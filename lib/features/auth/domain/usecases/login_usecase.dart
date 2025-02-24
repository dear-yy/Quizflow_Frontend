// 로그인 유즈케이스
// execute() 함수에서 로그인 로직을 처리함.
// UI에서 직접 AuthRepository를 호출하는 대신, 유즈케이스를 통해 비즈니스 로직을 실행함.

import 'package:quizflow_frontend/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Map<String, dynamic>> execute(String username, String password) {
    return repository.loginUser(username, password);
  }
}
