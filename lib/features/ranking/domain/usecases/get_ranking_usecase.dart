import 'package:quizflow_frontend/features/ranking/domain/entities/ranking.dart';
import 'package:quizflow_frontend/features/ranking/domain/repositories/ranking_repository.dart';

class GetRankingUseCase {
  final RankingRepository repository;

  GetRankingUseCase(this.repository);

  Future<RankingResponse> execute() {
    return repository.fetchRankingData();
  }
}
