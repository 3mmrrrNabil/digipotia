import 'package:digipotia/features/profile/presentation/widgets/show_point.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/service_locator.dart';
import '../cubit/profile_cubit.dart';

class Points extends StatefulWidget {
  final int points;
  final int completedBadges;

  const Points({
    super.key,
    required this.points,
    required this.completedBadges,
  });

  @override
  State<Points> createState() => _PointsState();
}

class _PointsState extends State<Points> {

  final List<Map<String, String>> badges = [
    {
      'title': 'مبتدئ',
      'subtitle': '',
      'image': 'assets/images/وسام1.png',
    },
    {
      'title': 'مساهم',
      'subtitle': '',
      'image': 'assets/images/وسام2.png',
    },
    {
      'title': 'موثوق',
      'subtitle': '',
      'image': 'assets/images/وسام3.png',
    },
    {
      'title': 'رائد',
      'subtitle': '',
      'image': 'assets/images/وسام4.png',
    },
  ];

  final List<Map<String, int>> levels = [
    {"min": 0, "max": 49},
    {"min": 50, "max": 99},
    {"min": 100, "max": 199},
    {"min": 200, "max": 499},
  ];





  int pointsToNextLevel(int points) {
    if (points < 50) {
      return 49 - points;
    } else if (points < 100) {
      return 99 - points;
    } else if (points < 200) {
      return 199 - points;
    } else if (points < 500) {
      return 499 - points;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int points = widget.points;
    final int completedBadges = widget.completedBadges;

    final int totalPointsForAllBadges = pointsToNextLevel(points);

    final currentLevel = levels.firstWhere(
          (level) => points >= level["min"]! && points <= level["max"]!,
      orElse: () => levels.last,
    );

    // المدى بتاع المستوى (مثلاً 50 أو 100 أو 300)
    final int levelRange = currentLevel["max"]! - currentLevel["min"]! + 1;

    // النقاط اللي جوا المستوى الحالي
    final int currentPointsInLevel = points - currentLevel["min"]!;

    // هنا البروجريس بيرسنت مظبوط
    final double progressPercent = currentPointsInLevel / levelRange;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 2,
        title: Text(
          'نقاطك',
          style: GoogleFonts.cairo(color: Color(0xFF4D4D4D), fontSize: 20),
        ),
        shadowColor: Colors.black,
        backgroundColor: Colors.white,
      ),
      body: ShowPoint(
        points: points,
        totalPointsForAllBadges: totalPointsForAllBadges,
        progressPercent: progressPercent,
        badges: badges,
        completedBadges: completedBadges,
      ),
    );
  }
}
