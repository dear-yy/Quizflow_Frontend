import 'dart:convert';

class MessageModel {
  final int quizroomId;
  final String message;
  final bool isGpt;
  final DateTime timestamp;
  final String? url;
  final String? title;
  final String? reason;
  final Map<String, dynamic>? feedback; // ✅ 피드백 추가

  MessageModel({
    required this.quizroomId,
    required this.message,
    required this.isGpt,
    required this.timestamp,
    this.url,
    this.title,
    this.reason,
    this.feedback,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    dynamic messageData = json['message'];
    String finalMessage = "⚠️ 메시지 처리 실패";
    Map<String, dynamic>? feedback;
    String? url;
    String? title;
    String? reason;

    try {
      if (messageData is String) {
        try {
          // ✅ 작은따옴표 JSON 전체를 큰따옴표 JSON으로 정확하게 변환하는 정규식
          if (messageData.startsWith("{") && messageData.endsWith("}")) {
            String correctedJson = messageData
            // 키 교체
                .replaceAllMapped(
                RegExp(r"'([^']+)'\s*:\s*"), (m) => '"${m[1]}": ')
            // 값 교체
                .replaceAllMapped(
                RegExp(r":\s*'([^']*)'"), (m) => ': "${m[1]}"');
            messageData = jsonDecode(correctedJson);

          } else {
            throw const FormatException("Not JSON");
          }
        } catch (e) {
          print("⚠️ JSON 파싱 실패, 원본 문자열로 처리: $e");
          messageData = {'raw_message': messageData};
        }
      }

      if (messageData is Map<String, dynamic>) {
        bool isFeedback = messageData.containsKey('understanding_feedback') &&
            messageData.containsKey('improvement_feedback');

        bool isArticle =
            messageData.containsKey('url') && messageData.containsKey('title');

        if (isFeedback) {
          feedback = {
            'understanding_feedback': messageData['understanding_feedback'],
            'improvement_feedback': messageData['improvement_feedback'],
          };
          finalMessage = "📋 AI 평가 피드백 제공됨";
        } else if (isArticle) {
          url = messageData['url'] as String?;
          title = messageData['title'] as String?;
          reason = messageData['reason'] as String?;
          finalMessage = '📌 추천 아티클! "$title"\n🔗 $url'
              '${reason != null ? '\n📝 추천 이유: $reason' : ''}';
        } else if (messageData.containsKey('raw_message')) {
          finalMessage = messageData['raw_message'];
        } else {
          finalMessage = messageData.toString();
        }
      } else {
        finalMessage = messageData.toString();
      }

      return MessageModel(
        quizroomId: json['quizroom'] ?? 0,
        message: finalMessage,
        isGpt: json['is_gpt'] ?? true,
        timestamp: DateTime.tryParse(json['timestamp'] ?? "") ?? DateTime.now(),
        url: url,
        title: title,
        reason: reason,
        feedback: feedback,
      );
    } catch (e) {
      print("⚠️ 전체 파싱 오류 발생: $e");
      return MessageModel(
        quizroomId: json['quizroom'] ?? 0,
        message: "⚠️ 메시지 처리 중 오류 발생",
        isGpt: json['is_gpt'] ?? true,
        timestamp: DateTime.now(),
      );
    }
  }
}
