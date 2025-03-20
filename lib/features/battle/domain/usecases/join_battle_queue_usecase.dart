import 'package:quizflow_frontend/features/battle/domain/repositories/battle_repository.dart';

class JoinBattleQueueUsecase {
  final BattleRepository repository;

  JoinBattleQueueUsecase(this.repository);

  Future<String> execute() {
    return repository.joinBattleQueue();
  }
}
