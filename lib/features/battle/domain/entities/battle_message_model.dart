import 'dart:convert';

class BattleMessageModel {
  final int battleroomId;
  final String message;
  final bool isGpt;
  final DateTime timestamp;
  final String? url;
  final String? title;
  final Map<String, dynamic>? feedback; // ✅ 피드백 추가

  BattleMessageModel({
    required this.battleroomId,
    required this.message,
    required this.isGpt,
    required this.timestamp,
    this.url,
    this.title,
    this.feedback,
  });

  factory BattleMessageModel.fromJson(Map<String, dynamic> json) {
    dynamic messageData = json['message'];
    String finalMessage = "⚠️ 메시지 처리 실패";

    try {
      // ✅ 1️⃣ `message`가 JSON 문자열이면 디코딩 시도
      if (messageData is String) {
        try {
          if (messageData.contains("{") && messageData.contains("}")) {
            print("🔍 messageData가 JSON 형식일 가능성 있음");
            String jsonString = messageData.replaceAll("'", "\"");
            messageData = jsonDecode(jsonString);
          }
        } catch (e) {
          print("⚠️ JSON 파싱 실패: $e");
          print("📌 원본 message 데이터: $messageData");
        }
      }

      // ✅ 2️⃣ 메시지 유형 구분
      bool isFeedback = messageData is Map<String, dynamic> &&
          messageData.containsKey('feedback');

      bool isArticle = messageData is Map<String, dynamic> &&
          messageData.containsKey('url') &&
          messageData.containsKey('title');

      // ✅ 3️⃣ URL 메시지 처리
      String? url = isArticle ? messageData['url'] as String? : null;
      String? title = isArticle ? messageData['title'] as String? : null;

      // ✅ 4️⃣ 최종 메시지 설정
      if (isFeedback) {
        finalMessage = "📋 AI 평가 피드백 제공됨";
      } else if (isArticle) {
        finalMessage = '📌 추천 아티클! "$title"\n🔗 $url';
      } else {
        finalMessage = messageData.toString();
      }

      return BattleMessageModel(
        battleroomId: json['quizroom'] ?? 0,
        message: finalMessage,
        isGpt: json['is_gpt'] ?? true,
        timestamp: DateTime.tryParse(json['timestamp'] ?? "") ?? DateTime.now(),
        url: url,
        title: title,
        feedback: isFeedback ? messageData['feedback'] : null,
      );
    } catch (e) {
      print("⚠️ 전체 파싱 오류 발생: $e");

      return BattleMessageModel(
        battleroomId: json['quizroom'] ?? 0,
        message: "⚠️ 메시지 처리 중 오류 발생",
        isGpt: json['is_gpt'] ?? true,
        timestamp: DateTime.now(),
      );
    }
  }
}