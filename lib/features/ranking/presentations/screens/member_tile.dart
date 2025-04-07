import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/ranking.dart';

class MemberTile extends StatelessWidget {
  final Profile info;

  const MemberTile({
    super.key,
    required this.info,
  });


  @override
  Widget build(BuildContext context) {
    const String baseUrl = "http://172.20.10.3:8000";

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF176560),
          backgroundImage: (info.image.isNotEmpty)
              ? NetworkImage("$baseUrl${info.image}")
              : null,
          child: (info.image.isEmpty)
              ? Text(
            "${info.rankingScore}",
            style: const TextStyle(color: Colors.white),
          )
              : null,
        ),
        title: Text(info.nickname, style: GoogleFonts.bebasNeue(fontSize: 20)),
        subtitle: Text("${info.rankingScore} pts"),
      ),
    );
  }
}
