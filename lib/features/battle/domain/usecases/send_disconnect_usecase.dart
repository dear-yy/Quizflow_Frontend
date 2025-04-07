import 'package:quizflow_frontend/features/battle/domain/repositories/battle_repository.dart';

class SendDisconnectUseCase {
  final BattleRepository repository;

  SendDisconnectUseCase(this.repository);

  Future<void> call(int battleRoomId) async {
    await repository.sendDisconnectRequest(battleRoomId); // ✅ 전달
  }
}
