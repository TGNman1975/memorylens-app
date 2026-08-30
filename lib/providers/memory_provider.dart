import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../database/app_database.dart';
import '../repositories/memory_repository.dart';
import '../services/image_storage_service.dart';

class MemoryProvider extends ChangeNotifier {
  MemoryProvider(this.repository);

  final MemoryRepository repository;

  List<Memory> _memories = [];

  List<Memory> get memories => _memories;

  int get totalMemories => _memories.length;

  int get favouriteCount =>
      _memories.where((memory) => memory.favourite).length;

  int get photoCount =>
      _memories.where(
        (memory) =>
            memory.imagePath != null &&
            memory.imagePath!.isNotEmpty,
      ).length;

  int get quickNoteCount =>
      _memories.where(
        (memory) =>
            memory.imagePath == null ||
            memory.imagePath!.isEmpty,
      ).length;

  int get reminderCount =>
      _memories.where(
        (memory) => memory.reminderAt != null,
      ).length;

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
    DateTime? reminderAt,
  }) async {
    final storedImagePath =
        await ImageStorageService.toStoredPath(imagePath);

    await repository.add(
      MemoriesCompanion.insert(
        title: title,
        note: Value(note),
        imagePath: Value(storedImagePath),
        favourite: Value(favourite),
        reminderAt: Value(reminderAt),
      ),
    );

    await loadMemories();
  }

  // ---------------------------------------------------------------------------
  // Update
  // ---------------------------------------------------------------------------

  Future<void> updateMemory({
    required Memory existing,
    required String title,
    String? note,
    bool favourite = false,
    DateTime? reminderAt,
  }) async {
    final updated = existing.copyWith(
      title: title,
      note: Value(note),
      favourite: favourite,
      reminderAt: Value(reminderAt),
    );

    await repository.update(updated);

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