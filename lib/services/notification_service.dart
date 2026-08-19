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
      tz.getLocation(timezoneInfo.identifier),
    );

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse:
          _onNotificationTapped,
    );

    await _createAndroidChannel();

    // IMPORTANT:
    // Do not request notification/alarm permissions here.
    //
    // Permissions are requested only when the user actually
    // creates a reminder.
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
        ?.createNotificationChannel(
          channel,
        );
  }

  static Future<void> _requestPermissions() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Notification permission is requested when the user
    // actually chooses to create a reminder.
    await android?.requestNotificationsPermission();

    // Exact alarm permission is also requested only when
    // the user actually chooses to create a reminder.
    await android?.requestExactAlarmsPermission();

    final ios = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  static Future<NotificationAppLaunchDetails?>
    getNotificationAppLaunchDetails() {
    return _notifications.getNotificationAppLaunchDetails();
  }
  static Future<void> scheduleReminder({
    required int memoryId,
    required String title,
    required DateTime reminderAt,
  }) async {
    if (reminderAt.isBefore(DateTime.now())) {
      return;
    }

    // Ask for permissions at the moment the user actually
    // saves a reminder.
    await _requestPermissions();

    await cancelReminder(memoryId);

    final scheduledDate = tz.TZDateTime.from(
      reminderAt,
      tz.local,
    );

    await _notifications.zonedSchedule(
      id: memoryId,
      title: 'MemoryLens Reminder',
      body: title,
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
    await _notifications.cancel(
      id: memoryId,
    );
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