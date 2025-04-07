import 'package:quizflow_frontend/features/battle/domain/entities/battle_result.dart';
import 'package:quizflow_frontend/features/battle/domain/repositories/battle_repository.dart';

class FetchBattleResultUseCase {
  final BattleRepository repository;

  FetchBattleResultUseCase(this.repository);

  Future<BattleResult?> call(int battleroomId) async {
    return await repository.fetchBattleResult(battleroomId);
  }
}
