import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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


        final bool isWin = record.matchResult == "win";
        final bool isDraw = record.matchResult == "draw";

        final DateTime battleDate = DateTime.parse(record.startDate);
        final String displayDate = "${battleDate.year}.${battleDate.month.toString().padLeft(2, '0')}.${battleDate.day.toString().padLeft(2, '0')}";

        const String baseUrl = "http://192.168.219.103:8000";

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF3EEE6),
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(
                color: isWin
                    ? const Color(0xFF176560)
                    : isDraw
                    ? Colors.blueGrey
                    : Colors.redAccent,
                width: 6,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            leading: SizedBox(
              width: 40,
              height: 40,
              child: Image.asset(
                isWin
                    ? 'assets/images/logos/win.png'
                    : isDraw
                    ? 'assets/images/logos/draw.png'
                    : 'assets/images/logos/lose.png',
                fit: BoxFit.contain,
              ),
            ),
            title: Text(
              "$displayDate  |  ${record.matchResult}",
              style: GoogleFonts.bebasNeue(
                fontSize: 22,
                color: const Color(0xFF333333),
              ),
            ),
            children: [
              _buildPlayerTile(myImage, myName, myScore, baseUrl, isMe: true),
              const Divider(),
              _buildPlayerTile(opponentImage, opponentName, opponentScore, baseUrl),
            ],
          ),

        );
      },
    );
  }

  Widget _buildPlayerTile(String image, String name, int score, String baseUrl, {bool isMe = false}) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: image.isNotEmpty ? NetworkImage("$baseUrl$image") : null,
          backgroundColor: Colors.grey[300],
          child: image.isEmpty
              ? Icon(
            isMe ? Icons.person : Icons.person_outline,
            color: Colors.white,
          )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: GoogleFonts.bebasNeue(
              fontSize: 20,
              color: const Color(0xFF444444),
            ),
          ),
        ),
        Text(
          "$score점",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isMe ? const Color(0xFF176560) : Colors.black,
          ),
        ),
      ],
    );
  }
}
