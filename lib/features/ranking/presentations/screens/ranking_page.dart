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
      backgroundColor: Color(0xFFFAFAFA),
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

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // ✅ Daily Score
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Daily Score",
                          style: GoogleFonts.bebasNeue(fontSize: 28, color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.bolt, color: const Color(0xFF176560), size: 28),
                              const SizedBox(width: 12),
                              Text(
                                "$todayScore점",
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 26,
                                  color: const Color(0xFF176560),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "오늘의 점수",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ✅ Monthly Ranking
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Monthly Ranking",
                          style: GoogleFonts.bebasNeue(fontSize: 26, color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircularPercentIndicator(
                                radius: 50,
                                lineWidth: 12,
                                animation: true,
                                percent: (monthlyPercent / 100).clamp(0.0, 1.0),
                                center: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${monthlyPercent.toInt()}%",
                                      style: GoogleFonts.bebasNeue(
                                        fontSize: 24,
                                        color: const Color(0xFF176560),
                                      ),
                                    ),
                                    const Text(
                                      "상위",
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
                                        text: data.myProfile.nickname,
                                        style: GoogleFonts.bebasNeue(
                                          fontSize: 20,
                                          color: const Color(0xFF176560),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(text: " 님은 이번 달 "),
                                      TextSpan(
                                        text: "${monthlyPercent.toInt()}%",
                                        style: GoogleFonts.bebasNeue(
                                          fontSize: 20,
                                          color: const Color(0xFF176560),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(text: "의 유저보다 앞서 있어요!"),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ✅ Top Users
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "Top Users",
                      style: GoogleFonts.bebasNeue(fontSize: 24, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: members.length,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemBuilder: (context, index) {
                      return MemberTile(info: members[index]);
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
