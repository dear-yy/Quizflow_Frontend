import 'package:quizflow_frontend/features/profile/domain/repositories/profile_repository.dart';

class DeleteAccountUseCase {
  final ProfileRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<void> execute() {
    return repository.deleteAccount();
  }
}
