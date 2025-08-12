import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'splash_screen.dart';
import '../constants/ color_utils.dart';
import '../providers/preferences_provider.dart';

class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _gradientAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _logoFadeAnimation;

  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _logoFadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    Timer(const Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preferencesProvider = Provider.of<PreferencesProvider>(context);
    final backgroundColorHex = preferencesProvider.themeColor;
    final themeColor = hexToColor(backgroundColorHex);
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(const Color(0xFF800000), themeColor, _gradientAnimation.value)!,
                  Color.lerp(const Color(0xFF800000), themeColor, _gradientAnimation.value)!,
                ],
              ),
            ),
            child: Center(
              child: FadeTransition(
                opacity: _logoFadeAnimation,
                child: SlideTransition(
                  position: _logoSlideAnimation,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: hexToColor(backgroundColorHex),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}