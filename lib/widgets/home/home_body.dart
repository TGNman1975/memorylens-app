import 'package:flutter/material.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({
    super.key,
    required this.header,
    required this.searchBar,
    required this.memoryList,
    required this.newMemoryButton,
  });

  final Widget header;
  final Widget searchBar;
  final Widget memoryList;
  final Widget newMemoryButton;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          header,
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: searchBar,
          ),

          const SizedBox(height: 12),

          Expanded(child: memoryList),

          Padding(
            padding: const EdgeInsets.all(16),
            child: newMemoryButton,
          ),
        ],
      ),
    );
  }
}