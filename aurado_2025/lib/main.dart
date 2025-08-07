import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'screens/home_screen.dart'; // Adjust to your dashboard or home screen
import 'task_manager.dart';

// Notification permission request
Future<void> requestNotificationPermission() async {
  final status = await Permission.notification.status;
  if (status.isDenied || status.isPermanentlyDenied) {
    await Permission.notification.request();
  }
}

// Global notification plugin instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestNotificationPermission();

  // Initialize timezone for scheduling notifications
  tz.initializeTimeZones();

  // Notification settings for Android
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  // Initialize the notifications plugin
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Run the app wrapped with ChangeNotifierProvider for TaskManager
  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskManager(),
      child: const MyApp(),
    ),
  );
}

// Main App widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuraDo',
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFF800000),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFFFBEEE6),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF800000),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFBEEE6),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF9B2C2C),
        cardTheme: CardThemeData(
          color: Colors.grey[900],
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9B2C2C),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(), // Use HomeScreen or TodayScreen as needed
    );
  }
}