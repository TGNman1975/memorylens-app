import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:memory_lens/models/memory.dart';
import 'package:memory_lens/providers/memory_provider.dart';
import 'package:memory_lens/services/camera_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CameraService _cameraService = CameraService();

  Future<void> _captureMemory() async {
    final File? image = await _cameraService.captureImage();

    if (!mounted || image == null) return;

    context.read<MemoryProvider>().addMemory(
      Memory(
        title: 'New Memory',
        imagePath: image.path,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final memories = context.watch<MemoryProvider>().memories;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              const Text(
                'MemoryLens',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Focus on what matters.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),

              const TextField(
                decoration: InputDecoration(
                  hintText: 'Search your memories...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: _captureMemory,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text(
                    'Capture Memory',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Recent Memories',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  itemCount: memories.length,
                  itemBuilder: (context, index) {
                    final memory = memories[index];

                    return Card(
                      child: ListTile(
                        leading: memory.imagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(memory.imagePath!),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.photo),

                        title: Text(memory.title),

                        subtitle: Text(
                          memory.imagePath == null
                              ? 'Tap Capture to add a photo'
                              : 'Photo saved',
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
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.search),
                    label: 'Search',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.add_circle_outline),
                    label: 'Capture',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.history),
                    label: 'Timeline',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person),
                    label: 'Me',
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