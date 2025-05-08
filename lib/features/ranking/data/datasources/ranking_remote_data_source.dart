import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizflow_frontend/features/ranking/domain/entities/ranking.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RankingRemoteDataSource {
  final http.Client client;

  RankingRemoteDataSource({required this.client});

  Future<RankingResponse> fetchRankingData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception("로그인이 필요합니다.");
    }

    final url = Uri.parse("http://192.168.219.103:8000/ranking/board/");
    final response = await client.get(
      url,
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return RankingResponse.fromJson(jsonBody);
    } else {
      throw Exception("랭킹 조회 실패: ${response.statusCode}");
    }
  }
}