import 'package:quizflow_frontend/features/profile/domain/repositories/profile_repository.dart';

class UpdateNicknameUseCase {
  final ProfileRepository repository;

  UpdateNicknameUseCase(this.repository);

  Future<void> execute(String newNickname) {
    return repository.updateNickname(newNickname);
  }
}
