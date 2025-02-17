// lib/screens/dummy_page.dart
import 'package:flutter/cupertino.dart';

class DummyPage extends StatelessWidget {
  final String title;
  const DummyPage({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(title)),
      child: SafeArea(
        child: Center(
          child: Text(
            '$title 페이지',
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
