import 'dart:io';

import 'package:image_picker/image_picker.dart';

import 'image_storage_service.dart';

class GalleryService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (image == null) return null;

    final sourceFile = File(image.path);

    return ImageStorageService.saveImage(sourceFile);
  }
}