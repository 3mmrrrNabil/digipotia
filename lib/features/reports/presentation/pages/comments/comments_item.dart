import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentItem extends StatelessWidget {
  final String userName;
  final String content;
  final String createdAt;

  const CommentItem({
    super.key,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ صورة البروفايل
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 10),
          // ✅ تفاصيل الكومنت
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName,
                    style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(height: 4),
                Text(content,
                    style: GoogleFonts.cairo(
                        fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(createdAt,
                    style: GoogleFonts.cairo(
                        fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
