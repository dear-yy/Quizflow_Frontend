import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Message extends StatelessWidget {
  final bool alignLeft;
  final String message;
  final DateTime timestamp;
  final bool showDateDivider; // ✅ 날짜를 표시할지 여부

  const Message({
    super.key,
    this.alignLeft = true,
    required this.message,
    required this.timestamp,
    this.showDateDivider = false, // 기본값 false
  });

  @override
  Widget build(BuildContext context) {
    final alignment = alignLeft ? Alignment.centerLeft : Alignment.centerRight;
    final bgColor = alignLeft ? const Color(0xFFF4F4F4) : Colors.blue[300]; // 사용자 메시지는 파란색
    final textColor = alignLeft ? Colors.black : Colors.white;
    final borderColor = alignLeft ? const Color(0xFFE7E7E7) : Colors.blueAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // ✅ 날짜 가운데 정렬을 위해 중앙 정렬
      children: [
        if (showDateDivider) // ✅ 각 날짜별 첫 번째 메시지에만 날짜 표시
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              formatDate(timestamp),
              style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        Row(
          mainAxisAlignment: alignLeft ? MainAxisAlignment.start : MainAxisAlignment.end, // ✅ 메시지 양 끝 정렬
          crossAxisAlignment: CrossAxisAlignment.end, // ✅ 메시지와 시간 하단 정렬
          children: [
            if (!alignLeft) // 사용자 메시지 (오른쪽 정렬 → 타임스탬프 먼저)
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Text(
                  formatTimestamp(timestamp),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: bgColor,
                  border: Border.all(color: borderColor, width: 1),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                margin: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  message.trim(),
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
              ),
            ),
            if (alignLeft) // GPT 메시지 (왼쪽 정렬 → 타임스탬프 나중에 표시)
              Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: Text(
                  formatTimestamp(timestamp),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // 날짜 포맷 함수 (ex: "2025년 2월 14일")
  String formatDate(DateTime timestamp) {
    return DateFormat('yyyy년 M월 d일').format(timestamp);
  }

  // 시간 포맷 함수 (ex: "06:56")
  String formatTimestamp(DateTime timestamp) {
    return DateFormat('HH:mm').format(timestamp);
  }
}