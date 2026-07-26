import 'package:flutter/material.dart';

class NewMemoryBottomSheet extends StatelessWidget {
  const NewMemoryBottomSheet({
    super.key,
    required this.onTakePhoto,
    required this.onChoosePhoto,
    required this.onQuickNote,
  });

  final VoidCallback onTakePhoto;
  final VoidCallback onChoosePhoto;
  final VoidCallback onQuickNote;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'New Memory',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: onTakePhoto,
            ),

            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose Photo'),
              onTap: onChoosePhoto,
            ),

            ListTile(
              leading: const Icon(Icons.note_alt_outlined),
              title: const Text('Quick Note'),
              onTap: onQuickNote,
            ),

            const ListTile(
              enabled: false,
              leading: Icon(Icons.mic),
              title: Text('Voice Note'),
              subtitle: Text('Coming Soon'),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}