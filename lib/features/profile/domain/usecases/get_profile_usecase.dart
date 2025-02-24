import 'package:quizflow_frontend/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<Map<String, dynamic>> execute() {
    return repository.getProfile();
  }
}
