import 'package:digipotia/auth/presentation/view/login.dart';
import 'package:digipotia/features/reports/presentation/pages/feed_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../features/app_section/app_section.dart';
import '../home/home_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int currentIndex = 0;

  final List<Map<String, dynamic>> pages = [
    {
      "icon": Icons.add,
      "iconColor": Colors.blue,
      "title": "أنشئ بلاغ بسهولة",
      "subtitle":
      "أرسل بلاغ عن أي مشكلة في محيطك مع تحديد الموقع بدقة وإرفاق الصور أو الفيديو.",
    },
    {
      "icon": Icons.edit,
      "iconColor": Colors.orange,
      "title": "اختر نوع البلاغ",
      "subtitle":
      "أمني، سلامة مروري، بيئي أو غيره... التطبيق يوجه بلاغك للجهة المناسبة فوراً.",
    },
    {
      "icon": Icons.show_chart,
      "iconColor": Colors.amber,
      "title": "شارك في الحل واكسب ثقة",
      "subtitle":
      "ساهم في مساعدة الآخرين، حل المشكلات المجتمعية واكسب نقاط ثقة وشارات تميزك.",
    },
  ];

  void nextPage() {
    if (currentIndex < pages.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = pages[currentIndex];

    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    // مقاسات Responsive
    double cardHeight = height * 0.35;
    double cardWidth = width * 0.85;
    double iconSize = width * 0.12;
    double titleFontSize = width * 0.05;
    double subtitleFontSize = width * 0.04;
    double buttonWidth = width * 0.85;
    double buttonHeight = height * 0.06;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // زر تخطي
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(width * 0.04),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: Text(
                    "تخطي",
                    style: TextStyle(
                      fontSize: width * 0.04,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                      decorationThickness: 1.5,
                      decorationColor: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // AnimatedSwitcher للمحتوى
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.2, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: SizedBox(
                      key: ValueKey<int>(currentIndex),
                      height: cardHeight,
                      width: cardWidth,
                      child: Card(
                        color: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(width * 0.06),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                page["icon"],
                                size: iconSize,
                                color: page["iconColor"],
                              ),
                              SizedBox(height: height * 0.02),
                              Text(
                                page["title"],
                                style: GoogleFonts.cairo(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: height * 0.015),
                              Text(
                                page["subtitle"],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cairo(
                                  fontSize: subtitleFontSize,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // زر التالي
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: height * 0.03, top: height * 0.04),
                    child: ElevatedButton(
                      onPressed: nextPage,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(buttonWidth, buttonHeight),
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "التالي",
                        style: GoogleFonts.poppins(
                          fontSize: width * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // الـ Dots مع أنيميشن
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: height * 0.025),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        pages.length,
                            (index) {
                          bool isActive = currentIndex == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(
                                horizontal: width * 0.015),
                            width: isActive ? width * 0.05 : width * 0.025,
                            height: height * 0.012,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.blue
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                          );
                        },
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
