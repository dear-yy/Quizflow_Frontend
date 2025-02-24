import 'dart:async';
import 'dart:convert';
import 'package:quizflow_frontend/features/chat/domain/entities/message_model.dart';
import 'package:quizflow_frontend/features/chat/data/datasources/web_socket_service.dart';

class ChatWebSocketDataSource {
  WebSocketService? _webSocketService;
  StreamSubscription<dynamic>? _subscription;

  bool _isConnected = false; // ✅ 중복 연결 방지

  void connect(int quizroomId, String token, Function(MessageModel) onNewMessage) {
    if (_isConnected) return;

    _webSocketService = WebSocketService(quizroomId: quizroomId, token: token);
    _isConnected = true;

    _subscription = _webSocketService!.stream.listen((event) {
      try {
        final Map<String, dynamic> data = jsonDecode(event);
        final newMessage = MessageModel.fromJson(data);
        onNewMessage(newMessage);
      } catch (e) {
        print("❌ WebSocket 데이터 파싱 오류: $e");
      }
    }, onError: (error) {
      print("❌ WebSocket 오류 발생: $error");
    });
  }

  void reconnect() {
    _webSocketService?.reconnect();
  }

  void sendMessage(String message) {
    _webSocketService?.sendMessage(message);
  }

  void disconnect() {
    _subscription?.cancel();
    _webSocketService?.disconnect();
    _isConnected = false;
  }
}
