import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSource({required this.client});

  // 로그인 API 요청
  Future<Map<String, dynamic>> loginUser(String username, String password) async {
    final url = Uri.parse("http://10.0.2.2:8000/users/login/");
    final response = await client.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 400) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final errorBody = json.decode(decodedBody);
      final errorMessage = (errorBody["error"] as List).join(", ");

      throw errorMessage; // 예외에 메시지 담아서 throw
    } else {
      throw Exception("로그인 실패 (알 수 없는 오류)");
    }
  }

  // 회원가입 API 요청
  Future<bool> registerUser({
    required String username,
    required String email,
    required String password,
    required String password2,
  }) async {
    final url = Uri.parse("http://10.0.2.2:8000/users/register/");
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
    } else if (response.statusCode == 400) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final errorBody = json.decode(decodedBody);
      final errorMessages = errorBody.entries
          .map((entry) => '${entry.key}: ${entry.value.join(", ")}')
          .join('\n');
      throw Exception(errorMessages);
    } else {
      throw Exception("회원가입 실패");
    }
  }
}
