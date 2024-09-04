import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

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
}
