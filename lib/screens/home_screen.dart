import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/date_formatter.dart';
import '../providers/memory_provider.dart';
import '../screens/add_memory_screen.dart';
import '../services/camera_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CameraService _cameraService = CameraService();
  String _searchText = "";

  Future<void> _captureMemory() async {
  final provider = context.read<MemoryProvider>();

  final File? image = await _cameraService.captureImage();

  if (!mounted || image == null) return;

  final result = await Navigator.of(context).push<Map<String, dynamic>>(
    MaterialPageRoute(
      builder: (_) => AddMemoryScreen(image: image),
    ),
  );

  if (!mounted || result == null) return;

  await provider.addMemory(
    title: result["title"] ?? "Untitled",
    note: result["note"],
    imagePath: image.path,
  );
}

  @override
  Widget build(BuildContext context) {
    final memories = context.watch<MemoryProvider>().memories;

    final filteredMemories = memories.where((memory) {
      final title = memory.title.toLowerCase();
      final note = (memory.note ?? "").toLowerCase();

      return title.contains(_searchText) ||
          note.contains(_searchText);
    }).toList();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              const Text(
                "MemoryLens",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Focus on what matters.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
  decoration: const InputDecoration(
    hintText: "Search your memories...",
    prefixIcon: Icon(Icons.search),
  ),
  onChanged: (value) {
    setState(() {
      _searchText = value.toLowerCase();
    });
  },
),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: _captureMemory,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text(
                    "Capture Memory",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Recent Memories",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: memories.isEmpty
                    ? const Center(
                        child: Text(
                          "No memories yet.\nTap Capture Memory to get started.",
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredMemories.length,
                        itemBuilder: (context, index) {
                          final memory = filteredMemories[index];

                          return Dismissible(
  key: ValueKey(memory.id),
  direction: DismissDirection.endToStart,

  background: Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(12),
    ),
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 24),
    child: const Icon(
      Icons.delete,
      color: Colors.white,
    ),
  ),

  confirmDismiss: (_) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Delete Memory"),
            content: const Text(
              "Are you sure you want to delete this memory?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete"),
              ),
            ],
          ),
        ) ??
        false;
  },

  onDismissed: (_) {
    context.read<MemoryProvider>().deleteMemory(memory.id);
  },

  child: Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MemoryDetailScreen(
          memory: memory,
        ),
      ),
    );
  },

  contentPadding: const EdgeInsets.all(12),

  leading: ...

  title: ...

  subtitle: ...
)
      contentPadding: const EdgeInsets.all(12),

      leading: memory.imagePath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(memory.imagePath!),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            )
          : const Icon(Icons.photo, size: 40),

      title: Row(
        children: [
          Expanded(
            child: Text(
              memory.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (memory.favourite)
            const Icon(
              Icons.star,
              color: Colors.amber,
            ),
        ],
      ),

      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),

          if ((memory.note ?? "").isNotEmpty)
            Text(memory.note!),

          const SizedBox(height: 6),

          Text(
            DateFormatter.format(memory.createdAt),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          )
        ],
      ),
    ),
  ),
);

  onDismissed: (_) {
    context.read<MemoryProvider>().deleteMemory(memory.id);
  },

  child: Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
            ),
    ),
  );
                              contentPadding: const EdgeInsets.all(12),

                              leading: memory.imagePath != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(memory.imagePath!),
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.photo, size: 40),

                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      memory.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (memory.favourite)
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                ],
                              ),

                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),

                                  if ((memory.note ?? "").isNotEmpty)
                                    Text(memory.note!),

                                  const SizedBox(height: 6),

                                  Text(
                                    memory.createdAt.toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              NavigationBar(
                selectedIndex: 0,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home),
                    label: "Home",
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.search),
                    label: "Search",
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.add_circle_outline),
                    label: "Capture",
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.history),
                    label: "Timeline",
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person),
                    label: "Me",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}