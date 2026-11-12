import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/memory_provider.dart';
import '../services/camera_service.dart';
import '../services/gallery_service.dart';

import '../widgets/common/app_header.dart';
import '../widgets/common/section_title.dart';
import '../widgets/home/home_memory_list.dart';
import '../widgets/home/memory_stats_card.dart';
import '../widgets/home/new_memory_bottom_sheet.dart';
import '../widgets/home/new_memory_button.dart';
import '../widgets/memory/memory_search_bar.dart';

import 'add_memory_screen.dart';
import 'memory_detail_screen.dart';
import 'quick_note_screen.dart';
import 'settings_screen.dart';
import 'folders_screen.dart';

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
          _capture();
        },
        onChoosePhoto: () {
          Navigator.pop(context);
          _choosePhoto();
        },
        onQuickNote: () {
          Navigator.pop(context);
          _quickNote();
        },
      ),
    );
  }

  Future<void> _choosePhoto() async {
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
  }

  Future<void> _capture() async {
    final file = await _camera.captureImage();

    if (!mounted || file == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddMemoryScreen(
          image: file,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await context.read<MemoryProvider>().loadMemories();
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
            SizedBox(
              width: 104,
              height: 104,
              child: Image.asset(
                'assets/images/memorylens_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.search,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
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
            const _EmptyStateTip(
              icon: Icons.photo_camera_outlined,
              title: 'Remember moments',
              text: 'Save photos of things you want to remember.',
            ),
            const SizedBox(height: 12),
            const _EmptyStateTip(
              icon: Icons.edit_note,
              title: 'Remember things',
              text: 'Keep quick notes for later.',
            ),
            const SizedBox(height: 12),
            const _EmptyStateTip(
              icon: Icons.notifications_active_outlined,
              title: 'Remember later',
              text: 'Set a reminder for the future.',
            ),
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

      if (_query.isEmpty) {
        return true;
      }

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
          (a, b) {
            if (a.favourite == b.favourite) {
              return b.createdAt.compareTo(a.createdAt);
            }

            return a.favourite ? -1 : 1;
          },
        );
        break;
    }

    final hasMemories = provider.memories.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MemoryLens'),
        actions: [
          IconButton(
            tooltip: 'Folders',
            icon: const Icon(Icons.folder_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const FoldersScreen()),
            ),
          ),
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
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppHeader(),

                        const SizedBox(height: 8),

                        MemorySearchBar(
                          onChanged: (value) {
                            setState(() {
                              _query = value;
                            });
                          },
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: MemoryStatsCard(
                                label: 'All',
                                value: provider.totalMemories,
                                icon: Icons.apps,
                                onTap: () {
                                  setState(() {
                                    _filter = null;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: MemoryStatsCard(
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
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: MemoryStatsCard(
                                label: 'Notes',
                                value: provider.quickNoteCount,
                                icon:
                                    Icons.sticky_note_2_outlined,
                                onTap: () {
                                  setState(() {
                                    _filter =
                                        _filter == 'notes'
                                            ? null
                                            : 'notes';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: MemoryStatsCard(
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
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        NewMemoryButton(
                          onPressed: _showNewMemorySheet,
                        ),

                        const SizedBox(height: 12),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: SectionTitle(
                            title: 'Memories',
                          ),
                        ),

                        const SizedBox(height: 4),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
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

                          if (!mounted) {
                            return;
                          }

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
                  ),
                ],
              )
            : _buildEmptyState(context),
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
