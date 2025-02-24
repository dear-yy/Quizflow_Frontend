import 'package:quizflow_frontend/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:quizflow_frontend/features/chat/data/datasources/chat_websocket_data_source.dart';
import 'package:quizflow_frontend/features/chat/domain/repositories/chat_repository.dart';
import 'package:quizflow_frontend/features/chat/domain/entities/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatWebSocketDataSource webSocketDataSource;

  ChatRepositoryImpl(this.remoteDataSource, this.webSocketDataSource);

  @override
  Future<List<Map<String, dynamic>>> getChatRooms() => remoteDataSource.getChatRooms();

  @override
  Future<int> createChatRoom() => remoteDataSource.createChatRoom();

  @override
  Future<List<MessageModel>> getMessages(int quizroomId) => remoteDataSource.fetchMessages(quizroomId);

  @override
  void connectWebSocket(int quizroomId, String token, Function(MessageModel) onNewMessage) {
    webSocketDataSource.connect(quizroomId, token, onNewMessage);
  }

  @override
  void sendMessage(String message) {
    webSocketDataSource.sendMessage(message);
  }

  @override
  void disconnectWebSocket() {
    webSocketDataSource.disconnect();
  }
}
