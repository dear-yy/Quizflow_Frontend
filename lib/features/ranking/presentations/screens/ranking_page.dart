import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:quizflow_frontend/features/ranking/domain/entities/member_tile.dart';

class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 점수 퍼센트 + 설명 묶음
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFf0f0f0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircularPercentIndicator(
                    radius: 50,
                    lineWidth: 12,
                    animation: true,
                    percent: 0.73,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "73",
                          style: GoogleFonts.bebasNeue(
                            fontSize: 24,
                            color: const Color(0xFF176560),
                          ),
                        ),
                        const Text("/100", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: const Color(0xFF176560),
                    backgroundColor: const Color(0xFFd1e4e2),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      "60%의 다른 사용자보다 앞서 있어요!",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Top Members",
                      style: GoogleFonts.bebasNeue(fontSize: 22, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView(
                        children: const [
                          MemberTile(rank: 1, name: "Davis Curtis", points: 2369),
                          MemberTile(rank: 2, name: "Sinyang Park", points: 1469),
                          MemberTile(rank: 3, name: "Terry Crews", points: 1053),
                          MemberTile(rank: 4, name: "Amy Santiago", points: 990),
                          MemberTile(rank: 5, name: "Tom Hanks", points: 800),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

