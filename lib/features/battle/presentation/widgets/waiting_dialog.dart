import 'package:flutter/material.dart';

class WaitingDialog extends StatelessWidget {
  final VoidCallback onCancel; // ✅ 취소 콜백을 BattleHomePage에서 받음

  const WaitingDialog({super.key, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("배틀 매칭 중..."),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          const Text("상대방을 찾는 중입니다..."),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel, // ✅ 취소 버튼 클릭 시 _cancelMatch() 실행
          child: const Text("취소"),
        ),
      ],
    );
  }
}
