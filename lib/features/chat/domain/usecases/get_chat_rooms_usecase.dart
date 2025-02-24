import 'package:quizflow_frontend/features/chat/domain/repositories/chat_repository.dart';

/// ✅ 채팅방 목록 조회 유즈케이스
class GetChatRoomsUseCase {
  final ChatRepository repository;

  GetChatRoomsUseCase(this.repository);

  Future<List<Map<String, dynamic>>> execute() {
    return repository.getChatRooms();
  }
}
