import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quizflow_frontend/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:quizflow_frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:quizflow_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:quizflow_frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:quizflow_frontend/features/auth/presentation/screens/login_page.dart';

void main() {
  // 1️⃣ HTTP 클라이언트 생성
  final httpClient = http.Client();

  // 2️⃣ 데이터 소스 생성 (API 요청 담당)
  final AuthRemoteDataSource authRemoteDataSource = AuthRemoteDataSource(client: httpClient);

  // 3️⃣ 레포지토리 생성 (데이터 소스 활용)
  final AuthRepository authRepository = AuthRepositoryImpl(authRemoteDataSource);

  // 4️⃣ 유즈케이스 생성 (비즈니스 로직 담당)
  final LoginUseCase loginUseCase = LoginUseCase(authRepository);

  // 5️⃣ Flutter 앱 실행 (LoginPage에 유즈케이스 전달)
  runApp(MyApp(loginUseCase: loginUseCase));
}

class MyApp extends StatelessWidget {
  final LoginUseCase loginUseCase;

  const MyApp({super.key, required this.loginUseCase});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(loginUseCase: loginUseCase),
    );
  }
}

// 1. `main.dart`에서 모든 객체를 생성하고 `LoginUseCase`를 `LoginPage`로 전달
// 2. `LoginPage`에서 `_loginUser()`를 실행하면 `loginUseCase.execute()` 호출
// 3. `loginUseCase.execute()` → `authRepository.loginUser()` 호출
// 4. `authRepository.loginUser()` → `authRemoteDataSource.loginUser()` 실행
// 5. `authRemoteDataSource.loginUser()`에서 서버로 로그인 요청 전송
// 6. 응답이 돌아오면 `LoginPage`에서 UI 업데이트
