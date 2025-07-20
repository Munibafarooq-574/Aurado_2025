import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/task_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: MyApp(),
    ),
  );
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuraDo',
      theme: ThemeData.light().copyWith(
        primaryColor: Color(0xFF800000),
        cardTheme: CardThemeData( // Changed from CardTheme to CardThemeData
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        scaffoldBackgroundColor: Color(0xFFFBEEE6),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF800000),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFF9B2C2C),
        cardTheme: CardThemeData( // Changed from CardTheme to CardThemeData
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        scaffoldBackgroundColor: Color(0xFF1A1A1A),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF9B2C2C),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: HomeScreen(),
    );
  }
}