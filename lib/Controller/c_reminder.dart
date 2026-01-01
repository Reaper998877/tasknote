import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tasknote/Model/m_reminder.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class ReminderController {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Singleton pattern to ensure one instance of the controller
  static final ReminderController _instance = ReminderController._internal();
  factory ReminderController() => _instance;
  ReminderController._internal();

  /// Initialize Notifications and Timezones
  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS/macOS settings
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _notificationsPlugin.initialize(initializationSettings);

    // Request permissions for Android 13+
    _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /// Schedule a Reminder (Not Working)
  Future<void> scheduleTaskReminder(Reminder task) async {
    if (task.reminderTime == null) return;

    await _notificationsPlugin.zonedSchedule(
      task.hashCode, // Unique ID
      task.title, // Notification Title
      task.content, // Notification Body
      tz.TZDateTime.from(task.reminderTime!, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          channelDescription: 'Channel for task reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Pin to Status Bar (Working)
  Future<void> pinTaskToStatusBar(Reminder task) async {
    // Use the text length + first characters or a fixed ID
    // to ensure the same text always targets the same notification 'slot'.
    // Using .hashCode on the String itself ensures consistency!
    int uniqueId = task.title.toLowerCase().trim().hashCode;

    await _notificationsPlugin.show(
      uniqueId,
      task.title,
      task.content,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pinned_channel',
          'Pinned Tasks',
          channelDescription: 'Channel for pinned sticky tasks',
          importance: Importance.max,
          priority: Priority.high,
          ongoing: true, // <--- THIS MAKES IT STICKY/PINNED
          autoCancel: false, // Prevents dismissal on tap
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // Not Used
  Future<void> getActiveNotifications({required String title}) async {
    int uniqueId = title.toLowerCase().trim().hashCode;
    List<ActiveNotification> list = await _notificationsPlugin
        .getActiveNotifications();

    for (var n in list) {
      if (n.id == uniqueId) await _notificationsPlugin.cancel(uniqueId);
    }
  }

  Future<bool> checkReminder({required String title}) async {
    int uniqueId = title.toLowerCase().trim().hashCode;
    List<ActiveNotification> list = await _notificationsPlugin
        .getActiveNotifications();

    for (var n in list) {
      if (n.id == uniqueId) return true;
    }
    return false;
  }
}

// IconButton(
//   icon: const Icon(Icons.delete_sweep, color: Colors.red),
//   onPressed: () {
//     _taskController.clearTask(_textController.text);
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Task cleared from status bar"))
//     );
//   },
// )
