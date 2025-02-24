import 'package:quizflow_frontend/features/chat/domain/repositories/chat_repository.dart';

/// ✅ 채팅방 메시지 전송 유즈케이스
class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  void execute(String message) {
    repository.sendMessage(message);
  }
}
