import 'dart:io';

import 'package:image_picker/image_picker.dart';

class GalleryService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (image == null) return null;

    return File(image.path);
  }
}