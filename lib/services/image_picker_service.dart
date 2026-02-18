import 'dart:io';

import 'package:image_picker/image_picker.dart';

import 'i_image_picker_service.dart';

class ImagePickerServiceImpl implements IImagePickerService {
  final ImagePicker _picker;

  ImagePickerServiceImpl({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  @override
  Future<File?> pickImage({required ImagePickerSource source}) async {
    try {
      final imageSource = source == ImagePickerSource.camera
          ? ImageSource.camera
          : ImageSource.gallery;

      final XFile? pickedFile = await _picker.pickImage(
        source: imageSource,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao selecionar imagem: $e');
    }
  }
}
