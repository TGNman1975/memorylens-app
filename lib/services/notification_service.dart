import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'memory_reminders';
  static const String _channelName = 'Memory Reminders';
  static const String _channelDescription =
      'Reminders for saved MemoryLens memories.';

  static void Function(int memoryId)? onNotificationTap;

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    final timezoneInfo =
        await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(
      tz.getLocation(timezoneInfo.name),
    );

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createAndroidChannel();
    await _requestPermissions();
  }

  static Future<void> _createAndroidChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> scheduleReminder({
    required int memoryId,
    required String title,
    required DateTime reminderAt,
  }) async {
    if (reminderAt.isBefore(DateTime.now())) {
      return;
    }

    final scheduledDate = tz.TZDateTime.from(
      reminderAt,
      tz.local,
    );

    await _notifications.zonedSchedule(
      memoryId,
      'MemoryLens Reminder',
      title,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle,
      payload: memoryId.toString(),
    );
  }

  static Future<void> cancelReminder(int memoryId) async {
    await _notifications.cancel(memoryId);
  }

  static void _onNotificationTapped(
    NotificationResponse response,
  ) {
    final payload = response.payload;

    if (payload == null) return;

    final memoryId = int.tryParse(payload);

    if (memoryId == null) return;

    onNotificationTap?.call(memoryId);
  }
}