import 'package:quizflow_frontend/features/ranking/domain/repositories/ranking_repository.dart';

class GetRankingUseCase {
  final RankingRepository repository;

  GetRankingUseCase(this.repository);

  Future<List<String>> execute() {
    return repository.getRankings();
  }
}
