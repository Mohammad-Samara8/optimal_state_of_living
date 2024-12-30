import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class CheckInNotificationPage extends StatefulWidget {
  const CheckInNotificationPage({super.key});

  @override
  CheckInNotificationPageState createState() => CheckInNotificationPageState();
}

class CheckInNotificationPageState extends State<CheckInNotificationPage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  int notificationId = 0;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    tz.initializeTimeZones();
  }

  void _initializeNotifications() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(TimeOfDay time) async {
    final now = DateTime.now();
    final scheduledTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);

    final notificationTime = scheduledTime.isBefore(now)
        ? scheduledTime.add(Duration(days: 1))
        : scheduledTime;

    final tzDateTime = tz.TZDateTime.from(notificationTime, tz.local);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'This is a notification channel for Android',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId++,
      'Reminder',
      "Don't forget to do your exercises",
      tzDateTime,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );
  }

  Future<void> _selectTimeAndScheduleNotification() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      await _showNotification(pickedTime);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Notification scheduled for ${pickedTime.format(context)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text(
            'Schedule Notification',
            style: TextStyle(color: Colors.white),
          )),
      body: Center(
        child: ElevatedButton(
          onPressed: _selectTimeAndScheduleNotification,
          child: Text('Pick Time to Receive Notification'),
        ),
      ),
    );
  }
}
