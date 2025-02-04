import 'package:flutter/material.dart';
import 'package:quizflow_frontend/navigation_bar.dart';
import 'package:quizflow_frontend/chat_list_page.dart';
import 'package:quizflow_frontend/battle_page.dart';
import 'package:quizflow_frontend/ranking_page.dart';
import 'package:quizflow_frontend/settings_page.dart';

class LoginSuccessPage extends StatefulWidget {
  @override
  _LoginSuccessPageState createState() => _LoginSuccessPageState();
}

class _LoginSuccessPageState extends State<LoginSuccessPage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0); // 여기서 바로 초기화!

  @override
  void dispose() {
    _pageController.dispose(); // 사용이 끝나면 메모리 해제
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 뒤로 가기 차단
      child: Scaffold(
        backgroundColor: Color(0xFF69A88D),
        appBar: AppBar(
          title: Text(['Chat', 'Battle', 'Ranking', 'Settings'][_selectedIndex]),
          backgroundColor: Color(0xFF176560),
          automaticallyImplyLeading: false, // 뒤로 가기 버튼 삭제
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [
            ChatListPage(),
            BattlePage(),
            RankingPage(),
            SettingsPage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBarWidget(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
          pageController: _pageController, // 전달
        ),
      ),
    );
  }
}