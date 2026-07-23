import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

              Text(
                "Focus on what matters.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade400,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                decoration: InputDecoration(
                  hintText: "Search your memories...",
                  prefixIcon: const Icon(Icons.search),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text(
                    "Capture Memory",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "Recent Memories",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 18),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.key),
                  title: const Text("Spare House Key"),
                  subtitle: const Text("Garage cupboard"),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: const Text("Parked Car"),
                  subtitle: const Text("Level 3 • Bay 27"),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.book),
                  title: const Text("Passport"),
                  subtitle: const Text("Bedroom safe"),
                ),
              ),

              const Spacer(),

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