import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProblemCategoryItem extends StatelessWidget {
  final String title;
  final String description;
  final String iconPath;
  final bool isSelected;
   Color? color;

   ProblemCategoryItem({
    super.key,
    required this.title,
    this.description = "",
    required this.iconPath,
    this.isSelected = false,
    this.color
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124,
      height: 71,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2563EB) : Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 0),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF5D5D5D),
                  fontSize: 12,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 6),
              SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
                color: isSelected ? Colors.white : color,
              ),
            ],
          ),
          if (description.isNotEmpty)
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white70 : const Color(0xFF7A7A7A),
                fontSize: 8,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }
}