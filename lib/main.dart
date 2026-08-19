import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'database/app_database.dart';
import 'providers/memory_provider.dart';
import 'repositories/memory_repository.dart';
import 'screens/home_screen.dart';
import 'screens/memory_detail_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();

  NotificationService.onNotificationTap = _openMemoryFromNotification;

  final launchDetails =
      await NotificationService.getNotificationAppLaunchDetails();

  final launchedMemoryId =
      launchDetails?.didNotificationLaunchApp == true
          ? int.tryParse(
              launchDetails?.notificationResponse?.payload ?? '',
            )
          : null;

  final database = AppDatabase();
  final repository = MemoryRepository(database);

  runApp(
    ChangeNotifierProvider(
      create: (_) => MemoryProvider(repository)..loadMemories(),
      child: MemoryLensApp(
        initialMemoryId: launchedMemoryId,
      ),
    ),
  );
}

void _openMemoryFromNotification(int memoryId) {
  final context = navigatorKey.currentContext;

  if (context == null) return;

  final provider = context.read<MemoryProvider>();

  Memory? memory;

  for (final item in provider.memories) {
    if (item.id == memoryId) {
      memory = item;
      break;
    }
  }

  if (memory == null) return;

  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (_) => MemoryDetailScreen(
        memory: memory!,
      ),
    ),
  );
}

class MemoryLensApp extends StatefulWidget {
  const MemoryLensApp({
    super.key,
    this.initialMemoryId,
  });

  final int? initialMemoryId;

  @override
  State<MemoryLensApp> createState() => _MemoryLensAppState();
}

class _MemoryLensAppState extends State<MemoryLensApp> {
  bool _openedInitialMemory = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_openedInitialMemory) return;

    final memoryId = widget.initialMemoryId;

    if (memoryId == null) {
      _openedInitialMemory = true;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _openedInitialMemory = true;
      _openMemoryFromNotification(memoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'MemoryLens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}