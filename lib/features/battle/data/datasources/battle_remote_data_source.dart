import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizflow_frontend/features/battle/domain/entities/battle_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ✅ API 요청을 담당하는 데이터 소스
class BattleRemoteDataSource {
  late final http.Client client;

  BattleRemoteDataSource({required this.client});

  /// ✅ 배틀 기록 조회 (서버에서 전체 채팅방을 가져옴)
  Future<List<BattleRecord>> getBattleRooms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("❌ 로그인이 필요합니다.");
    }

    final url = Uri.parse("http://10.0.2.2:8000/battle/list/");

    try {
      final response = await client.get(
        url,
        headers: {
          "Authorization": "Token $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData.map((json) => BattleRecord.fromJson(json)).toList();
      } else {
        throw Exception("❌ 배틀 기록 조회 실패: ${response.body}");
      }
    } catch (e) {
      throw Exception("❌ 서버 오류 또는 네트워크 문제 발생: $e");
    }
  }

  /// ✅ 배틀 매치 대기 요청(배틀 대기 큐에 추가)
  Future<String> joinBattleQueue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("❌ 로그인이 필요합니다.");
    }

    final url = Uri.parse("http://10.0.2.2:8000/battle/match/");
    final response = await client.post(
      url,
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({}),
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes))['message'];
    } else {
      throw Exception("❌ 서버 응답: ${response.body}");
    }
  }

  /// ✅ 배틀 매치 결과 조회
  Future<String> fetchMatchResult() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("❌ 로그인이 필요합니다.");
    }

    final url = Uri.parse("http://10.0.2.2:8000/battle/match/");
    final response = await client.get(
      url,
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes))['message'];
    } else {
      throw Exception("❌ 서버 응답: ${response.body}");
    }
  }

  /// ✅ 새 배틀룸 조회
  Future<int?> fetchNewBattleRoom() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? userPk = prefs.getInt('user_pk');

    if (token == null) {
      throw Exception("❌ 로그인이 필요합니다.");
    }

    final url = Uri.parse("http://10.0.2.2:8000/battle/new_room/");
    final response = await client.get(
      url,
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
    );

    final responseBody = utf8.decode(response.bodyBytes);
    print("📩 서버 응답: $responseBody"); // ✅ 서버 응답 출력

    if (response.statusCode == 200) {
      final responseData = json.decode(responseBody);

      for (var room in responseData) {
        int roomId = room['id'];
        int player1 = room['player_1'];
        int player2 = room['player_2'];

        if (player1 == userPk || player2 == userPk) {
          return roomId;
        }
      }
      return null;
    } else {
      throw Exception("❌ 서버 응답: $responseBody");
    }
  }

  /// ✅ 배틀 매치 대기 취소
  Future<String> cancelBattleMatch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("❌ 로그인이 필요합니다.");
    }

    final url = Uri.parse("http://10.0.2.2:8000/battle/match/cancel/");

    try {
      final response = await client.get(
        url,
        headers: {
          "Authorization": "Token $token",
          "Content-Type": "application/json",
        },
      );

      final responseBody = utf8.decode(response.bodyBytes); // ✅ UTF-8 인코딩 유지
      print("📩 서버 응답 (취소): $responseBody"); // ✅ 서버 응답 확인

      final responseData = json.decode(responseBody);

      if (response.statusCode == 200) {
        return responseData['message'];
      } else {
        throw Exception("❌ 서버 응답: $responseBody");
      }
    } catch (e) {
      print("❌ [ERROR] 배틀 매칭 취소 중 오류 발생: $e");
      return "취소 요청 실패: $e"; // ✅ 예외 발생 시 기본 메시지 반환 (앱 크래시 방지)
    }
  }
}