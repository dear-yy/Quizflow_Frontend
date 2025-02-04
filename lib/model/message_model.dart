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

  // API 응답 JSON을 MessageModel로 변환하는 팩토리 메서드
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      quizroomId: json["quizroom"] ?? 0,
      message: json["message"] ?? "",
      isGpt: json["is_gpt"] ?? false,
      timestamp: DateTime.parse(json["timestamp"]),
    );
  }
}

List<MessageModel> parseMessages(List<dynamic> messagesJson) {
  return messagesJson.map((json) => MessageModel.fromJson(json)).toList();
}
