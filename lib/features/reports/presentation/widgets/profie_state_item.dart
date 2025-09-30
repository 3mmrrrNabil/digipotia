import 'package:digipotia/core/extensions/media_query_extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class ProfileStepItem extends StatelessWidget {
  final String title;
  final String iconPath;
  final bool isActive;
  final bool isCompleted;

  const ProfileStepItem({
    super.key,
    required this.title,
    required this.iconPath,
    this.isActive = false,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isActive || isCompleted ? const Color(0xFF2563EB) : Colors.white;
    final iconColor = isActive || isCompleted ? Colors.white : const Color(0xFF2563EB);

    return Column(
      children: [
        Container(
          padding:  EdgeInsets.all(context.sp(15)),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.withOpacity(0.3), width: context.wp(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 2,
                offset: const Offset(6, 6),
              ),
            ],
          ),
          child:
              ColorFiltered(
    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
    child:
          Image.asset(
            iconPath,
            width: context.wp(5),
            height: context.hp(3),
            color:  iconColor,
          ),
        ),
    ),
        SizedBox(height: context.hp(1.5)),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: const Color(0xFF2563EB),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
