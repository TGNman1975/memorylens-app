import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';

class BackupService {
  static Future<File> createBackup(
    List<Memory> memories,
  ) async {
    final directory = await getApplicationDocumentsDirectory();

    final filename =
        'memorylens_backup_${DateTime.now().millisecondsSinceEpoch}.json';

    final file = File('${directory.path}/$filename');

    final data = memories
        .map(
          (m) => {
            'id': m.id,
            'title': m.title,
            'note': m.note,
            'imagePath': m.imagePath,
            'latitude': m.latitude,
            'longitude': m.longitude,
            'favourite': m.favourite,
            'createdAt': m.createdAt.toIso8601String(),
          },
        )
        .toList();

    const encoder = JsonEncoder.withIndent('  ');

    await file.writeAsString(
      encoder.convert(data),
    );

    return file;
  }
}