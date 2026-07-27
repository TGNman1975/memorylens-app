import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Map'),
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(-31.9523, 115.8613),
          initialZoom: 10,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.memorylens.app',
          ),
        ],
      ),
    );
  }
}