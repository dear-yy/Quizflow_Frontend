import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:quizflow_frontend/features/battle/domain/entities/battle_message_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// WebSocket을 Setup 단계 → Battle 단계까지 관리하는 통합 클래스
class BattleWebSocketService {
  final int battleroomId;
  final int userPk;
  final String token;

  // 각각의 WebSocket 채널
  WebSocketChannel? _setupChannel;
  WebSocketChannel? _battleChannel;

  bool _isBattleConnected = false;
  bool _isSetupConnected = false;

  final StreamController<dynamic> _battleStreamController = StreamController.broadcast();
  final StreamController<dynamic> _setupStreamController = StreamController.broadcast();

  Stream<dynamic> get battleStream => _battleStreamController.stream;
  Stream<dynamic> get setupStream => _setupStreamController.stream;

  BattleWebSocketService({
    required this.battleroomId,
    required this.userPk,
    required this.token,
  });

  /// Setup WebSocket 연결 및 메시지 수신 처리
  void connectSetup({
    required VoidCallback onBattleReady,
    required Function(BattleMessageModel) onNewMessage,
    required Function(String) onOpponentFinished,
    required VoidCallback onWaitForOtherPlayer,
    required VoidCallback onBothPlayersFinished,
    required Function(String) onReceiveRole,
  }) {
    if (_isSetupConnected) return;

    final url = Uri.parse("ws://192.168.219.103:8000/ws/battle/$battleroomId/");
    _setupChannel = WebSocketChannel.connect(url);

    _setupChannel!.sink.add(jsonEncode({
      "type": "auth",
      "token": token,
    }));

    _isSetupConnected = true;

    _setupChannel!.stream.listen((data) {
      final message = jsonDecode(data);
      _setupStreamController.add(message);

      if (message['type'] == 'fail') {
        print("❌ 인증 실패: \${message['message']}");
        disconnectSetup();
      } else if (message['type'] == 'system') {
        final msg = message['message'] ?? '';
        print("📡 시스템 메시지 수신: \$msg");

        if (msg.contains("설정 완료")) {
          print("🎯 설정 완료 메시지 수신. Setup 종료 후 Battle 시작");
          disconnectSetup();
          onBattleReady();

          connectBattle(
            onNewMessage: onNewMessage,
            onOpponentFinished: onOpponentFinished,
            onWaitForOtherPlayer: onWaitForOtherPlayer,
            onBothPlayersFinished: onBothPlayersFinished,
            onReceiveRole: onReceiveRole,
          );
        }
      }
    }, onError: (e) {
      print("❌ 셋업 소스 에러: \$e");
      disconnectSetup();
    }, onDone: () {
      print("🔌 Setup WebSocket Closed");
      _isSetupConnected = false;
    });
  }

  /// Battle WebSocket 연결
  void connectBattle({
    required Function(BattleMessageModel) onNewMessage,
    required Function(String opponentMessage)? onOpponentFinished,
    required VoidCallback? onWaitForOtherPlayer,
    required VoidCallback? onBothPlayersFinished,
    required Function(String)? onReceiveRole,
  }) {
    if (_isBattleConnected) return;

    final url = Uri.parse("ws://192.168.219.103:8000/ws/battle/$battleroomId/$userPk/");
    _battleChannel = WebSocketChannel.connect(url);

    _battleChannel!.sink.add(jsonEncode({
      "type": "auth"
    }));

    _isBattleConnected = true;

    _battleChannel!.stream.listen((data) {
      final decoded = jsonDecode(data);
      _battleStreamController.add(decoded);

      if (decoded["type"] == "user") {
        if (decoded.containsKey("message_content")) {
          final contentStr = decoded["message_content"];
          Map<String, dynamic> content;

          try {
            content = jsonDecode(contentStr);
          } catch (e) {
            print("⚠️ 종료 메시지 파싱 실패: \$e");
            return;
          }

          final bool isP1Done = content["player_1"] ?? false;
          final bool isP2Done = content["player_2"] ?? false;
          final int myRole = content["my_role"];
          final bool iAmDone = myRole == 1 ? isP1Done : isP2Done;
          final bool opponentDone = myRole == 1 ? isP2Done : isP1Done;

          onReceiveRole?.call(myRole == 1 ? "player_1" : "player_2");

          if (!iAmDone && opponentDone) {
            onOpponentFinished?.call("상대방이 먼저 종료되었습니다.");
          } else if (iAmDone && !opponentDone) {
            onWaitForOtherPlayer?.call();
          } else if (iAmDone && opponentDone) {
            onBothPlayersFinished?.call();
          }

          return;
        }

        try {
          final messageModel = BattleMessageModel.fromJson(decoded);
          onNewMessage(messageModel);
        } catch (e) {
          print("⚠️ GPT 메시지 파싱 실패: \$e");
        }
      }
    }, onError: (e) {
      print("❌ Battle WebSocket Error: \$e");
    }, onDone: () {
      print("🔌 Battle WebSocket Closed");
      _isBattleConnected = false;
    });
  }

  void sendBattleMessage(String message) {
    if (_isBattleConnected) {
      _battleChannel!.sink.add(jsonEncode({
        "type": "user",
        "message": message,
      }));
    } else {
      print("⚠️ Battle WebSocket not connected");
    }
  }

  void disconnectSetup() {
    print("🔌 SETUP 연결 해제");
    _setupChannel?.sink.close();
    _setupStreamController.close();
    _isSetupConnected = false;
  }

  void disconnectBattle() {
    print("🔌 BATTLE 연결 해제");
    _battleChannel?.sink.close();
    _battleStreamController.close();
    _isBattleConnected = false;
  }

  void disconnectAll() {
    disconnectSetup();
    disconnectBattle();
  }
}