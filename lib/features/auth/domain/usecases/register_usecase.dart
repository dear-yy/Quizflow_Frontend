import 'package:quizflow_frontend/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<bool> execute({
    required String username,
    required String email,
    required String password,
    required String password2,
  }) {
    return repository.registerUser(
      username: username,
      email: email,
      password: password,
      password2: password2,
    );
  }
}
