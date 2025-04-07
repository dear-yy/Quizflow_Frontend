import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackCard extends StatelessWidget {
  final Map<String, dynamic> feedback;

  const FeedbackCard({Key? key, required this.feedback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFe5bdb5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            spreadRadius: 1.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 8),
              Text(
                "💡 AI 피드백",
                style: GoogleFonts.bebasNeue(
                  fontSize: 18,
                  color: const Color(0xFFe5bdb5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ✅ 피드백 출력 (한국어 변환 + 이모지 포함)
          _buildFeedbackRow("🧐 이해도 분석", feedback["understanding_feedback"]),
          _buildFeedbackRow("🚀 개선 방법", feedback["improvement_feedback"]),
        ],
      ),
    );
  }

  // ✅ 제목 스타일 적용
  Widget _buildSectionTitle(String title, bool isBold) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.bebasNeue(
          fontSize: 16,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: const Color(0xFFe5bdb5),
        ),
      ),
    );
  }

  // ✅ 개별 피드백 항목 UI 개선 (이모지 추가)
  Widget _buildFeedbackRow(String key, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.bebasNeue(fontSize: 14, color: Colors.black),
                children: [
                  TextSpan(
                    text: "$key: ",
                    style: GoogleFonts.bebasNeue(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  TextSpan(text: value.toString(), style: GoogleFonts.bebasNeue(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
