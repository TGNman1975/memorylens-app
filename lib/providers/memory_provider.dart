import 'package:flutter/material.dart';

import '../models/memory.dart';

class MemoryProvider extends ChangeNotifier {
  final List<Memory> _memories = [
    Memory(title: 'Spare House Key'),
    Memory(title: 'Parked Car'),
    Memory(title: 'Passport'),
  ];

  List<Memory> get memories => List.unmodifiable(_memories);

  void addMemory(Memory memory) {
    _memories.insert(0, memory);
    notifyListeners();
  }
}