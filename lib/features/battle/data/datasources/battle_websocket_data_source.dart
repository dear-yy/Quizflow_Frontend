import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:quizflow_frontend/features/battle/data/datasources/battle_web_socket_service.dart';
import 'package:quizflow_frontend/features/battle/domain/entities/battle_message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BattleWebSocketDataSource {
  BattleWebSocketService? _webSocketService;

  StreamSubscription? _setupSubscription;
  StreamSubscription? _battleSubscription;

  bool _isBattleConnected = false;

  /// ✅ setup → battle 환동 통합
  Future<void> connect({
    required int battleroomId,
    required Function(BattleMessageModel) onNewMessage,
    required VoidCallback onBattleReady,
    required Function(String) onOpponentFinished,
    required Function(String) onWaitForOtherPlayer,
    required Function(String) onBothPlayersFinished,
    required Function(String) onReceiveRole,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userPk = prefs.getInt('user_pk');

    print("🔐 SharedPreferences - token: \$token, userPk: \$userPk");

    if (token == null || userPk == null) {
      throw Exception("❌ 로그인 정보가 없습니다.");
    }

    _webSocketService = BattleWebSocketService(
      battleroomId: battleroomId,
      userPk: userPk,
      token: token,
    );

    print("🔌 [SETUP] WebSocket 연결 시도: battleRoomId=\$battleroomId");

    _webSocketService!.connectSetup(
      onBattleReady: () {
        print("🎯 [SETUP] 배틀 준비 완료. connectBattle() 실행");
        onBattleReady();

        _webSocketService!.connectBattle(
          onNewMessage: onNewMessage,
          onOpponentFinished: onOpponentFinished,
          onWaitForOtherPlayer: onWaitForOtherPlayer,
          onBothPlayersFinished: onBothPlayersFinished,
          onReceiveRole: onReceiveRole,
        );

        print("⚔️ [BATTLE] WebSocket 연결 시작됨");
      },
      onNewMessage: (msg) {
        print("📨 [SETUP] 메시지 수신됨 (BattleMessageModel): \${msg.message}");
        onNewMessage(msg);
      },
      onOpponentFinished: (msg) {
        print("⚠️ [BATTLE] \$msg");
        onOpponentFinished(msg);
      },
      onWaitForOtherPlayer: (msg) {
        print("⏳ [BATTLE] \$msg");
        onWaitForOtherPlayer(msg);
      },
      onBothPlayersFinished: (msg) {
        print("🌟 [BATTLE] \$msg");
        onBothPlayersFinished(msg);
      },
      onReceiveRole: (role) {
        print("🧑‍🤝🧒 [BATTLE] 내 역할 수신됨: \$role");
        onReceiveRole(role);
      },
    );
  }

  void sendMessage(String message) {
    print("📤 [SEND] 메시지 전송: \$message");
    _webSocketService?.sendBattleMessage(message);
  }

  Future<void> disconnectWithServerEndDate() async {
    final prefs = await SharedPreferences.getInstance();
    final userPk = prefs.getInt('user_pk');

    if (userPk == null) return;

    print("✅ [DATASOURCE] userPk: $userPk");
    await _webSocketService?.sendDisconnectRequest(userPk);
  }

  void disconnect() {
    print("❎ [DISCONNECT] WebSocket 종료 시도");
    _setupSubscription?.cancel();
    _battleSubscription?.cancel();
    _webSocketService?.disconnectAll();
    _isBattleConnected = false;
  }
}