import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // 채팅 목록 (동적으로 변경 가능)
  List<Map<String, String>> chats = [
    {"date": "2025.01.31", "time": "12:30"},
    {"date": "2025.01.30", "time": "14:15"},
    {"date": "2025.01.29", "time": "10:45"},
  ];

  // 새 채팅 추가 (테스트용)
  void _addChat() {
    setState(() {
      chats.insert(0, {"date": "2025.02.01", "time": "09:00"}); // 리스트 맨 앞에 추가
    });
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
                return _buildChatItem(chats[index]["date"]!, chats[index]["time"]!);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addChat, // 버튼 클릭 시 새 채팅 추가
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildChatItem(String date, String time) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            date.split(".")[2], // 날짜에서 "일"만 추출
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text("$date $time"),
        subtitle: const Text("진행 시간"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}
