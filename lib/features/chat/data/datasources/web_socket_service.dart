import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  late WebSocketChannel _channel;
  final int quizroomId;
  final String token;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  final StreamController<dynamic> _streamController = StreamController.broadcast();

  WebSocketService({required this.quizroomId, required this.token}) {
    _connect();
  }

  void _connect() {
    if (_isConnected) return; // ✅ 중복 연결 방지

    String url = "ws://172.20.10.3:8000/ws/chat/$quizroomId/";
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _channel.sink.add(jsonEncode({
        "type": "auth",
        "token": token
      }));

      _isConnected = true;
      print("✅ WebSocket 연결됨: $url");

      _channel.stream.listen((data) {
        _streamController.add(data);
      }, onError: (error) {
        print("❌ WebSocket 오류 발생: $error");
        _isConnected = false;
      }, onDone: () {
        print("✅ WebSocket 연결 종료됨");
        _isConnected = false;
      });
    } catch (e) {
      _isConnected = false;
      print("❌ WebSocket 연결 실패: $e");
    }
  }

  void reconnect() {
    disconnect();
    Future.delayed(const Duration(milliseconds: 500), _connect); // ✅ 재연결 시 딜레이 추가
  }

  void sendMessage(String message) {
    if (_isConnected) {
      try {
        _channel.sink.add(jsonEncode({
          "type": "user",
          "message": message
        }));
      } catch (e) {
        print("❌ 메시지 전송 실패: $e");
      }
    } else {
      print("⚠️ WebSocket이 연결되어 있지 않습니다. 메시지를 전송할 수 없습니다.");
    }
  }

  Stream<dynamic> get stream => _streamController.stream;

  void disconnect() {
    try {
      _channel.sink.close(status.goingAway);
      _isConnected = false;
      _streamController.close();
      print("✅ WebSocket 연결 종료");
    } catch (e) {
      print("❌ WebSocket 종료 실패: $e");
    }
  }
}
