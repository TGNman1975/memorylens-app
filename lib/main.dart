import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'database/app_database.dart';
import 'providers/memory_provider.dart';
import 'repositories/memory_repository.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  final database = AppDatabase();
  final repository = MemoryRepository(database);

  runApp(
    ChangeNotifierProvider(
      create: (_) => MemoryProvider(repository)..loadMemories(),
      child: const MemoryLensApp(),
    ),
  );
}

class MemoryLensApp extends StatelessWidget {
  const MemoryLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemoryLens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}