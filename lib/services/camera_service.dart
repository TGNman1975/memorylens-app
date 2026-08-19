import 'dart:io';

import 'package:image_picker/image_picker.dart';

import 'image_storage_service.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> captureImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image == null) return null;

    final sourceFile = File(image.path);

    return ImageStorageService.saveImage(sourceFile);
  }
}