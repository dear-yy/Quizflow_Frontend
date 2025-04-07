import 'dart:ui';

import 'package:quizflow_frontend/features/battle/domain/entities/battle_message_model.dart';
import 'package:quizflow_frontend/features/battle/domain/entities/battle_record.dart';
import 'package:quizflow_frontend/features/battle/domain/entities/battle_result.dart';

abstract class BattleRepository {

  Future<List<BattleRecord>> getBattleRooms();
  Future<String> joinBattleQueue ();
  Future<String> fetchMatchResult();
  Future<int?> fetchNewBattleRoom ();
  Future<String> cancelBattleMatch ();

  Future<void> connectWebSocket({
    required int battleroomId,
    required Function(BattleMessageModel) onNewMessage,
    required Function(String) onOpponentFinished,
    required VoidCallback onWaitForOtherPlayer,
    required VoidCallback onBothPlayersFinished,
    required Function(String) onReceiveRole,
    required VoidCallback onBattleReady,
  });

  void sendMessage(String message);

  void disconnectWebSocket();

  Future<void> sendDisconnectRequest(int battleRoomId);

  Future<BattleResult?> fetchBattleResult(int battleroomId);
}