import 'package:quizflow_frontend/features/chat/domain/repositories/chat_repository.dart';
import 'package:quizflow_frontend/features/chat/domain/entities/message_model.dart';

/// ✅ WebSocket 연결 유즈케이스
class ConnectWebSocketUseCase {
  final ChatRepository repository;

  ConnectWebSocketUseCase(this.repository);

  void execute(int quizroomId, String token, Function(MessageModel) onNewMessage) {
    repository.connectWebSocket(quizroomId, token, onNewMessage);
  }

  void sendMessage(String message) {
    repository.sendMessage(message);
  }

  void disconnect() {
    repository.disconnectWebSocket();
  }
}
