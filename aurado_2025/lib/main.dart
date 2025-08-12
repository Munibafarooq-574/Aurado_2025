import 'package:aurado_2025/screens/forget_password1.dart';
import 'package:aurado_2025/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/preference_screen.dart';
import 'screens/screen_1.dart';
import 'task_manager.dart';
import 'providers/user_provider.dart';
import 'providers/preferences_provider.dart';

// =======================
// Notification Permission
// =======================
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

  final prefsProvider = PreferencesProvider();
  await prefsProvider.loadPreferences();

  await requestNotificationPermission();

  // Initialize timezone for notifications
  tz.initializeTimeZones();

  // Notification settings for Android
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  // Initialize the notifications plugin
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Run the app with all providers, including prefsProvider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TaskManager()),
        ChangeNotifierProvider(create: (_) => prefsProvider),
      ],
      child: const MyApp(),
    ),
  );
}

// =======================
// Main App Widget
// =======================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesProvider>(context);
    Color scaffoldBgColor = _fromHex(prefs.themeColor);


    print('scaffoldBgColor: $scaffoldBgColor');
    print('prefs.themeColor: ${prefs.themeColor}');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AuraDo',

      theme: ThemeData.light().copyWith(
        primaryColor: scaffoldBgColor,
        scaffoldBackgroundColor: scaffoldBgColor,
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff800000),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        appBarTheme: AppBarTheme(
           backgroundColor: scaffoldBgColor,  // <-- dynamic color from preferences
          elevation: 0,
          titleTextStyle: TextStyle(
            color: const Color(0xff800000).computeLuminance() > 0.5 ? Colors.black : Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: const Color(0xff800000).computeLuminance() > 0.5 ? Colors.black : Colors.white,
          ),
        ),

        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: scaffoldBgColor,
          selectedItemColor: const Color(0xff800000),
          unselectedItemColor: Colors.black,
        ),

      ),


      // Dark theme
      darkTheme: null,

      // Theme mode from PreferencesProvider
      themeMode: ThemeMode.light,

      // Navigation
      initialRoute: '/',
      routes: {
        '/': (context) => const Screen1(),
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/preferences': (context) => const PreferenceScreen(),
        '/forget_password': (context) => ForgetPasswordScreen(),
      },
    );
  }

  Color _fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
