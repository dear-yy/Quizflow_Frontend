// 레포지토리 구현체
// AuthRemoteDataSource를 사용해서 로그인 요청을 보냄.
// AuthRepository 인터페이스를 구현한 클래스임.
// UI에서 직접 API 요청을 하지 않고, 레포지토리를 통해 데이터를 가져오게 됨.

import 'package:quizflow_frontend/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:quizflow_frontend/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);
  
  // 로그인
  @override
  Future<Map<String, dynamic>> loginUser(String username, String password) {
    return remoteDataSource.loginUser(username, password);
  }

  // 회원가입 
  @override
  Future<bool> registerUser({
    required String username,
    required String email,
    required String password,
    required String password2,
  }) {
    return remoteDataSource.registerUser(
      username: username,
      email: email,
      password: password,
      password2: password2,
    );
  }
}

