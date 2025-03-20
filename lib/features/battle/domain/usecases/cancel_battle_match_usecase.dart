import 'package:quizflow_frontend/features/battle/domain/repositories/battle_repository.dart';

class CancelBattleMatchUsecase {
  final BattleRepository repository;

  CancelBattleMatchUsecase(this.repository);

  Future<String> execute() {
    return repository.cancelBattleMatch();
  }
}
