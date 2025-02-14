import 'package:intl/intl.dart';

class MessageModel {
  final int quizroomId;
  final String message;
  final bool isGpt;
  final DateTime timestamp;

  MessageModel({
    required this.quizroomId,
    required this.message,
    required this.isGpt,
    required this.timestamp,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      quizroomId: json['quizroomId'] ?? 0,
      message: json['message'] ?? "⚠️ 서버에서 메시지를 정상적으로 받지 못했습니다.",
      isGpt: json['isGpt'] ?? true,
      timestamp: DateTime.tryParse(json['timestamp'] ?? "") ?? DateTime.now(),
    );
  }
}

List<MessageModel> parseMessages(List<dynamic> messagesJson) {
  return messagesJson.map((json) => MessageModel.fromJson(json)).toList();
}