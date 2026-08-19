import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageStorageService {
  static Future<File> saveImage(File source) async {
    final appDirectory =
        await getApplicationDocumentsDirectory();

    final photoDirectory = Directory(
      p.join(appDirectory.path, 'memory_photos'),
    );

    if (!await photoDirectory.exists()) {
      await photoDirectory.create(recursive: true);
    }

    final extension = p.extension(source.path);

    final fileName =
        'memory_${DateTime.now().microsecondsSinceEpoch}$extension';

    final destination = File(
      p.join(photoDirectory.path, fileName),
    );

    return source.copy(destination.path);
  }

  static Future<void> deleteImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return;
    }

    final file = File(imagePath);

    if (await file.exists()) {
      await file.delete();
    }
  }
}