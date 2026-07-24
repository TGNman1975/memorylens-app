import 'package:flutter/material.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../repositories/memory_repository.dart';

class MemoryProvider extends ChangeNotifier {
  final MemoryRepository repository;

  MemoryProvider(this.repository);

  List<Memory> _memories = [];

  List<Memory> get memories => _memories;

  Future<void> loadMemories() async {
    _memories = await repository.getAll();
    notifyListeners();
  }

  Future<void> addMemory({
    required String title,
    String? note,
    String? imagePath,
  }) async {
    await repository.add(
      MemoriesCompanion.insert(
        title: title,
        note: Value(note),
        imagePath: Value(imagePath),
      ),
    );

    await loadMemories();
  }

  Future<void> deleteMemory(int id) async {
    await repository.delete(id);
    await loadMemories();
  }
}