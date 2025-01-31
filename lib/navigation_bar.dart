import 'package:flutter/material.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final PageController pageController;

  BottomNavigationBarWidget({
    required this.selectedIndex,
    required this.onItemTapped,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // 아이콘 위치 고정 (중요)
      currentIndex: selectedIndex,
      onTap: (index) {
        onItemTapped(index);
        pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 300), // 애니메이션 지속 시간
          curve: Curves.easeInOut, // 부드러운 애니메이션
        );
      },
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_kabaddi),
          label: 'Battle',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events),
          label: 'Ranking',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Setting',
        ),
      ],
      backgroundColor: Color(0xFF176560),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
    );
  }
}
