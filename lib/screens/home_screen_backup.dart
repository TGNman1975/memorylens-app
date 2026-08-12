import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'quick_note_screen.dart';
import '../services/gallery_service.dart';
import '../providers/memory_provider.dart';
import '../services/camera_service.dart';

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
import 'settings_screen.dart';

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
        builder: (_) => AddMemoryScreen(
          image: file,
        ),
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



  Widget _buildEmptyState(
    BuildContext context,
    MemoryProvider provider,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          24,
          24,
          24,
          40,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.18),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/memorylens_logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.search,
                    size: 48,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Save it. Forget it.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 12),

            Text(
              'MemoryLens stores your memories, '
              'so you don’t have to.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                    height: 1.4,
                  ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _showNewMemorySheet,
                icon: const Icon(Icons.add),
                label: const Text(
                  'Create Your First Memory',
                ),
              ),
            ),

            const SizedBox(height: 28),

            _EmptyStateTip(
              icon: Icons.photo_camera_outlined,
              title: 'Remember places',
              text: 'Save photos and where you were.',
            ),

            const SizedBox(height: 12),

            _EmptyStateTip(
              icon: Icons.edit_note,
              title: 'Remember things',
              text: 'Keep quick notes for later.',
            ),

            const SizedBox(height: 12),

            _EmptyStateTip(
              icon: Icons.notifications_active_outlined,
              title: 'Remember later',
              text: 'Set a reminder for the future.',
            ),

            if (provider.memories.isNotEmpty)
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
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

    final hasMemories = provider.memories.isNotEmpty;

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
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: hasMemories
            ? Padding(
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
                              _filter =
                                  _filter == 'photos'
                                      ? null
                                      : 'photos';
                            });
                          },
                        ),
                        MemoryStatsCard(
                          label: 'Notes',
                          value: provider.quickNoteCount,
                          icon: Icons.sticky_note_2_outlined,
                          onTap: () {
                            setState(() {
                              _filter =
                                  _filter == 'notes'
                                      ? null
                                      : 'notes';
                            });
                          },
                        ),
                        MemoryStatsCard(
                          label: 'Favs',
                          value: provider.favouriteCount,
                          icon: Icons.star,
                          onTap: () {
                            setState(() {
                              _filter =
                                  _filter == 'favourites'
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
                          final updated =
                              await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  MemoryDetailScreen(
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
                          await provider.deleteMemory(
                            memory.id,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            : _buildEmptyState(
                context,
                provider,
              ),
      ),
    );
  }
}

class _EmptyStateTip extends StatelessWidget {
  const _EmptyStateTip({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}