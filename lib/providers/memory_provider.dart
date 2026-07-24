import 'package:flutter/material.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../repositories/memory_repository.dart';

class MemoryProvider extends ChangeNotifier {
  final MemoryRepository repository;

  MemoryProvider(this.repository);

  List<Memory> _memories = [];

  List<Memory> get memories => _memories;

  // ---------------------------------------------------------------------------
  // Load
  // ---------------------------------------------------------------------------

  Future<void> loadMemories() async {
    _memories = await repository.getAll();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Create
  // ---------------------------------------------------------------------------

  Future<void> addMemory({
    required String title,
    String? note,
    String? imagePath,
    bool favourite = false,
  }) async {
    await repository.add(
      MemoriesCompanion.insert(
        title: title,
        note: Value(note),
        imagePath: Value(imagePath),
        favourite: Value(favourite),
      ),
    );

    await loadMemories();
  }

  // ---------------------------------------------------------------------------
  // Update
  // ---------------------------------------------------------------------------

  Future<void> updateMemory(Memory memory) async {
    await repository.update(memory);
    await loadMemories();
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  Future<void> deleteMemory(int id) async {
    await repository.delete(id);
    await loadMemories();
  }
}