import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quizflow_frontend/chat_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<Map<String, dynamic>> chats = [];
  String? _errorMessage;
  bool _isLoading = false;

  Future<Map<String, dynamic>?> _getUserAuth() async {
    final prefs = await SharedPreferences.getInstance();
    int? userPk = prefs.getInt('user_pk');
    String? token = prefs.getString('token');
    if (userPk == null || token == null) {
      setState(() {
        _errorMessage = "로그인이 필요합니다.";
        _isLoading = false;
      });
      return null;
    }
    return {'userPk': userPk, 'token': token};
  }

  Future<void> _createChatRoom() async {
    try {
      var authData = await _getUserAuth();
      if (authData == null) return;
      String token = authData['token'];

      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/quizrooms/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
        body: jsonEncode({}),
      );

      String responseBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(responseBody);

      if (response.statusCode == 201) {
        int newQuizroomId = data["quizroom"]["id"];

        // 🚀 채팅방 생성 후 최신 데이터를 불러오기
        await _fetchChatRooms();

        _enterChatRoom(newQuizroomId);
      } else {
        print("❌ 채팅방 생성 실패: $responseBody");
      }
    } catch (e) {
      print("❌ 채팅방 생성 중 오류 발생: $e");
    }
  }


  Future<void> _fetchChatRooms() async {
    try {
      var authData = await _getUserAuth();
      if (authData == null) return;
      String token = authData['token'];

      final response = await http.get(
        Uri.parse("http://10.0.2.2:8000/quizrooms/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
      );

      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(responseBody);

        setState(() {
          chats = data.map((room) {
            String startDate = room["start_date"] ?? "1970-01-01T00:00:00";
            String updateDate = room["update_date"] ?? startDate;
            String date = updateDate.split("T")[0];
            String time = updateDate.split("T")[1].substring(0, 5);
            String? endDate = room["end_date"];
            int cnt = (room["cnt"] ?? 0) as int;

            return {
              "id": room["id"],
              "date": date,
              "time": time,
              "start_date": startDate,
              "update_date": updateDate,
              "end_date": endDate,
              "cnt": cnt,
            };
          }).toList();

          chats.sort((a, b) => DateTime.parse(b["update_date"]).compareTo(DateTime.parse(a["update_date"])));
        });
      } else {
        print("❌ 채팅방 목록 불러오기 실패: ${utf8.decode(response.bodyBytes)}");
      }
    } catch (e) {
      print("❌ 채팅방 목록 불러오는 중 오류 발생: $e");
    }
  }

  void _enterChatRoom(int quizroomId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(quizroomId: quizroomId),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchChatRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return GestureDetector(
                  onTap: () => _enterChatRoom(chat["id"]),
                  child: _buildChatItem(chat),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createChatRoom,
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat) {
    String subtitleText = chat["cnt"] == 0
        ? "퀴즈를 시작하세요!"
        : chat["end_date"] != null
        ? "종료 시간: ${chat["end_date"].split('T')[0]} ${chat["end_date"].split('T')[1].substring(0, 5)}"
        : "퀴즈를 계속 푸세요! ${chat["update_date"].split('T')[0]} ${chat["update_date"].split('T')[1].substring(0, 5)}";

    double progress = chat["cnt"] / 3.0;
    Color progressColor = _getProgressColor(chat["cnt"]);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        title: Text(chat["date"], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitleText),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }

  Color _getProgressColor(int cnt) {
    return [Colors.grey, Colors.yellow, Colors.orange, Colors.blue][cnt.clamp(0, 3)];
  }
}