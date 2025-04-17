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

    // 순위 컬러 (1~3등은 특별 표시)
    Color getRankColor(int rank) {
      if (rank == 1) return const Color(0xFFFFD700); // gold
      if (rank == 2) return const Color(0xFFC0C0C0); // silver
      if (rank == 3) return const Color(0xFFCD7F32); // bronze
      return const Color(0xFFE0E0E0); // 기본 배경
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: getRankColor(info.rank ?? 0).withAlpha(25), // 0.1 = 25/255
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: getRankColor(info.rank ?? 0), width: 1),
      ),
      child: Row(
        children: [
          // 🏅 순위 표시 뱃지
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: getRankColor(info.rank ?? 0),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              "${info.rank}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // 🧑 프로필 이미지 or 이름 이니셜
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF176560),
            backgroundImage: (info.image.isNotEmpty)
                ? NetworkImage("$baseUrl${info.image}")
                : null,
            child: (info.image.isEmpty)
                ? Text(
              info.nickname[0],
              style: const TextStyle(color: Colors.white, fontSize: 18),
            )
                : null,
          ),

          const SizedBox(width: 16),

          // 📝 닉네임 & 점수
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.nickname,
                  style: GoogleFonts.bebasNeue(
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "${info.rankingScore} pts",
                  style: GoogleFonts.notoSans(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}