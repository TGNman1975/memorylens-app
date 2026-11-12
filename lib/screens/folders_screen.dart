import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/app_database.dart';
import '../providers/memory_provider.dart';
import '../widgets/home/home_memory_list.dart';
import 'memory_detail_screen.dart';

Future<int?> _editFolder(BuildContext context, [Folder? folder]) {
  final provider = context.read<MemoryProvider>();
  return showDialog<int>(
    context: context,
    builder: (_) => _FolderDialog(provider: provider, folder: folder),
  );
}

class _FolderDialog extends StatefulWidget {
  const _FolderDialog({required this.provider, this.folder});
  final MemoryProvider provider;
  final Folder? folder;

  @override
  State<_FolderDialog> createState() => _FolderDialogState();
}

class _FolderDialogState extends State<_FolderDialog> {
  late final _name = TextEditingController(text: widget.folder?.name);
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final id = await widget.provider.saveFolder(
        _name.text,
        id: widget.folder?.id,
      );
      if (mounted) Navigator.pop(context, id);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error is ArgumentError
            ? error.message.toString()
            : 'Unable to save folder.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: Text(widget.folder == null ? 'New folder' : 'Rename folder'),
    content: TextField(
      controller: _name,
      autofocus: true,
      enabled: !_saving,
      decoration: InputDecoration(
        labelText: 'Folder name',
        errorText: _error,
        errorMaxLines: 4,
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: const Text('Save'),
      ),
    ],
  );
}

class FolderField extends StatelessWidget {
  const FolderField({super.key, required this.id, required this.onChanged});
  final int? id;
  final ValueChanged<int?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final folders = context.watch<MemoryProvider>().folders;
    final name = folders.where((folder) => folder.id == id).firstOrNull?.name;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.folder_outlined),
      title: const Text('Folder (optional)'),
      subtitle: Text(name ?? 'Unfiled'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onChanged == null
          ? null
          : () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (routeContext) => FoldersScreen(
                    onSelected: (id) {
                      Navigator.pop(routeContext);
                      onChanged!(id);
                    },
                  ),
                ),
              );
            },
    );
  }
}

class FoldersScreen extends StatelessWidget {
  const FoldersScreen({super.key, this.onSelected});
  final ValueChanged<int?>? onSelected;

  Future<void> _delete(BuildContext context, Folder folder) async {
    final provider = context.read<MemoryProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text('Delete ${folder.name}?'),
        content: const Text(
          'Your memories will stay saved and move to Unfiled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await provider.deleteFolder(folder.id);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to delete folder. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MemoryProvider>();
    final counts = <int?, int>{};
    for (final memory in provider.memories) {
      counts.update(memory.folderId, (count) => count + 1, ifAbsent: () => 1);
    }
    void open(String title, int? id, {bool all = false}) {
      if (onSelected != null) {
        onSelected!(id);
        return;
      }
      Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => _FolderMemories(title: title, id: id, all: all),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Folders')),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined),
              title: const Text('New folder'),
              onTap: () async {
                final id = await _editFolder(context);
                if (context.mounted && id != null) onSelected?.call(id);
              },
            ),
            if (onSelected == null)
              ListTile(
                leading: const Icon(Icons.collections_bookmark_outlined),
                title: const Text('All Memories'),
                subtitle: Text('${provider.totalMemories}'),
                onTap: () => open('All Memories', null, all: true),
              ),
            ListTile(
              leading: const Icon(Icons.inbox_outlined),
              title: const Text('Unfiled'),
              subtitle: Text('${counts[null] ?? 0}'),
              onTap: () => open('Unfiled', null),
            ),
            for (final folder in provider.folders)
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(folder.name),
                subtitle: Text('${counts[folder.id] ?? 0}'),
                onTap: () => open(folder.name, folder.id),
                trailing: onSelected != null
                    ? null
                    : PopupMenuButton<bool>(
                        tooltip: 'Manage folder',
                        onSelected: (rename) async {
                          if (rename) {
                            await _editFolder(context, folder);
                          } else {
                            await _delete(context, folder);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: true, child: Text('Rename')),
                          PopupMenuItem(value: false, child: Text('Delete')),
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FolderMemories extends StatelessWidget {
  const _FolderMemories({
    required this.title,
    required this.id,
    required this.all,
  });
  final String title;
  final int? id;
  final bool all;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MemoryProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SafeArea(
        child: HomeMemoryList(
          memories: all
              ? provider.memories
              : provider.memories.where((m) => m.folderId == id).toList(),
          onTap: (memory) async {
            await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => MemoryDetailScreen(memory: memory),
              ),
            );
          },
          onDelete: (memory) => provider.deleteMemory(memory.id),
        ),
      ),
    );
  }
}
