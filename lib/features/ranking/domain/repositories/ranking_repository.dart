import 'package:quizflow_frontend/features/ranking/domain/entities/ranking.dart';

abstract class RankingRepository {
  Future<RankingResponse> fetchRankingData();
}
