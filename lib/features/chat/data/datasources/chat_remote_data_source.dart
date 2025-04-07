import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quizflow_frontend/features/chat/domain/entities/message_model.dart';

/// ✅ API 요청을 담당하는 데이터 소스 (채팅방 조회, 채팅방 생성, 메시지 조회)
class ChatRemoteDataSource {
  final http.Client client;

  ChatRemoteDataSource({required this.client});

  /// ✅ 채팅방 목록 조회 (서버에서 전체 채팅방을 가져옴)
  Future<List<Map<String, dynamic>>> getChatRooms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("❌ 로그인이 필요합니다.");
    }

    final url = Uri.parse("http://172.20.10.3:8000/quizrooms/");
    final response = await client.get(
      url,
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception("❌ 채팅방 목록 조회 실패: ${response.statusCode}");
    }
  }

  /// ✅ 새로운 채팅방 생성 (서버에 요청하여 방을 만듦)
  Future<int> createChatRoom() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("❌ 로그인이 필요합니다.");
    }

    final url = Uri.parse("http://172.20.10.3:8000/quizrooms/");
    final response = await client.post(
      url,
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({}),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      return responseData["quizroom"]["id"];
    } else {
      throw Exception("❌ 채팅방 생성 실패: ${response.statusCode}");
    }
  }

  /// ✅ 특정 채팅방의 메시지 조회 (서버에서 해당 방의 대화 기록을 가져옴)
  Future<List<MessageModel>> fetchMessages(int quizroomId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("❌ 로그인이 필요합니다.");
    }

    final url = Uri.parse("http://172.20.10.3:8000/quizroom/$quizroomId/message_list/");
    final response = await client.get(
      url,
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> messageList = json.decode(utf8.decode(response.bodyBytes))['messages'];
      return messageList.map((message) => MessageModel.fromJson(message)).toList();
    } else {
      throw Exception("❌ 메시지를 불러오는 중 오류 발생: ${response.statusCode}");
    }
  }
}