import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizflow_frontend/features/chat/presentation/screens/chat_list_page.dart';
import 'package:quizflow_frontend/features/battle/presentation/screens/battle_home_page.dart';
import 'package:quizflow_frontend/features/ranking/presentations/screens/ranking_page.dart';
import 'package:quizflow_frontend/features/profile/presentation/screens/settings_page.dart';
import 'package:quizflow_frontend/features/home/presentation/screens/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    print("✅[DEBUG] HomePage initState 실행됨!");
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF69A88D),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Text(
                  ['Chat', 'Battle', 'Ranking', 'Settings'][_selectedIndex],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.bebasNeue(
                    fontSize: 36,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: 4, // 페이지 개수
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return const ChatListPage();
                    case 1:
                      return const BattleHomePage();
                    case 2:
                      return RankingPage(key: ValueKey(DateTime.now().millisecondsSinceEpoch));
                    case 3:
                      return const SettingsPage();
                    default:
                      return Container();
                  }
                },
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        pageController: _pageController,
      ),
    );
  }
}
