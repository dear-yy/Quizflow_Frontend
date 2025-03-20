import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DateDivider extends StatelessWidget {
  final DateTime date;

  const DateDivider({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '${date.year}년 ${date.month}월 ${date.day}일',
      style: GoogleFonts.bebasNeue(
        color: Colors.black54,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),

      textAlign: TextAlign.center,
    );
  }
}
