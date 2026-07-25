


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/app_database.dart';
import '../providers/memory_provider.dart';
import '../services/camera_service.dart';
import '../widgets/common/app_header.dart';
import '../widgets/common/capture_button.dart';
import '../widgets/common/section_title.dart';
import '../widgets/memory/memory_card.dart';
import '../widgets/memory/memory_search_bar.dart';
import 'add_memory_screen.dart';
import 'memory_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CameraService _camera = CameraService();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemoryProvider>().loadMemories();
    });
  }

  Future<void> _capture() async {
  final file = await _camera.captureImage();

  if (!mounted || file == null) return;

  final saved = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => AddMemoryScreen(image: file),
    ),
  );

  if (!mounted) return;

  if (saved == true) {
    await context.read<MemoryProvider>().loadMemories();
  }

    );

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MemoryProvider>();

    final memories = provider.memories.where((m) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return m.title.toLowerCase().contains(q) ||
          (m.note ?? '').toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('MemoryLens')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const AppHeader(),
              const SizedBox(height: 16),
              MemorySearchBar(
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 16),
              CaptureButton(onPressed: _capture),
              const SizedBox(height: 24),
              SectionTitle(title: 'Memories'),
              const SizedBox(height: 12),
              Expanded(
                child: memories.isEmpty
                    ? const Center(child: Text('No memories yet'))
                    : ListView.builder(
                        itemCount: memories.length,
                        itemBuilder: (_, i) {
                          final Memory memory = memories[i];
                          return MemoryCard(
                            memory: memory,
                            onTap: () async {
  final updated = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => MemoryDetailScreen(
        memory: memory,
      ),
    ),
  );

  if (!mounted) return;

  if (updated == true) {
    await provider.loadMemories();
  }
},
                              );
                            },
                            onDelete: () {
                              provider.deleteMemory(memory.id);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
