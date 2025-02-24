import 'package:quizflow_frontend/features/chat/domain/repositories/chat_repository.dart';

/// ✅ 채팅방 생성 유즈케이스
class CreateChatRoomUseCase {
  final ChatRepository repository;

  CreateChatRoomUseCase(this.repository);

  Future<int> execute() {
    return repository.createChatRoom();
  }
}
