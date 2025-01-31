import 'package:flutter/material.dart';
import 'dart:math';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  // 더미 랭킹 데이터
  List<String> rankings = [
    "1. Alice - 1500 pts",
    "2. Bob - 1400 pts",
    "3. Charlie - 1300 pts",
  ];

  // 랭킹 새로고침 기능
  void _refreshRanking() {
    setState(() {
      rankings.shuffle(); // 리스트 랜덤 섞기 (데이터가 바뀌는 느낌)
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Top Rankings",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: rankings.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text("${index + 1}"),
                  ),
                  title: Text(rankings[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _refreshRanking, // 버튼 클릭 시 랭킹 새로고침
            child: const Text("Refresh Ranking"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}