import 'dart:io';

enum ImagePickerSource { camera, gallery }

abstract class IImagePickerService {
  Future<File?> pickImage({required ImagePickerSource source});
}
