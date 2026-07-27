import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Map'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 80,
            ),
            SizedBox(height: 20),
            Text(
              'Interactive Memory Map\nComing Soon',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}