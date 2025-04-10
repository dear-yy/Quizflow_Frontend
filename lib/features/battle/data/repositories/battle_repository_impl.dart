import 'dart:ui';

import 'package:quizflow_frontend/features/battle/data/datasources/battle_remote_data_source.dart';
import 'package:quizflow_frontend/features/battle/data/datasources/battle_web_socket_service.dart';
import 'package:quizflow_frontend/features/battle/data/datasources/battle_websocket_data_source.dart';
import 'package:quizflow_frontend/features/battle/domain/entities/battle_message_model.dart';
import 'package:quizflow_frontend/features/battle/domain/entities/battle_record.dart';
import 'package:quizflow_frontend/features/battle/domain/entities/battle_result.dart';
import 'package:quizflow_frontend/features/battle/domain/repositories/battle_repository.dart';

class BattleRepositoryImpl implements BattleRepository {
  final BattleRemoteDataSource battleRemoteDataSource;
  final BattleWebSocketDataSource battleWebSocketDataSource;

  BattleRepositoryImpl(this.battleRemoteDataSource, this.battleWebSocketDataSource);

  @override
  Future<List<BattleRecord>> getBattleRooms() => battleRemoteDataSource.getBattleRooms();

  @override
  Future<String> joinBattleQueue() => battleRemoteDataSource.joinBattleQueue();

  @override
  Future<String> fetchMatchResult() => battleRemoteDataSource.fetchMatchResult();

  @override
  Future<int?> fetchNewBattleRoom() => battleRemoteDataSource.fetchNewBattleRoom();

  @override
  Future<String> cancelBattleMatch () => battleRemoteDataSource.cancelBattleMatch();

  @override
  Future<void> connectWebSocket({
    required int battleroomId,
    required Function(BattleMessageModel) onNewMessage,
    required Function(String) onOpponentFinished,
    required Function(String) onWaitForOtherPlayer,
    required Function(String) onBothPlayersFinished,
    required Function(String) onReceiveRole,
    required VoidCallback onBattleReady,
  }) {
    return battleWebSocketDataSource.connect(
      battleroomId: battleroomId,
      onNewMessage: onNewMessage,
      onOpponentFinished: onOpponentFinished,
      onWaitForOtherPlayer: onWaitForOtherPlayer,
      onBothPlayersFinished: onBothPlayersFinished,
      onReceiveRole: onReceiveRole,
      onBattleReady: onBattleReady,
    );
  }


  @override
  Future<void> sendDisconnectRequest(int battleRoomId) async {
    await battleRemoteDataSource.sendDisconnectRequest(battleRoomId); // ✅ 전달
  }

  @override
  void sendMessage(String message) {
    battleWebSocketDataSource.sendMessage(message);
  }

  @override
  void disconnectWebSocket() {
    battleWebSocketDataSource.disconnect();
  }


  Future<BattleResult?> fetchBattleResult(int battleroomId) async {
    return await battleRemoteDataSource.fetchBattleResult(battleroomId);
  }
}