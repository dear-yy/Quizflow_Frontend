import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MemberTile extends StatelessWidget {
  final int rank;
  final String name;
  final int points;

  const MemberTile({
    super.key,
    required this.rank,
    required this.name,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF176560),
          child: Text("$rank", style: const TextStyle(color: Colors.white)),
        ),
        title: Text(name, style: GoogleFonts.bebasNeue(fontSize: 20)),
        subtitle: Text("$points points"),
      ),
    );
  }
}
