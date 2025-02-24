import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BattleRemoteDataSource {
  final http.Client client;

  BattleRemoteDataSource({required this.client});

  Future<String> startBattle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("로그인이 필요합니다.");
    }

    final url = Uri.parse("http://10.0.2.2:8000/battle/start/");
    final response = await client.post(
      url,
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['message']; // 배틀 시작 메시지 반환
    } else {
      throw Exception("배틀 시작 실패: ${response.statusCode}");
    }
  }
}
