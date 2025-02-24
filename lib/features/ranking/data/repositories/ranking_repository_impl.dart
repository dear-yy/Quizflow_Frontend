import 'package:quizflow_frontend/features/ranking/data/datasources/ranking_remote_data_source.dart';
import 'package:quizflow_frontend/features/ranking/domain/repositories/ranking_repository.dart';

class RankingRepositoryImpl implements RankingRepository {
  final RankingRemoteDataSource remoteDataSource;

  RankingRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<String>> getRankings() => remoteDataSource.getRankings();
}
