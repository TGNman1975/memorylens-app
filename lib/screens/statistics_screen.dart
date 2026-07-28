import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/memory_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MemoryProvider>();

    Widget statTile(
      IconData icon,
      String title,
      int value,
    ) {
      return Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: Text(
            value.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          statTile(
            Icons.apps,
            'Total Memories',
            provider.totalMemories,
          ),
          statTile(
            Icons.photo,
            'Photos',
            provider.photoCount,
          ),
          statTile(
            Icons.sticky_note_2_outlined,
            'Quick Notes',
            provider.quickNoteCount,
          ),
          statTile(
            Icons.star,
            'Favourites',
            provider.favouriteCount,
          ),
        ],
      ),
    );
  }
}