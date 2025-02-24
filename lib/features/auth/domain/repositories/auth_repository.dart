// 레포지토리 인터페이스
// AuthRepository는 인터페이스 역할을 함.
// loginUser() 함수가 있지만, 실제 구현 x

abstract class AuthRepository {
  // 로그인
  Future<Map<String, dynamic>> loginUser(String username, String password);

  // 회원가입
  Future<bool> registerUser({
    required String username,
    required String email,
    required String password,
    required String password2,
  });
}
