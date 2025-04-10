import 'package:flutter/material.dart';
import 'package:quizflow_frontend/features/battle/domain/entities/battle_result.dart';
import 'package:quizflow_frontend/features/battle/presentation/screens/battle_home_page.dart';

void showResultDialog(BuildContext context, BattleResult result) {
  final me = result.myRole == 1 ? result.player1 : result.player2;
  final opponent = result.myRole == 1 ? result.player2 : result.player1;

  IconData statusIcon(String status) {
    switch (status) {
      case "win":
        return Icons.emoji_events;
      case "lose":
        return Icons.cancel;
      case "draw":
      default:
        return Icons.handshake;
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case "win":
        return Colors.green;
      case "lose":
        return Colors.red;
      case "draw":
      default:
        return Colors.grey;
    }
  }

  double getBarValue(int score) {
    return (score.clamp(0, 100)) / 100.0;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(statusIcon(me.status), color: statusColor(me.status)),
          const SizedBox(width: 8),
          Text(
            me.status == "win"
                ? "승리하셨습니다!"
                : me.status == "lose"
                ? "아쉽게 패배했어요"
                : "무승부!",
            style: TextStyle(
              fontSize: 20,
              color: statusColor(me.status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPlayerCard(
            label: "당신",
            nickname: me.nickname,
            score: me.score,
            status: me.status,
            color: statusColor(me.status),
          ),
          const SizedBox(height: 16),
          _buildPlayerCard(
            label: "상대",
            nickname: opponent.nickname,
            score: opponent.score,
            status: opponent.status,
            color: statusColor(opponent.status),
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            Navigator.pop(context); // ✅ 다이얼로그 닫기
            Navigator.popUntil(context, (route) => route.isFirst);
           },
          child: const Text("홈으로 가기"),
        ),
      ],
    ),
  );
}

Widget _buildPlayerCard({
  required String label,
  required String nickname,
  required int score,
  required String status,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color, width: 1.2),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label ($nickname)", style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: (score / 100).clamp(0.0, 1.0),
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("점수: $score", style: const TextStyle(fontSize: 14)),
            Text(
              status.toUpperCase(),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
            )
          ],
        ),
      ],
    ),
  );
}
