import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

import '../core/routes/routes.dart'; // عدل المسار حسب مكان Routes عندك

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _QuarterArcAnimationState();
}

class _QuarterArcAnimationState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _colorController;
  late AnimationController _textController;

  int loopCount = 0;
  bool finishedRotation = false;

  @override
  void initState() {
    super.initState();

    // دوران القوس
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _rotationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        loopCount++;
        if (loopCount < 1) {
          _rotationController.forward(from: 0);
        } else {
          _rotationController.stop();
          setState(() => finishedRotation = true);
          _colorController.forward(); // يبدأ أنيميشن الخلفية
        }
      }
    });

    _rotationController.forward();

    // أنيميشن الخلفية
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _colorController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _textController.forward();
      }
    });

    // أنيميشن النص (يظهر من تحت)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // بعد ما النص يظهر → نروح للصفحة المناسبة
    _textController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await Future.delayed(const Duration(seconds: 1));
        _navigateNext();
      }
    });
  }

  Future<void> _navigateNext() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;
    final token = prefs.getString('token');

    // الملاحة لازم تحصل بعد ما الـ build يخلص
    Future.microtask(() {
      if (isFirstTime) {
        prefs.setBool('isFirstTime', false);
        Navigator.pushReplacementNamed(context, Routes.onboarding);
      } else if (token != null && token.isNotEmpty) {
        Navigator.pushReplacementNamed(context, Routes.appSection);
      } else {
        Navigator.pushReplacementNamed(context, Routes.login);
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _colorController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationController,
        _colorController,
        _textController,
      ]),
      builder: (context, _) {
        // زاوية دوران القوس
        double currentAngle =
            (_rotationController.value * 2 * math.pi) + (3 * math.pi / 6);

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: finishedRotation
                  ? RadialGradient(
                center: const Alignment(0.2, 0.2),
                radius: _colorController.value * 6,
                colors: [
                  const Color(0xFF2563EB), // الأزرق
                  Color.lerp(Colors.white, const Color(0xFF2563EB),
                      _colorController.value)!,
                ],
                stops: const [0.0, 1.0],
              )
                  : const LinearGradient(
                colors: [Colors.white, Colors.white],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // القوس + الكلمة
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: currentAngle,
                      child: SizedBox(
                        width: 220,
                        height: 220,
                        child: CircularProgressIndicator(
                          value: 0.25,
                          strokeWidth: 4,
                          color: finishedRotation
                              ? Colors.white
                              : const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    Text(
                      'عَيْنٌ',
                      style: GoogleFonts.cairo(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: finishedRotation
                            ? Colors.white
                            : const Color(0xFF2563EB),
                        shadows: [
                          Shadow(
                            blurRadius: 15,
                            color: Colors.blue.withOpacity(0.5),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // النص اللي يطلع من تحت
                FadeTransition(
                  opacity: _textController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1), // يبدأ من تحت
                      end: const Offset(0, 0), // مكانه الطبيعي
                    ).animate(CurvedAnimation(
                      parent: _textController,
                      curve: Curves.easeOut,
                    )),
                    child: Text(
                      'بلّغ… نحلّها سوا',
                      style: GoogleFonts.cairo(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
