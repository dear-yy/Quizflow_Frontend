import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  late WebSocketChannel _channel;
  final int quizroomId;
  final String token;

  WebSocketService({required this.quizroomId, required this.token}) {
    String url = "ws://10.0.2.2:8000/ws/chat/$quizroomId/";
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      // ✅ 인증 메시지 전송 (일반 메시지와 구분)
      _channel.sink.add(jsonEncode({
        "type": "auth",  // 👈 인증 메시지 타입 추가
        "token": token
      }));

      print("✅ WebSocket 연결됨: $url");
    } catch (e) {
      print("❌ WebSocket 연결 실패: $e");
    }
  }

  void sendMessage(String message) {
    try {
      _channel.sink.add(jsonEncode({
        "type": "user",  // 👈 일반 채팅 메시지 타입 추가
        "message": message
      }));
    } catch (e) {
      print("❌ 메시지 전송 실패: $e");
    }
  }

  Stream get stream => _channel.stream;

  void disconnect() {
    try {
      _channel.sink.close(status.goingAway);
      print("✅ WebSocket 연결 종료");
    } catch (e) {
      print("❌ WebSocket 종료 실패: $e");
    }
  }
}
