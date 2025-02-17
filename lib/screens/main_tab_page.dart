import 'package:flutter/cupertino.dart';
import 'home_page.dart';
import 'calendar_page.dart';
import 'chatbot_page.dart'; // 챗봇 페이지 임포트
import 'my_page.dart';
import 'dummy_page.dart'; // 라이브러리 탭 등, 필요하다면 사용

class MainTabPage extends StatefulWidget {
  const MainTabPage({super.key});

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  // 하단 탭이 포함된 메인 페이지입니다.
  int _currentIndex = 0; // 기본 탭은 MyPage(마이페이지)

  final List<Widget> _pages = [
    const HomePage(),
    const CalendarPage(),
    const ChatbotPage(),
    const DummyPage(title: '라이브러리'),
    const MyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar),
            label: '캘린더',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2),
            label: '고민해결',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book),
            label: '라이브러리',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: '마이페이지',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (_) => _pages[index],
        );
      },
    );
  }
}
