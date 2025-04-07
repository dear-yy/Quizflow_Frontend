import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:quizflow_frontend/features/ranking/data/datasources/ranking_remote_data_source.dart';
import 'package:quizflow_frontend/features/ranking/domain/entities/ranking.dart';
import 'package:quizflow_frontend/features/ranking/presentations/screens/member_tile.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  late Future<RankingResponse> _rankingFuture;

  @override
  void initState() {
    super.initState();
    _rankingFuture =
        RankingRemoteDataSource(client: http.Client()).fetchRankingData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<RankingResponse>(
          future: _rankingFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("에러 발생: ${snapshot.error}"));
            } else if (!snapshot.hasData) {
              return const Center(child: Text("데이터 없음"));
            }

            final data = snapshot.data!;
            final todayScore = data.todayScore;
            final monthlyPercent = data.monthlyPercentage;
            final members = data.rankingInfo;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Daily Score 제목 추가
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "Daily Score",
                    style: GoogleFonts.bebasNeue(fontSize: 26, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 12),
                // Daily Score Container
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularPercentIndicator(
                        radius: 50,
                        lineWidth: 12,
                        animation: true,
                        percent: (todayScore / 100).clamp(0.0, 1.0),
                        center: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$todayScore",
                              style: GoogleFonts.bebasNeue(
                                fontSize: 24,
                                color: const Color(0xFF176560),
                              ),
                            ),
                            const Text(
                              "/100",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: const Color(0xFF176560),
                        backgroundColor: const Color(0xFFD1E4E2),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                            children: [
                              TextSpan(
                                text: "${data.myProfile.nickname}",
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 20,
                                  color: const Color(0xFF176560),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(text: " 님!\n"),
                              const TextSpan(text: "이번 달은 "),
                              TextSpan(
                                text: "${monthlyPercent.toInt()}%",
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 20,
                                  color: const Color(0xFF176560),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(text: "의 사람들보다 앞서 있어요!"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Top Members List
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
                          child: ListView.builder(
                            itemCount: members.length,
                            itemBuilder: (context, index) {
                              return MemberTile(info: members[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
