import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'quick_note_screen.dart';
import '../services/gallery_service.dart';
import '../providers/memory_provider.dart';
import '../services/camera_service.dart';
import '../services/location_service.dart';
import '../widgets/common/app_header.dart';
import '../widgets/home/memory_stats_card.dart';
import '../widgets/common/section_title.dart';
import 'map_screen.dart';
import '../widgets/memory/memory_search_bar.dart';
import 'add_memory_screen.dart';
import 'memory_detail_screen.dart';
import '../widgets/home/new_memory_button.dart';
import '../widgets/home/new_memory_bottom_sheet.dart';
import '../widgets/home/photo_source_sheet.dart';
import '../widgets/home/home_memory_list.dart';

enum MemorySort {
  newest,
  oldest,
  favourites,
}
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CameraService _camera = CameraService();
  final LocationService _locationService = LocationService();

  String _query = '';
  String? _filter;
  MemorySort _sort = MemorySort.newest;
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
  final saved = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => const QuickNoteScreen(),
    ),
  );

  if (!mounted) return;

  if (saved == true) {
    await context.read<MemoryProvider>().loadMemories();
  }
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
  if (_filter == 'photos' && m.imagePath == null) {
    return false;
  }

  if (_filter == 'notes' && m.imagePath != null) {
    return false;
  }

  if (_filter == 'favourites' && !m.favourite) {
    return false;
  }

  if (_query.isEmpty) return true;

  final q = _query.toLowerCase();

  return m.title.toLowerCase().contains(q) ||
      (m.note ?? '').toLowerCase().contains(q);
}).toList();
    switch (_sort) {
  case MemorySort.newest:
    memories.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );
    break;

  case MemorySort.oldest:
    memories.sort(
      (a, b) => a.createdAt.compareTo(b.createdAt),
    );
    break;

  case MemorySort.favourites:
    memories.sort(
      (a, b) => b.favourite
          .toString()
          .compareTo(a.favourite.toString()),
    );
    break;
}
    return Scaffold(
      appBar: AppBar(
        title: const Text('MemoryLens'),
        actions: [
  PopupMenuButton<MemorySort>(
    tooltip: 'Sort',
    icon: const Icon(Icons.sort),
    onSelected: (sort) {
      setState(() {
        _sort = sort;
      });
    },
    itemBuilder: (_) => const [
      PopupMenuItem(
        value: MemorySort.newest,
        child: Text('Newest'),
      ),
      PopupMenuItem(
        value: MemorySort.oldest,
        child: Text('Oldest'),
      ),
      PopupMenuItem(
        value: MemorySort.favourites,
        child: Text('Favourites First'),
      ),
    ],
  ),
    IconButton(
    tooltip: 'Map',
    icon: const Icon(Icons.map),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const MapScreen(),
        ),
      );
    },
  ),
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
              Row(
  children: [
    MemoryStatsCard(
      label: 'All',
      value: provider.totalMemories,
      icon: Icons.apps,
      onTap: () {
        setState(() {
          _filter = null;
        });
      },
    ),
    MemoryStatsCard(
      label: 'Photos',
      value: provider.photoCount,
      icon: Icons.photo,
      onTap: () {
        setState(() {
          _filter = _filter == 'photos' ? null : 'photos';
        });
      },
    ),
    MemoryStatsCard(
      label: 'Notes',
      value: provider.quickNoteCount,
      icon: Icons.sticky_note_2_outlined,
      onTap: () {
        setState(() {
          _filter = _filter == 'notes' ? null : 'notes';
        });
      },
    ),
    MemoryStatsCard(
      label: 'Favs',
      value: provider.favouriteCount,
      icon: Icons.star,
      onTap: () {
        setState(() {
          _filter = _filter == 'favourites'
              ? null
              : 'favourites';
        });
      },
    ),
  ],
),

const SizedBox(height: 20),
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