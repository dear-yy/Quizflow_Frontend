import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RankingRemoteDataSource {
  final http.Client client;

  RankingRemoteDataSource({required this.client});

  Future<List<String>> getRankings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("로그인이 필요합니다.");
    }

    final url = Uri.parse("http://192.168.219.103:8000/rankings/");
    final response = await client.get(
      url,
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> rankings = json.decode(response.body);
      return rankings.map((ranking) => "${ranking['rank']}. ${ranking['username']} - ${ranking['score']} pts").toList();
    } else {
      throw Exception("랭킹 조회 실패: ${response.statusCode}");
    }
  }
}
