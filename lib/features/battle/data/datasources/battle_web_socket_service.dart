import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:quizflow_frontend/features/battle/domain/entities/battle_message_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

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
    required Function(String) onWaitForOtherPlayer,
    required Function(String) onBothPlayersFinished,
    required Function(String) onReceiveRole,
  }) {
    if (_isSetupConnected) return;

    final url = Uri.parse("ws://10.0.2.2:8000/ws/battle/$battleroomId/");
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
        print("❌ 인증 실패: ${message['message']}");
        disconnectSetup();
      } else if (message['type'] == 'system') {
        final msg = message['message'] ?? '';
        print("📡 시스템 메시지 수신: $msg");

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
    required Function(String)? onOpponentFinished,
    required Function(String)? onWaitForOtherPlayer,
    required Function(String)? onBothPlayersFinished,
    required Function(String)? onReceiveRole,
  }) {
    if (_isBattleConnected) return;

    final url = Uri.parse("ws://10.0.2.2:8000/ws/battle/$battleroomId/$userPk/");
    _battleChannel = WebSocketChannel.connect(url);

    _battleChannel!.sink.add(jsonEncode({
      "type": "auth"
    }));

    _isBattleConnected = true;

    _battleChannel!.stream.listen((data) {
      final decoded = jsonDecode(data);
      _battleStreamController.add(decoded);

      if (decoded["type"] == "user") {
        try {
          final messageModel = BattleMessageModel.fromJson(decoded);
          onNewMessage(messageModel);
        } catch (e) {
          print("⚠️ GPT 메시지 파싱 실패: $e");
        }
      }

      if (decoded["type"] == "system") {
        /// disconnect 확인용
        if (decoded.containsKey("is_opponent_ended") && decoded.containsKey("am_i_ended")) {
          print('🔍 disconnect 변동 존재!!! \n $decoded)');

          try {
            final bool amIEnded = decoded["am_i_ended"] ?? false;
            final bool isOpponentEnded = decoded["is_opponent_ended"] ?? false;

            print("🔎 종료 상태 확인 → 나: $amIEnded / 상대: $isOpponentEnded");

            String msg = "";

            if (isOpponentEnded && !amIEnded) {
              msg = "상대 플레이어가 배틀퀴즈를 완료하였습니다.";
              if (onOpponentFinished != null) {
                print("📨 onOpponentFinished 콜백 존재함 → 메시지 전달: $msg");
                onOpponentFinished(msg);
              } else {
                print("⚠️ onOpponentFinished 콜백이 null입니다.");
              }
            } else if (!isOpponentEnded && amIEnded) {
              msg = "상대 플레이어가 배틀퀴즈를 완료하지 못했습니다. 잠시만 대기해주세요.";
              if (onWaitForOtherPlayer != null) {
                print("📨 onWaitForOtherPlayer 콜백 존재함 → 메시지 전달: $msg");
                onWaitForOtherPlayer(msg);
              } else {
                print("⚠️ onWaitForOtherPlayer 콜백이 null입니다.");
              }
            } else if (isOpponentEnded && amIEnded) {
              msg = "두 플레이어 모두 배틀 퀴즈를 종료하였습니다. 잠시 후 결과창이 표시됩니다.";
              if (onBothPlayersFinished != null) {
                print("📨 onBothPlayersFinished 콜백 존재함 → 메시지 전달: $msg");
                onBothPlayersFinished(msg);
              } else {
                print("⚠️ onBothPlayersFinished 콜백이 null입니다.");
              }
            } else {
              print("ℹ️ 아무도 아직 끝나지 않은 상태입니다.");
            }
          } catch (e) {
            print("❌ 종료 메시지 처리 중 오류 발생: $e");
            print("📦 전체 메시지: $decoded");
          }

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

  Future<void> sendDisconnectRequest(int userPk) async {
    final url = Uri.parse("http://10.0.2.2:8000/battle/$battleroomId/disconnect/");
    final now = DateTime.now().toUtc().toIso8601String();

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_pk": userPk,
          "end_date": now,
        }),
      );
      print("📤 disconnect 요청 완료: ${response.statusCode}");
    } catch (e) {
      print("❌ disconnect 요청 실패: $e");
    }
  }

  void disconnectAll() {
    disconnectSetup();
    disconnectBattle();
  }
}