import 'package:quizflow_frontend/features/chat/domain/repositories/chat_repository.dart';
import 'package:quizflow_frontend/features/chat/domain/entities/message_model.dart';

/// ✅ 채팅방 메시지 조회 유즈케이스
class GetMessagesUseCase {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  Future<List<MessageModel>> execute(int quizroomId) {
    return repository.getMessages(quizroomId);
  }
}
