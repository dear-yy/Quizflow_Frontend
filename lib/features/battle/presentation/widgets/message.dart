import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Message extends StatelessWidget {
  final bool alignLeft;
  final String message;
  final DateTime timestamp;
  final bool showDateDivider;

  const Message({
    super.key,
    this.alignLeft = true,
    required this.message,
    required this.timestamp,
    this.showDateDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = alignLeft ? Alignment.centerLeft : Alignment.centerRight;
    final bgColor = alignLeft ? const Color(0xFFF4F4F4) : const Color(0xFF176560);
    final textColor = alignLeft ? Colors.black : Colors.white;
    final borderColor = alignLeft ? const Color(0xFFF4F4F4) : const Color(0xFF176560);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showDateDivider)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              formatDate(timestamp),
              style: GoogleFonts.bebasNeue(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Row(
          mainAxisAlignment: alignLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!alignLeft)
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Text(
                  formatTimestamp(timestamp),
                  style: GoogleFonts.bebasNeue(color: Colors.grey, fontSize: 12),
                ),
              ),
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: bgColor,
                  border: Border.all(color: borderColor, width: 1),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                margin: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  message.trim(),
                  style: GoogleFonts.bebasNeue(color: textColor, fontSize: 16),
                ),
              ),
            ),
            if (alignLeft)
              Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: Text(
                  formatTimestamp(timestamp),
                  style: GoogleFonts.bebasNeue(color: Colors.grey, fontSize: 12),
                ),
              ),
          ],
        ),
      ],
    );
  }

  String formatDate(DateTime timestamp) {
    return DateFormat('yyyy년 M월 d일').format(timestamp);
  }

  String formatTimestamp(DateTime timestamp) {
    return DateFormat('HH:mm').format(timestamp);
  }
}
