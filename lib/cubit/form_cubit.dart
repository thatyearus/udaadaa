import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:udaadaa/models/feed.dart';
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
    } catch (e) {
      logger.e(e);
      emit(FormError(e.toString()));
    }
  }

  Map<String, XFile?> get selectedImages => _selectedImages;
}
