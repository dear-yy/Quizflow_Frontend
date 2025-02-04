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
        print("✅ 채팅방 생성 성공: $data");

        int newQuizroomId = data["quizroom"]["id"];

        setState(() {
          chats.insert(0, {
            "id": newQuizroomId,
            "date": "날짜 없음",
            "time": "시간 없음",
            "end_date": null,
            "cnt": 0, // 새 채팅방의 진행 상태는 기본값 0
          });
        });

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
            // ✅ 날짜 변환 및 기본값 설정
            String startDate = room["start_date"] ?? "1970-01-01T00:00:00";
            String updateDate = room["update_date"] ?? startDate; // 업데이트 날짜가 없으면 start_date 사용
            String date = updateDate.split("T")[0]; // YYYY-MM-DD
            String time = updateDate.split("T")[1].substring(0, 5); // HH:MM
            String? endDate = room["end_date"];
            int cnt = (room["cnt"] ?? 0) as int; // 진행 상태 (0~3)

            return {
              "id": room["id"],
              "date": date,
              "time": time,
              "start_date": startDate, // 정렬을 위한 필드 추가
              "update_date": updateDate, // 마지막 업데이트 날짜
              "end_date": endDate,
              "cnt": cnt,
            };
          }).toList();

          // 최신 업데이트된 방이 위에 오도록 정렬 (update_date 기준 내림차순)
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
                  onTap: () {
                    int quizroomId = chat["id"];
                    _enterChatRoom(quizroomId);
                  },
                  child: _buildChatItem(chat["date"], chat["time"], chat["end_date"], chat["cnt"]),
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

  Widget _buildChatItem(String date, String time, String? endDate, int cnt) {
    String subtitleText = endDate != null
        ? "종료 시간: ${endDate.split('T')[0]} ${endDate.split('T')[1].substring(0, 5)}"
        : "퀴즈를 완료해보세요!";

    double progress = cnt / 3.0; // 진행 상태 (0.0 ~ 1.0)
    Color progressColor = _getProgressColor(cnt); // 상태에 따라 색상 변경

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        title: Row(
          children: [
            Text(
              date, // YYYY-MM-DD (update_date 기준)
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(
              time, // HH:MM (update_date 기준)
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitleText), // 종료 시간 또는 "퀴즈를 완료해보세요!"
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: progress, // 진행 상태 (0.0 ~ 1.0)
                backgroundColor: Colors.grey[300], // 배경색
                valueColor: AlwaysStoppedAnimation<Color>(progressColor), // 진행 상태 색상
                minHeight: 8,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }

  /// 진행 상태(cnt)에 따른 색상 반환
  Color _getProgressColor(int cnt) {
    switch (cnt) {
      case 1:
        return Colors.yellow;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      default:
        return Colors.grey; // 기본값 (0)
    }
  }
}