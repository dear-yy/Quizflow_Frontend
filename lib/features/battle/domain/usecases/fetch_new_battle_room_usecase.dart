import 'package:quizflow_frontend/features/battle/domain/repositories/battle_repository.dart';

class FetchNewBattleRoomUsecase {
  final BattleRepository repository;

  FetchNewBattleRoomUsecase(this.repository);

  Future<int?> execute() {
    return repository.fetchNewBattleRoom();
  }
}