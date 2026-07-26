import 'package:flutter/material.dart';

class PhotoSourceSheet extends StatelessWidget {
  const PhotoSourceSheet({
    super.key,
    required this.onCamera,
    required this.onGallery,
  });

  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Photo',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: onCamera,
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: onGallery,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}