import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  static const String _notificationEnabledKey = 'daily_checkin_notifications_enabled';
  static const String _notificationTimeKey = 'daily_checkin_notification_time';

  static Future<void> initialize() async {
    // Initialize timezone data
    tz.initializeTimeZones();

    // Android-only initialization
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for Android 13+
    await _requestAndroidPermissions();
  }

  static Future<void> _requestAndroidPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to daily check-in screen
    print('Notification tapped: ${response.payload}');
  }

  static Future<void> scheduleDailyCheckinReminder({
    int hour = 9,
    int minute = 0,
  }) async {
    await _notifications.cancel(0); // Cancel existing notification

    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'daily_checkin',
      'Daily Check-in Reminders',
      channelDescription: 'Reminders to complete your daily mood check-in',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
      autoCancel: true,
      ongoing: false,
      styleInformation: BigTextStyleInformation(
        'How are you feeling today? Take a moment to check in with yourself and track your mental wellness journey.',
      ),
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    try {
      await _notifications.zonedSchedule(
        0,
        'Daily Check-in Reminder 🌟',
        'How are you feeling today? Take a moment to check in with yourself.',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'daily_checkin',
      );
    } catch (e) {
      // Fallback to inexact scheduling if exact alarms are not permitted
      await _notifications.zonedSchedule(
        0,
        'Daily Check-in Reminder 🌟',
        'How are you feeling today? Take a moment to check in with yourself.',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'daily_checkin',
      );
    }

    // Save notification settings
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, true);
    await prefs.setString(_notificationTimeKey, '$hour:$minute');
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  static Future<void> cancelDailyCheckinReminder() async {
    await _notifications.cancel(0);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, false);
  }

  static Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationEnabledKey) ?? false;
  }

  static Future<String> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_notificationTimeKey) ?? '9:00';
  }

  static Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'instant_notifications',
      'Instant Notifications',
      channelDescription: 'Immediate notifications for app events',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
      autoCancel: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  static Future<void> scheduleCheckinCompletionReminder() async {
    // Schedule a gentle reminder 12 hours after the daily reminder if not completed
    final tz.TZDateTime reminderTime = tz.TZDateTime.now(tz.local).add(
      const Duration(hours: 12),
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'checkin_reminder',
      'Check-in Completion Reminders',
      channelDescription: 'Gentle reminders to complete missed check-ins',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      enableVibration: false,
      playSound: false,
      autoCancel: true,
      styleInformation: BigTextStyleInformation(
        'Don\'t forget to check in with yourself today. Your mental health matters! Take a few minutes to reflect on how you\'re feeling.',
      ),
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    try {
      await _notifications.zonedSchedule(
        1,
        'Gentle Reminder 💙',
        'Don\'t forget to check in with yourself today. Your mental health matters!',
        reminderTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'checkin_reminder',
      );
    } catch (e) {
      // Fallback to inexact scheduling if exact alarms are not permitted
      await _notifications.zonedSchedule(
        1,
        'Gentle Reminder 💙',
        'Don\'t forget to check in with yourself today. Your mental health matters!',
        reminderTime,
        details,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'checkin_reminder',
      );
    }
  }

  static Future<void> cancelCheckinCompletionReminder() async {
    await _notifications.cancel(1);
  }

  // Android-specific: Show test notification immediately
  static Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'test_notifications',
      'Test Notifications',
      channelDescription: 'Test notifications to verify functionality',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
      autoCancel: true,
      styleInformation: BigTextStyleInformation(
        'This is a test notification to make sure your daily check-in reminders are working properly. You can customize the time in settings.',
      ),
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      999,
      'Test Notification 🔔',
      'Your notifications are working! Daily reminders will appear like this.',
      details,
      payload: 'test_notification',
    );
  }

  // Android-specific: Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Android-specific: Get pending notifications count
  static Future<int> getPendingNotificationsCount() async {
    final pendingNotifications = await _notifications.pendingNotificationRequests();
    return pendingNotifications.length;
  }

  // Enable notifications by default on app startup (compulsory)
  static Future<void> enableDefaultNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('first_launch') ?? true;
    
    if (isFirstLaunch) {
      // Mark as not first launch anymore
      await prefs.setBool('first_launch', false);
      
      // Enable notifications by default
      await scheduleDailyCheckinReminder();
      
      // Show welcome notification
      await Future.delayed(const Duration(seconds: 2));
      await showInstantNotification(
        title: 'Welcome to SeaSmart! 🌟',
        body: 'Daily check-in reminders are now active. We\'ll remind you at 9:00 AM each day to check in with yourself.',
        payload: 'welcome',
      );
    } else {
      // For existing users, ensure notifications are still enabled if they were before
      final notificationsEnabled = await areNotificationsEnabled();
      if (notificationsEnabled) {
        final timeString = await getNotificationTime();
        final timeParts = timeString.split(':');
        final hour = int.tryParse(timeParts[0]) ?? 9;
        final minute = int.tryParse(timeParts[1]) ?? 0;
        
        await scheduleDailyCheckinReminder(hour: hour, minute: minute);
      }
    }
  }
}