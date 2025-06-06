import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/cubit/profile_cubit.dart';
import 'package:udaadaa/models/calorie.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/models/report.dart';
import 'package:udaadaa/models/weight.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';

part 'form_state.dart';

class FormCubit extends Cubit<FormState> {
  ProfileCubit profileCubit;
  FeedCubit feedCubit;
  FormCubit(
    this.profileCubit,
    this.feedCubit,
  ) : super(FormInitial());

  final Map<String, XFile?> _selectedImages = {
    'FOOD': null,
    'EXERCISE': null,
    'WEIGHT': null,
  };

  List<bool> _mealSelection = [true, false, false, false];
  FeedType _feedType = FeedType.breakfast;

  void updateMealSelection(int index) {
    _mealSelection = List.generate(_mealSelection.length, (i) => i == index);
    switch (index) {
      case 0:
        _feedType = FeedType.breakfast;
        break;
      case 1:
        _feedType = FeedType.lunch;
        break;
      case 2:
        _feedType = FeedType.dinner;
        break;
      case 3:
        _feedType = FeedType.snack;
        break;
    }
    emit(FormInitial());
  }

  Future<void> updateImage(String type, ImageSource pickertype) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: pickertype);

      if (pickedFile != null) {
        _selectedImages[type] = pickedFile;
        emit(FormInitial());
      }
    } catch (e) {
      Analytics().logEvent(
        "이미지_업로드_오류",
        parameters: {
          "에러_내역": e.toString(),
          "이미지_타입": type,
          "소스_타입": pickertype.toString(),
        },
      );
      logger.e("이미지 업로드 중 오류 발생: $e");
      emit(FormError('이미지 업로드 중 오류가 발생했습니다'));
    }
  }

  Future<File?> compressImage(File file) async {
    try {
      final img.Image? image = img.decodeImage(file.readAsBytesSync());

      if (image == null) {
        throw Exception('Unable to decode image');
      }

      img.Image resizedImage = img.copyResize(image, width: 1024);

      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = tempDir.path;
      final File compressedImage =
          File('$tempPath/${DateTime.now().microsecondsSinceEpoch}.jpg')
            ..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 70));

      return compressedImage;
    } catch (e) {
      Analytics().logEvent("업로드_압축실패", parameters: {"에러": e.toString()});
      logger.e(e);
      return null;
    }
  }

  Future<String?> uploadImage(String type) async {
    final XFile? file = _selectedImages[type];
    if (file == null) {
      emit(FormError('No image selected'));
      return null;
    }

    try {
      emit(FormLoading());
      final File? compressedImage = await compressImage(File(file.path));
      if (compressedImage == null) {
        emit(FormError('Failed to compress image'));
        return null;
      }
      final userId = supabase.auth.currentUser?.id;
      final imagePath =
          '$userId/$type/${DateTime.now().microsecondsSinceEpoch}.jpg';
      for (int attempt = 0; attempt < 3; attempt++) {
        try {
          await supabase.storage
              .from('FeedImages')
              .upload(imagePath, compressedImage)
              .timeout(const Duration(seconds: 15));
          logger.d("✅ 이미지 업로드 성공: $imagePath (시도: ${attempt + 1}/3)");
          break;
        } catch (e) {
          logger.w("🔄 이미지 업로드 실패 (시도: ${attempt + 1}/3): $e");
          if (attempt == 2) {
            logger.e("❌ 이미지 업로드 최종 실패: $e");
            rethrow;
          }
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
      return imagePath;
    } catch (e) {
      logger.e(e);
      Analytics().logEvent("업로드_이미지실패", parameters: {"에러": e.toString()});
      emit(FormError(e.toString()));
      return null;
    }
  }

  Future<void> calculate(
    String mealContent,
  ) async {
    try {
      emit(FormLoading());
      final String? base64String = await getBase64Image('FOOD');
      if (base64String == null) {
        emit(FormError('Failed to get base64 image'));
        return;
      }
      final res = await dioClient.dio.post(
        '/estimateCal',
        data: {
          'selectedImage': base64String,
          'description': mealContent,
        },
      );
      final Map<String, dynamic> jsonResponse = json.decode(res.toString());
      Calorie calorie = Calorie.fromJson(jsonResponse);
      emit(FormCalorie(calorie));
    } catch (e) {
      Analytics().logEvent("업로드_칼로리실패", parameters: {"에러": e.toString()});
      logger.e(e);
      emit(FormError(e.toString()));
    }
  }

  Future<dynamic> feedInfo({
    required FeedType type,
    required String review,
    // String? mealType,
    double? weight,
    int? exerciseTime,
    String? mealContent,
    Calorie? calorie,
    required String contentType,
  }) async {
    try {
      if (state is FormLoading) {
        return;
      }
      emit(FormLoading());
      String? imagePath = await uploadImage(contentType);
      if (imagePath == null) {
        emit(FormError('Failed to upload image'));
        return;
      }
      return {
        "user_id": supabase.auth.currentUser!.id,
        "review": review,
        "type": type,
        "image_path": imagePath,
        "calorie": calorie?.totalCalories,
        "is_challenge": profileCubit.getIsChallenger,
        'weight': weight,
        'exercise_time': exerciseTime,
      };
    } catch (e) {
      Analytics().logEvent("업로드_제출실패", parameters: {"에러": e.toString()});
      logger.e(e);
      emit(FormError(e.toString()));
    }
  }

  void missionComplete(
      {required FeedType type,
      required String review,
      String? mealType,
      double? weight,
      int? exerciseTime,
      String? mealContent,
      Calorie? calorie,
      required String contentType,
      String? feedId}) {
    emit(FormSuccess());
    updateReport(
      type: type,
      review: review,
      contentType: contentType,
      mealType: mealType,
      weight: weight,
      exerciseTime: exerciseTime,
      mealContent: mealContent,
      feedId: feedId,
      calorie: calorie,
    );
    feedCubit.fetchMyFeeds();
  }

/*
  Future<void> submit(
      {required FeedType type,
      required String review,
      String? mealType,
      String? weight,
      String? exerciseTime,
      String? mealContent,
      Calorie? calorie,
      required String contentType}) async {
    try {
      if (state is FormLoading) {
        return;
      }
      emit(FormLoading());
      String? imagePath = await uploadImage(contentType);
      if (imagePath == null) {
        emit(FormError('Failed to upload image'));
        return;
      }
      final Feed feed = Feed(
        userId: supabase.auth.currentUser!.id,
        review: review,
        type: type,
        imagePath: imagePath,
        calorie: calorie?.totalCalories,
        isChallenge: profileCubit.getIsChallenger,
      );
      final ret =
          await supabase.from('feed').insert(feed.toMap()).select().single();
      emit(FormSuccess());
      updateReport(
        type: type,
        review: review,
        contentType: contentType,
        mealType: mealType,
        weight: weight,
        exerciseTime: exerciseTime,
        mealContent: mealContent,
        feedId: ret['id'],
        calorie: calorie,
      );
      feedCubit.fetchMyFeeds();
    } catch (e) {
      Analytics().logEvent("업로드_제출실패", parameters: {"에러": e.toString()});
      logger.e(e);
      emit(FormError(e.toString()));
    }
  }*/

  Future<void> submitWeight(
      {required String weight, required String contentType}) async {
    try {
      if (state is FormLoading) {
        return;
      }
      emit(FormLoading());
      String? imagePath = await uploadImage(contentType);
      if (imagePath == null) {
        emit(FormError('Failed to upload image'));
        return;
      }
      final Weight curWeight = Weight(
        userId: supabase.auth.currentUser!.id,
        date: DateTime.now(),
        weight: double.parse(weight),
        imagePath: imagePath,
      );
      await supabase.from('weight').insert(curWeight.toMap());
      /*updateReport(
        type: FeedType.weight,
        contentType: contentType,
        weight: weight,
      );*/
      emit(FormSuccess());
      feedCubit.fetchMyFeeds();
      feedCubit.updateMission();
    } catch (e) {
      Analytics().logEvent("업로드_제출실패", parameters: {"에러": e.toString()});
      logger.e(e);
      emit(FormError("인증에 실패했습니다."));
    }
  }

  Future<void> updateReport({
    required FeedType type,
    String? review,
    required String contentType,
    String? feedId,
    String? mealType,
    double? weight,
    int? exerciseTime,
    String? mealContent,
    Calorie? calorie,
  }) async {
    try {
      await profileCubit.getMyTodayReport();
      final Report? prevReport = profileCubit.getReport;
      switch (type) {
        case FeedType.breakfast:
        case FeedType.lunch:
        case FeedType.dinner:
        case FeedType.snack:
          /*
          final String? base64String = await getBase64Image('FOOD');
          if (base64String == null) {
            emit(FormError('Failed to get base64 image'));
            return;
          }
          final res = await dioClient.dio.post(
            '/estimateCal',
            data: {
              'selectedImage': base64String,
              'description': mealContent!,
            },
          );
          final Map<String, dynamic> jsonResponse = json.decode(res.toString());
          Calorie calorie = Calorie.fromJson(jsonResponse);
          
          await supabase
              .from('feed')
              .update({'calorie': calorie.totalCalories}).eq('id', feedId);*/
          final Report report = Report(
            userId: supabase.auth.currentUser!.id,
            date: DateTime.now(),
            breakfast: type == FeedType.breakfast
                ? (prevReport?.breakfast ?? 0) + (calorie?.totalCalories ?? 0)
                : null,
            lunch: type == FeedType.lunch
                ? (prevReport?.lunch ?? 0) + (calorie?.totalCalories ?? 0)
                : null,
            dinner: type == FeedType.dinner
                ? (prevReport?.dinner ?? 0) + (calorie?.totalCalories ?? 0)
                : null,
            snack: type == FeedType.snack
                ? (prevReport?.snack ?? 0) + (calorie?.totalCalories ?? 0)
                : null,
          );
          await supabase
              .from('report')
              .upsert(report.toMap(), onConflict: 'user_id, date');
          break;
        case FeedType.exercise:
          final int exerciseValue = exerciseTime!;
          logger.d(
              "${supabase.auth.currentUser!.id} $exerciseValue ${DateTime.now()}");
          final Report report = Report(
            userId: supabase.auth.currentUser!.id,
            date: DateTime.now(),
            exercise: (prevReport?.exercise ?? 0) + exerciseValue,
          );
          await supabase
              .from('report')
              .upsert(report.toMap(), onConflict: 'user_id, date');
          break;
        case FeedType.weight:
          final double weightValue = weight!;
          logger.d(
              "${supabase.auth.currentUser!.id} $weightValue ${DateTime.now()}");
          final Report report = Report(
            userId: supabase.auth.currentUser!.id,
            date: DateTime.now(),
            weight: weightValue,
          );
          await supabase
              .from('report')
              .upsert(report.toMap(), onConflict: 'user_id, date');
          break;
      }
      selectedImages[contentType] = null;
      profileCubit.getMyTodayReport();
      profileCubit.selectDay(DateTime.now());
    } catch (e) {
      Analytics().logEvent("업로드_리포트실패", parameters: {"에러": e.toString()});
      logger.e(e);
      emit(FormError(e.toString()));
    }
  }

  Future<String?> getBase64Image(String type) async {
    if (_selectedImages[type] == null) {
      return null;
    }

    String extension = _selectedImages[type]!.path.split('.').last;
    String mimeType;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        mimeType = 'image/jpeg';
        break;
      case 'png':
        mimeType = 'image/png';
        break;
      case 'gif':
        mimeType = 'image/gif';
        break;
      case 'bmp':
        mimeType = 'image/bmp';
        break;
      case 'webp':
        mimeType = 'image/webp';
        break;
      default:
        mimeType = 'application/octet-stream'; // 알 수 없는 확장자의 경우 기본값
        break;
    }

    File file = File(_selectedImages[type]!.path);
    File? compressedFile = await compressImage(file);
    if (compressedFile == null) {
      return null;
    }
    List<int> bytes = compressedFile.readAsBytesSync();
    String base64Image = base64Encode(bytes);

    return 'data:$mimeType;base64,$base64Image';
  }

  Map<String, XFile?> get selectedImages => _selectedImages;
  List<bool> get mealSelection => _mealSelection;
  FeedType get feedType => _feedType;
}
