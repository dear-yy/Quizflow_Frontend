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

  static Map<String, dynamic>? tryFixAndDecode(String input) {
    try {
      // 이미 올바른 JSON이면 그대로 파싱
      return jsonDecode(input);
    } catch (_) {
      try {
        // 작은따옴표 → 큰따옴표로 수정
        final corrected = input
            .replaceAllMapped(RegExp(r"'([^']+)'\s*:"), (m) => '"${m[1]}":')
            .replaceAllMapped(RegExp(r":\s*'([^']*)'"), (m) => ': "${m[1]}"');
        return jsonDecode(corrected);
      } catch (e) {
        print("⚠️ JSON 보정 실패: $e");
        return null;
      }
    }
  }

  factory BattleMessageModel.fromJson(Map<String, dynamic> json) {
    try {
      dynamic rawMessage = json['message'];
      dynamic messageContent = json['message_content'];
      String finalMessage = "⚠️ 메시지 처리 실패";
      String? url;
      String? title;
      bool isDisconnect = json['disconnect'] ?? false;

      // ✅ message_content 우선 처리
      if (messageContent is String && messageContent.contains("{")) {
        messageContent = tryFixAndDecode(messageContent) ?? messageContent;
      }

      if (messageContent is Map<String, dynamic> && messageContent.containsKey("message")) {
        rawMessage = messageContent;
      }

      // ✅ message가 문자열 JSON일 경우
      if (rawMessage is String && rawMessage.contains("{")) {
        rawMessage = tryFixAndDecode(rawMessage) ?? rawMessage;
      }

      // ✅ 최종 분기 처리
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
