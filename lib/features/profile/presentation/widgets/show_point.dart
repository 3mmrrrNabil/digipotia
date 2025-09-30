import 'package:digipotia/core/extensions/media_query_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'badge_item.dart';
class ShowPoint extends StatelessWidget {
  const ShowPoint({
    super.key,
    required this.points,
    required this.totalPointsForAllBadges,
    required this.progressPercent,
    required this.badges,
    required this.completedBadges,
  });

  final int points;
  final int totalPointsForAllBadges;
  final double progressPercent;
  final List<Map<String, String>> badges;
  final int completedBadges;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: const Color(0xFFFDFDFD),
        ),
        padding: const EdgeInsets.only(bottom: 20), // مساحة في الأسفل عند السكروول
        child: Column(
          children: [
            SizedBox(height: context.hp(5)),
            // === بطاقة النقاط ===
            Container(
              width: context.wp(88),
              height: context.hp(25),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.white,
                shadows: [
                  BoxShadow(
                    color: const Color(0x3F000000),
                    blurRadius: 4,
                    offset: const Offset(0, 0),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: context.wp(20),
                    height: context.hp(10),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/سلم.png"),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: context.hp(0.5)),
                  Text(
                    '$points نقطة',
                    style: GoogleFonts.cairo(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: context.hp(1)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'متبقي ${totalPointsForAllBadges } نقطة علي وسامك القاده',
                            style: GoogleFonts.cairo(
                              color: const Color(0xFF535353),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: context.wp(2)),
                          SvgPicture.asset(
                            "assets/svg/SparklesOutline.svg",
                            width: context.wp(3),
                            height: context.hp(3),
                          ),
                        ],
                      ),
                      SizedBox(height: context.hp(1)),
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: context.hp(1.7),
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              color: Colors.white,
                              shadows: [
                                BoxShadow(
                                  color: const Color(0x3F000000),
                                  blurRadius: 4,
                                  offset: const Offset(0, 0),
                                )
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: context.wp(88) * progressPercent,
                              height: context.hp(1.7),
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                color: const Color(0x9EFFF712),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: context.hp(3)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 27),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'الأوسمه المحققه',
                        style: GoogleFonts.cairo(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.hp(3)),
                  Column(
                    children: badges.asMap().entries.map((entry) {
                      int idx = entry.key;
                      Map<String, String> badge = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: BadgeItem(
                          index: idx,
                          activeIndex: completedBadges,
                          title: badge['title']!,
                          subtitle: badge['subtitle']!,
                          imagePath: badge['image']!,
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
