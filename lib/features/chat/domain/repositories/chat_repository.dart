import 'package:quizflow_frontend/features/chat/domain/entities/message_model.dart';

/// ✅ 레포지토리 인터페이스 (추상 클래스)
/// - `ChatRepositoryImpl`에서 구현됨
abstract class ChatRepository {
  Future<List<Map<String, dynamic>>> getChatRooms();
  Future<int> createChatRoom();
  Future<List<MessageModel>> getMessages(int quizroomId);
  void connectWebSocket(int quizroomId, String token, Function(MessageModel) onNewMessage);
  void sendMessage(String message);
  void disconnectWebSocket();

}
