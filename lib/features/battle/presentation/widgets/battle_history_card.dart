import 'package:flutter/material.dart';
import 'package:quizflow_frontend/features/battle/domain/entities/battle_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BattleHistoryCard extends StatelessWidget {
  final BattleRecord record;

  const BattleHistoryCard({super.key, required this.record});

  Future<int?> _getUserPk() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_pk');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: _getUserPk(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Text('유저 정보를 불러올 수 없습니다.'));
        }

        final int userPk = snapshot.data!;

        final bool isPlayer1 = record.playerId1 == userPk;

        final String myName = isPlayer1 ? record.player1 : record.player2;
        final String opponentName = isPlayer1 ? record.player2 : record.player1;
        final String myImage = isPlayer1 ? record.image1 : record.image2;
        final String opponentImage = isPlayer1 ? record.image2 : record.image1;
        final int myScore = isPlayer1 ? record.score1 : record.score2;
        final int opponentScore = isPlayer1 ? record.score2 : record.score1;

        final bool isWin = record.matchResult == "승리";
        final bool isDraw = record.matchResult == "무승부";

        final DateTime battleDate = DateTime.parse(record.startDate);
        final String displayDate = "${battleDate.year}.${battleDate.month.toString().padLeft(2, '0')}.${battleDate.day.toString().padLeft(2, '0')}";

        const String baseUrl = "http://172.20.10.3:8000";

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            leading: Icon(
              isWin
                  ? Icons.emoji_events
                  : isDraw
                  ? Icons.handshake
                  : Icons.sentiment_dissatisfied,
              color: isWin
                  ? Colors.green
                  : isDraw
                  ? Colors.blue
                  : Colors.red,
            ),
            title: Text(
              "$displayDate - ${record.matchResult}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            childrenPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: myImage.isNotEmpty ? NetworkImage("$baseUrl$myImage") : null,
                  backgroundColor: Colors.grey[300],
                  child: myImage.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                ),
                title: Text(myName, style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: Text(myScore.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: opponentImage.isNotEmpty ? NetworkImage("$baseUrl$opponentImage") : null,
                  backgroundColor: Colors.grey[300],
                  child: opponentImage.isEmpty ? const Icon(Icons.person_outline, color: Colors.white) : null,
                ),
                title: Text(opponentName, style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: Text(opponentScore.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }
}