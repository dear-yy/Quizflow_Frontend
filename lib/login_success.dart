import 'package:flutter/material.dart';
import 'package:quizflow_frontend/navigation_bar.dart'; // 하단 네비게이션 바를 가져옵니다.
import 'package:quizflow_frontend/profile_page.dart';
import 'package:quizflow_frontend/chat_page.dart';

class LoginSuccessPage extends StatefulWidget {
  @override
  _LoginSuccessPageState createState() => _LoginSuccessPageState();
}

class _LoginSuccessPageState extends State<LoginSuccessPage> {
  int _selectedIndex = 0;

  // 각 페이지를 나누어 리스트로 관리
  List<Widget> _pages = [
    ChatPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF69A88D),
      appBar: AppBar(
        title: Text('Login Success'),
        backgroundColor: Color(0xFF176560),
      ),
      body: SafeArea(
        child: _pages[_selectedIndex], // 선택된 페이지 표시
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        selectedIndex: _selectedIndex, // 선택된 인덱스
        onItemTapped: _onItemTapped, // 탭 시 인덱스 업데이트
      ),
    );
  }
}
