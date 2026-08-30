import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageStorageService {
  static const String _photoDirectoryName = 'memory_photos';

  /// Saves an image permanently inside the application's Documents directory.
  static Future<File> saveImage(File source) async {
    if (!await source.exists()) {
      throw Exception('Source image file does not exist.');
    }

    final appDirectory = await getApplicationDocumentsDirectory();

    final photoDirectory = Directory(
      p.join(
        appDirectory.path,
        _photoDirectoryName,
      ),
    );

    if (!await photoDirectory.exists()) {
      await photoDirectory.create(recursive: true);
    }

    final extension = p.extension(source.path);

    final fileName =
        'memory_${DateTime.now().microsecondsSinceEpoch}$extension';

    final destination = File(
      p.join(
        photoDirectory.path,
        fileName,
      ),
    );

    final savedFile = await source.copy(destination.path);

    if (!await savedFile.exists()) {
      throw Exception('Failed to save image.');
    }

    return savedFile;
  }

  /// Converts an absolute image path into a stable relative path
  /// for storage in the database.
  static Future<String?> toStoredPath(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    // Already a relative path.
    if (!p.isAbsolute(imagePath)) {
      return imagePath;
    }

    final appDirectory = await getApplicationDocumentsDirectory();

    final relativePath = p.relative(
      imagePath,
      from: appDirectory.path,
    );

    return relativePath;
  }

  /// Resolves a database path into the current device's absolute path.
  ///
  /// Supports both new relative paths and legacy absolute paths.
  static Future<File?> resolveImageFile(String? storedPath) async {
    if (storedPath == null || storedPath.isEmpty) {
      return null;
    }

    // Legacy absolute path.
    if (p.isAbsolute(storedPath)) {
      final legacyFile = File(storedPath);

      if (await legacyFile.exists()) {
        return legacyFile;
      }

      return null;
    }

    final appDirectory = await getApplicationDocumentsDirectory();

    final file = File(
      p.join(
        appDirectory.path,
        storedPath,
      ),
    );

    if (await file.exists()) {
      return file;
    }

    return null;
  }

  /// Deletes an image from permanent storage.
  static Future<void> deleteImage(String? storedPath) async {
    final file = await resolveImageFile(storedPath);

    if (file == null) {
      return;
    }

    if (await file.exists()) {
      await file.delete();
    }
  }
}