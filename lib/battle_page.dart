import 'package:flutter/material.dart';

class BattlePage extends StatefulWidget {
  const BattlePage({super.key});

  @override
  State<BattlePage> createState() => _BattlePageState();
}

class _BattlePageState extends State<BattlePage> {
  String battleStatus = "Battle Page"; // 초기 상태 메시지

  void _startBattle() {
    setState(() {
      battleStatus = "Battle Started! ⚔️🔥";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              battleStatus,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _startBattle, // 버튼 클릭 시 배틀 시작
            child: const Text("Start Battle"),
          ),
        ],
      ),
    );
  }
}