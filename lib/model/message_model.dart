import 'package:url_launcher/url_launcher.dart'; // URL 오픈을 위해 추가
import 'dart:convert';

class MessageModel {
  final int quizroomId;
  final String message;
  final bool isGpt;
  final DateTime timestamp;
  final String? url;
  final String? title;
  final String? reason;

  MessageModel({
    required this.quizroomId,
    required this.message,
    required this.isGpt,
    required this.timestamp,
    this.url,
    this.title,
    this.reason,
  });


  factory MessageModel.fromJson(Map<String, dynamic> json) {
    dynamic messageData = json['message'];

    // ✅ message가 JSON 문자열이라면 파싱 시도
    if (messageData is String) {
      try {
        // 🚨 작은따옴표(' ')를 큰따옴표(" ")로 변환 후 jsonDecode 실행
        String jsonString = messageData.replaceAll("'", "\"");
        messageData = jsonDecode(jsonString);
      } catch (e) {
        print("⚠️ message 필드 JSON 파싱 실패: $e");
        print("📌 원본 message 데이터: $messageData");
      }
    }

    // ✅ 파싱된 데이터에서 필요한 값 추출
    String? url = messageData is Map<String, dynamic>
        ? messageData['url']
        : null;
    String? title = messageData is Map<String, dynamic>
        ? messageData['title']
        : null;
    String? reason = messageData is Map<String, dynamic>
        ? messageData['reason']
        : null;

    // ✅ 추천 아티클이 포함된 경우, message를 자동 생성
    String finalMessage = (url != null && title != null)
        ? '📌 추천 아티클! "$title"\n🔗 $url${reason != null
        ? '\n📝 추천 이유: $reason'
        : ''}'
        : (messageData is String
        ? messageData
        : "⚠️ 서버에서 메시지를 정상적으로 받지 못했습니다.");

    return MessageModel(
      quizroomId: json['quizroom'] ?? 0,
      message: finalMessage,
      // ✅ 최종 message 반영
      isGpt: json['is_gpt'] ?? true,
      timestamp: DateTime.tryParse(json['timestamp'] ?? "") ?? DateTime.now(),
      url: url,
      title: title,
      reason: reason,
    );
  }
}