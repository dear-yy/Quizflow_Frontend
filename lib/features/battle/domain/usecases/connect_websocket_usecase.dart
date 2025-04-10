import 'dart:ui';
import 'package:quizflow_frontend/features/battle/data/datasources/battle_web_socket_service.dart';
import 'package:quizflow_frontend/features/battle/domain/repositories/battle_repository.dart';
import 'package:quizflow_frontend/features/battle/domain/entities/battle_message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectWebSocketUseCase {
  final BattleRepository repository;
  BattleWebSocketService? _service;

  ConnectWebSocketUseCase(this.repository);

  Future<void> execute({
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

    if (token == null || userPk == null) {
      throw Exception('❌ 로그인 정보 없음 (token 또는 user_pk 없음)');
    }

    _service = BattleWebSocketService(
      battleroomId: battleroomId,
      userPk: userPk,
      token: token,
    );

    _service!.connectSetup(
      onBattleReady: onBattleReady,
      onNewMessage: onNewMessage,
      onOpponentFinished: onOpponentFinished,
      onWaitForOtherPlayer: onWaitForOtherPlayer,
      onBothPlayersFinished: onBothPlayersFinished,
      onReceiveRole: onReceiveRole,
    );
  }

  void disconnect() {
    _service?.disconnectAll();
  }

  void sendMessage(String message) {
    _service?.sendBattleMessage(message);
  }
}
