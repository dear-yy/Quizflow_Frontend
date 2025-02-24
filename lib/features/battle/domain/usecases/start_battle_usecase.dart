import 'package:quizflow_frontend/features/battle/domain/repositories/battle_repository.dart';

class StartBattleUseCase {
  final BattleRepository repository;

  StartBattleUseCase(this.repository);

  Future<String> execute() {
    return repository.startBattle();
  }
}
