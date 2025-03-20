import 'package:quizflow_frontend/features/battle/domain/entities/battle_record.dart';
import 'package:quizflow_frontend/features/battle/domain/repositories/battle_repository.dart';

class GetBattleRoomUsecase {
  final BattleRepository repository;

  GetBattleRoomUsecase(this.repository);

  Future<List<BattleRecord>> execute() {
    return repository.getBattleRooms();
  }
}
