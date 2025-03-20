import 'package:quizflow_frontend/features/battle/domain/entities/battle_record.dart';

abstract class BattleRepository {

  Future<List<BattleRecord>> getBattleRooms();
  Future<String> joinBattleQueue ();
  Future<String> fetchMatchResult();
  Future<int?> fetchNewBattleRoom ();
  Future<String> cancelBattleMatch ();
}