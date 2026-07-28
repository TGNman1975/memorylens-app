import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../providers/memory_provider.dart';
import 'memory_detail_screen.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MemoryProvider>();

    final memories = provider.memories
        .where(
          (m) => m.latitude != null && m.longitude != null,
        )
        .toList();

    final LatLng centre = memories.isNotEmpty
        ? LatLng(
            memories.first.latitude!,
            memories.first.longitude!,
          )
        : const LatLng(-31.9523, 115.8613);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Map'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: centre,
          initialZoom: memories.isEmpty ? 10 : 14,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.memorylens.app',
          ),

          MarkerLayer(
            markers: memories.map((memory) {
              return Marker(
                point: LatLng(
                  memory.latitude!,
                  memory.longitude!,
                ),
                width: 50,
                height: 50,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MemoryDetailScreen(memory: memory),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.location_on,
                    size: 40,
                    color: Colors.red,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}