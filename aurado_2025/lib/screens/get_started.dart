// ignore_for_file: deprecated_member_use

import 'dart:math'; // Added for Random
import 'package:flutter/material.dart';
import 'signup_screen.dart'; // Verified import path
import '../providers/preferences_provider.dart';
import 'package:provider/provider.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> with SingleTickerProviderStateMixin {
  late AnimationController _starController;
  late Animation<double> _starAnimation;


  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Faster blinking for visibility
    )..repeat(reverse: true); // Ensures blinking effect
    _starAnimation = Tween<double>(begin: 0.0, end: 1.0).animate( // Full range for blinking
      CurvedAnimation(parent: _starController, curve: Curves.easeInOut),
    );
    _starController.forward();
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preferencesProvider = Provider.of<PreferencesProvider>(context);
    final backgroundColorHex = preferencesProvider.themeColor;
    final size = MediaQuery.of(context).size; // Get screen size dynamically
    return Scaffold(
      body: Container(
        decoration:  BoxDecoration(
          color: hexToColor(backgroundColorHex), // Matched with SplashScreen background
        ),
        child: Stack(
          children: [
            // Glowing Stars focused on top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.3, // Top 30% of 2424px = ~727px
              child: CustomPaint(
                painter: StarPainter(_starAnimation, size),
                child: Container(),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Character and task icons with error handling
                  Stack(
                    children: [
                      Image.asset(
                        'assets/character.png',
                        height: 200,
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey,
                            child: const Center(child: Text('Image Missing')),
                          );
                        },
                      ),
                      Positioned(
                        right: 50,
                        top: 50,
                        child: Icon(Icons.check_circle, color: Colors.grey, size: 40),
                      ),
                      Positioned(
                        left: 50,
                        top: 100,
                        child: Icon(Icons.check_circle, color: Colors.grey, size: 40),
                      ),
                      Positioned(
                        right: 30,
                        bottom: 50,
                        child: Icon(Icons.check_circle, color: Colors.grey, size: 40),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: const [
                        Text(
                          'Design Your Best Day',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Plan, track, and achieve your goals with clarity and peace of mind. Let\'s make every task feel like a step forward.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Get Started Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF800000),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for Glowing Stars
class StarPainter extends CustomPainter {
  final Animation<double> animation;
  final Size screenSize;

  StarPainter(this.animation, this.screenSize) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    // Generate random star positions across the top section
    final random = Random();
    final starCount = 25;
    final double topHeight = screenSize.height * 0.3;
    final List<Offset> stars = List.generate(
      starCount,
          (_) => Offset(
        random.nextDouble() * screenSize.width,
        random.nextDouble() * topHeight,
      ),
    );

    for (var star in stars) {
      final path = Path();
      const double spikeLength = 35.0;
      path.moveTo(star.dx, star.dy - spikeLength * animation.value);
      path.lineTo(star.dx + 15 * animation.value, star.dy + 15 * animation.value);
      path.lineTo(star.dx - 15 * animation.value, star.dy + 15 * animation.value);
      path.lineTo(star.dx + spikeLength * animation.value, star.dy);
      path.lineTo(star.dx, star.dy - spikeLength * animation.value);
      path.close();

      paint.color = Colors.white.withOpacity(0.98 * animation.value);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 35.0);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}