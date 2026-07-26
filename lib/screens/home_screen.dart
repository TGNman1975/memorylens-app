import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'quick_note_screen.dart';
import '../services/gallery_service.dart';
import '../providers/memory_provider.dart';
import '../services/camera_service.dart';
import '../services/location_service.dart';
import '../widgets/common/app_header.dart';

import '../widgets/common/section_title.dart';

import '../widgets/memory/memory_search_bar.dart';
import 'add_memory_screen.dart';
import 'memory_detail_screen.dart';
import '../widgets/home/new_memory_button.dart';
import '../widgets/home/new_memory_bottom_sheet.dart';
import '../widgets/home/photo_source_sheet.dart';
import '../widgets/home/home_memory_list.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CameraService _camera = CameraService();
  final LocationService _locationService = LocationService();

  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemoryProvider>().loadMemories();
    });
  }
  Future<void> _showNewMemorySheet() async {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (_) => NewMemoryBottomSheet(
      onTakePhoto: () {
        Navigator.pop(context);
        _showPhotoSourceSheet();
      },
      onChoosePhoto: () {
        Navigator.pop(context);
        _showPhotoSourceSheet();
      },
      onQuickNote: () {
        Navigator.pop(context);
        _quickNote();
      },
    ),
  );
}

Future<void> _showPhotoSourceSheet() async {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (_) => PhotoSourceSheet(
      onCamera: () {
        Navigator.pop(context);
        _capture();
      },
      onGallery: () async {
  Navigator.pop(context);

  final image = await GalleryService.pickImage();

  if (!mounted || image == null) return;

  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => AddMemoryScreen(
        image: image,
      ),
    ),
  );

  if (result == true && mounted) {
    await context.read<MemoryProvider>().loadMemories();
  }
},
    ),
  );
}

  Future<void> _capture() async {
    final file = await _camera.captureImage();

    if (!mounted || file == null) return;

    final provider = context.read<MemoryProvider>();

    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddMemoryScreen(image: file),
      ),
    );

    if (!mounted) return;

    if (saved == true) {
      await provider.loadMemories();
    }
  }

  Future<void> _quickNote() async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const QuickNoteScreen(),
    ),
  );
}

  Future<void> _testLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Latitude: ${position.latitude}\n'
            'Longitude: ${position.longitude}',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
      appBar: AppBar(
        title: const Text('MemoryLens'),
        actions: [
          IconButton(
            tooltip: 'Test GPS',
            icon: const Icon(Icons.my_location),
            onPressed: _testLocation,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const AppHeader(),
              const SizedBox(height: 16),

              MemorySearchBar(
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              NewMemoryButton(
  onPressed: _showNewMemorySheet,
),

              const SizedBox(height: 24),

              const SectionTitle(
                title: 'Memories',
              ),

              const SizedBox(height: 12),

              Expanded(
  child: HomeMemoryList(
    memories: memories,
    onTap: (memory) async {
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
    onDelete: (memory) async {
      await provider.deleteMemory(memory.id);
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