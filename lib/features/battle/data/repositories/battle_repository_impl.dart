import 'package:quizflow_frontend/features/battle/data/datasources/battle_remote_data_source.dart';
import 'package:quizflow_frontend/features/battle/domain/repositories/battle_repository.dart';

class BattleRepositoryImpl implements BattleRepository {
  final BattleRemoteDataSource remoteDataSource;

  BattleRepositoryImpl(this.remoteDataSource);

  @override
  Future<String> startBattle() => remoteDataSource.startBattle();
}
