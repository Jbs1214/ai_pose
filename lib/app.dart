// lib/app.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // <== 추가
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/login_page.dart';
import 'screens/user_details_page.dart';
import 'screens/main_tab_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: '올곧음 App',
      // Material 위젯들이 사용하는 localizations 설정
      // (No MaterialLocalizations found 오류 방지)
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ko', 'KR'),
      ],
      theme: const CupertinoThemeData(
        primaryColor: CupertinoColors.activeBlue,
      ),
      home: const AuthWrapper(),
    );
  }
}

/// AuthWrapper: FirebaseAuth의 로그인 상태와 Firestore의 사용자 문서 유무에 따라 화면 분기
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 로딩 중
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        // 로그인 안됨
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginPage();
        }
        // 로그인됨: Firestore 문서 확인
        final user = snapshot.data!;
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
          builder: (context, userDocSnapshot) {
            if (userDocSnapshot.connectionState == ConnectionState.waiting) {
              return const CupertinoPageScaffold(
                child: Center(child: CupertinoActivityIndicator()),
              );
            }
            final userDoc = userDocSnapshot.data;
            final docExists = (userDoc != null && userDoc.exists);
            if (!docExists) {
              return const UserDetailsPage();
            }
            // 메인 탭 페이지로 이동
            return const MainTabPage();
          },
        );
      },
    );
  }
}
