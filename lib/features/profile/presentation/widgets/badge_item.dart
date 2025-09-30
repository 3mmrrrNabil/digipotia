import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class BadgeItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final int index; // ترتيب البادج
  final int activeIndex; // الرقم المدخل يحدد أي بادجات ملونة
  final Color activeColor;
  final Color inactiveColor;
  final Color borderColor;

  const BadgeItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.index,
    required this.activeIndex,
    this.activeColor = const Color(0xFFE8FFEE),
    this.inactiveColor = Colors.white,
    this.borderColor =  Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    double wp(double percent) => MediaQuery.of(context).size.width * percent / 100;
    double hp(double percent) => MediaQuery.of(context).size.height * percent / 100;

    bool isActive = index < activeIndex; // اللون الطبيعي
    bool isNext = index == activeIndex; // الأبيض مع حد

    return Container(
      width: wp(100),
      height: hp(8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),

      decoration: ShapeDecoration(
        shadows: [

      isActive?BoxShadow():
      BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2
              ,offset: Offset(0, 5)
          )

        ],
        color: isActive
            ? activeColor
            : isNext
            ? inactiveColor
            : inactiveColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: isActive ? BorderSide(color: borderColor,  width: 0.5) : BorderSide.none,


        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(imagePath),
              SizedBox(width: wp(2)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: hp(0.8)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF747474),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Icon(
            isActive ? Icons.check_circle_outline : Icons.lock_outlined,
            color: isActive ? const Color(0xFF48BB78) : Colors.grey,
          ),
        ],
      ),
    );
  }
}

