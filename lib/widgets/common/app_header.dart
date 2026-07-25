import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_strings.dart';

/// Displays the MemoryLens title, tagline and a dynamic greeting.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Good Morning 👋';
    if (hour < 17) return 'Good Afternoon ☀️';
    if (hour < 21) return 'Good Evening 🌙';

    return 'Welcome Back 👋';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting(),
          style: theme.textTheme.bodyMedium,
        ),

        const SizedBox(height: AppSpacing.sm),

        Text(
          AppStrings.appName,
          style: theme.textTheme.headlineMedium,
        ),

        const SizedBox(height: AppSpacing.xs),

        Text(
          AppStrings.tagline,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}