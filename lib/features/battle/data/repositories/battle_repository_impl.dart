import 'package:quizflow_frontend/features/battle/data/datasources/battle_remote_data_source.dart';
import 'package:quizflow_frontend/features/battle/domain/entities/battle_record.dart';
import 'package:quizflow_frontend/features/battle/domain/repositories/battle_repository.dart';

class BattleRepositoryImpl implements BattleRepository {
  final BattleRemoteDataSource battleRemoteDataSource;

  BattleRepositoryImpl(this.battleRemoteDataSource);

  @override
  Future<List<BattleRecord>> getBattleRooms() => battleRemoteDataSource.getBattleRooms();

  @override
  Future<String> joinBattleQueue() => battleRemoteDataSource.joinBattleQueue();

  @override
  Future<String> fetchMatchResult() => battleRemoteDataSource.fetchMatchResult();

  @override
  Future<int?> fetchNewBattleRoom() => battleRemoteDataSource.fetchNewBattleRoom();

  @override
  Future<String> cancelBattleMatch () => battleRemoteDataSource.cancelBattleMatch();
}