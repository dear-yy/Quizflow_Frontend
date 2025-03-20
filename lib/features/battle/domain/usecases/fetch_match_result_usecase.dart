import 'package:quizflow_frontend/features/battle/domain/repositories/battle_repository.dart';

class FetchMatchResultUsecase {
  final BattleRepository repository;

  FetchMatchResultUsecase(this.repository);

  Future<String> execute() {
    return repository.fetchMatchResult();
  }
}
