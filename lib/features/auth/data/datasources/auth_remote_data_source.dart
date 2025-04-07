import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSource({required this.client});

  // 로그인 API 요청
  Future<Map<String, dynamic>> loginUser(String username, String password) async {
    final url = Uri.parse("http://172.20.10.3:8000/users/login/");
    final response = await client.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("로그인 실패");
    }
  }

  // 회원가입 API 요청
  Future<bool> registerUser({
    required String username,
    required String email,
    required String password,
    required String password2,
  }) async {
    final url = Uri.parse("http://172.20.10.3:8000/users/register/");
    final response = await client.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
        "password2": password2,
        "email": email,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception("회원가입 실패");
    }
  }
}
