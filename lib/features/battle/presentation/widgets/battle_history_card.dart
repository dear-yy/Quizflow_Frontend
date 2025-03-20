import 'package:flutter/material.dart';
import 'package:quizflow_frontend/features/battle/domain/entities/battle_record.dart';
import 'battle_history_card.dart';
import 'date_divider.dart';
import 'package:quizflow_frontend/features/battle/data/repositories/battle_repository_impl.dart';
import 'package:quizflow_frontend/features/battle/domain/usecases/get_battle_room_usecase.dart';
import 'package:http/http.dart' as http;

class BattleHistoryCard extends StatelessWidget {
  final BattleRecord record;

  const BattleHistoryCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    String result = (record.score1 > record.score2) ? "승리" : "패배";
    DateTime battleDate = DateTime.parse(record.startDate);
    String displayDate = "${battleDate.year}년 ${battleDate.month}월 ${battleDate.day}일 ${battleDate.hour}시 ${battleDate.minute}분";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ExpansionTile(
        title: Text("📅 $displayDate - $result"),
        children: [
          ListTile(
            leading: CircleAvatar(child: Text(record.player1[0])),
            title: Text("내 닉네임: ${record.player1}"),
            subtitle: Text("점수: ${record.score1}"),
          ),
          ListTile(
            leading: CircleAvatar(child: Text(record.player2[0])),
            title: Text("상대 닉네임: ${record.player2}"),
            subtitle: Text("점수: ${record.score2}"),
          ),
          ListTile(
            title: Text("🕒 배틀 시간: $displayDate"),
          ),
        ],
      ),
    );
  }
}