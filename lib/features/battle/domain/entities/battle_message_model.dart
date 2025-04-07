import 'dart:convert';

class BattleMessageModel {
  final int battleroomId;
  final String message;
  final bool isGpt;
  final DateTime timestamp;
  final String? url;
  final String? title;
  final bool? disconnect; // ✅ 피드백 추가

  BattleMessageModel({
    required this.battleroomId,
    required this.message,
    required this.isGpt,
    required this.timestamp,
    this.url,
    this.title,
    this.disconnect,
  });

  factory BattleMessageModel.fromJson(Map<String, dynamic> json) {
    try {
      dynamic rawMessage = json['message'];
      dynamic messageContent = json['message_content'];
      String finalMessage = "⚠️ 메시지 처리 실패";
      String? url;
      String? title;
      bool isDisconnect = json['disconnect'] ?? false;

      // ✅ 1. 우선 message_content가 존재할 경우 우선 처리
      if (messageContent != null) {
        try {
          if (messageContent is String && messageContent.contains("{")) {
            messageContent = jsonDecode(messageContent.replaceAll("'", "\""));
          }

          if (messageContent is Map<String, dynamic> && messageContent.containsKey("message")) {
            rawMessage = messageContent;
          }
        } catch (e) {
          print("⚠️ message_content 파싱 실패: $e");
        }
      }

      // ✅ 2. message 자체가 JSON 문자열일 경우 파싱
      if (rawMessage is String) {
        try {
          if (rawMessage.contains("{") && rawMessage.contains("}")) {
            rawMessage = jsonDecode(rawMessage.replaceAll("'", "\""));
          }
        } catch (e) {
          print("⚠️ message 파싱 실패: $e");
        }
      }

      print("📥 최종 처리 대상 message: $rawMessage");

      // ✅ 3. 종료 메시지 또는 아티클 판단
      if (rawMessage is Map<String, dynamic>) {
        if (rawMessage.containsKey("player_1") && rawMessage.containsKey("player_2")) {
          finalMessage = rawMessage["message"] ?? "🎯 종료 메시지 수신";
        } else if (rawMessage.containsKey("url") && rawMessage.containsKey("title")) {
          url = rawMessage["url"];
          title = rawMessage["title"];
          finalMessage = '📌 추천 아티클! "$title"\n🔗 $url';
        } else if (rawMessage.containsKey("message")) {
          finalMessage = rawMessage["message"].toString();
        } else {
          finalMessage = rawMessage.toString();
        }
      } else {
        finalMessage = rawMessage.toString();
      }

      return BattleMessageModel(
        battleroomId: json['quizroom'] ?? 0,
        message: finalMessage,
        isGpt: json['is_gpt'] ?? true,
        timestamp: DateTime.tryParse(json['timestamp'] ?? "") ?? DateTime.now(),
        url: url,
        title: title,
        disconnect: isDisconnect,
      );
    } catch (e) {
      print("❌ 전체 메시지 파싱 실패: $e");
      return BattleMessageModel(
        battleroomId: json['quizroom'] ?? 0,
        message: "⚠️ 메시지 파싱 오류 발생",
        isGpt: json['is_gpt'] ?? true,
        timestamp: DateTime.now(),
      );
    }
  }
}
