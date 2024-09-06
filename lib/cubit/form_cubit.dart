import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/models/report.dart';
import 'package:udaadaa/utils/constant.dart';

part 'form_state.dart';

class FormCubit extends Cubit<FormState> {
  FormCubit() : super(FormInitial());

  final Map<String, XFile?> _selectedImages = {
    'FOOD': null,
    'EXERCISE': null,
    'WEIGHT': null,
  };

  Future<void> updateImage(String type) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _selectedImages[type] = pickedFile;
      emit(FormInitial());
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
      await supabase.storage
          .from('FeedImages')
          .upload(imagePath, compressedImage);
      return imagePath;
    } catch (e) {
      logger.e(e);
      emit(FormError(e.toString()));
      return null;
    }
  }

  Future<void> submit({
    required String type,
    required String review,
    String? mealType,
    String? weight,
    String? exerciseTime,
    String? mealContent,
  }) async {
    try {
      logger.d("submitting form");
      emit(FormLoading());
      String? imagePath = await uploadImage(type);
      if (imagePath == null) {
        emit(FormError('Failed to upload image'));
        return;
      }
      final Feed feed = Feed(
        userId: supabase.auth.currentUser!.id,
        review: review,
        type: type,
        imagePath: imagePath,
      );
      await supabase.from('feed').insert(feed.toMap());
      _selectedImages[type] = null;
      emit(FormSuccess());
      updateReport(
        type: type,
        review: review,
        mealType: mealType,
        weight: weight,
        exerciseTime: exerciseTime,
        mealContent: mealContent,
      );
    } catch (e) {
      logger.e(e);
      emit(FormError(e.toString()));
    }
  }

  Future<void> updateReport({
    required String type,
    required String review,
    String? mealType,
    String? weight,
    String? exerciseTime,
    String? mealContent,
  }) async {
    try {
      switch (type) {
        case 'FOOD':
          // TODO: calorie calculation
          break;
        case 'EXERCISE':
          final int exerciseValue = int.parse(exerciseTime!);
          logger.d(
              "${supabase.auth.currentUser!.id} $exerciseValue ${DateTime.now()}");
          final Report report = Report(
            userId: supabase.auth.currentUser!.id,
            date: DateTime.now(),
            exercise: exerciseValue,
          );
          await supabase
              .from('report')
              .upsert(report.toMap(), onConflict: 'user_id, date');
          break;
        case 'WEIGHT':
          final double weightValue = double.parse(weight!);
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
    } catch (e) {
      logger.e(e);
      emit(FormError(e.toString()));
    }
  }

  Map<String, XFile?> get selectedImages => _selectedImages;
}
