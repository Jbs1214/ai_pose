import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'main_tab_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<bool> _hasUserDetails(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.exists;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // 로딩 상태
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        // 사용자가 로그인되어 있으면
        if (authSnapshot.hasData) {
          final uid = authSnapshot.data!.uid;
          return FutureBuilder<bool>(
            future: _hasUserDetails(uid),
            builder: (context, userDocSnapshot) {
              if (userDocSnapshot.connectionState == ConnectionState.waiting) {
                return const CupertinoPageScaffold(
                  child: Center(child: CupertinoActivityIndicator()),
                );
              }
              // Firestore에 문서가 있으면 MainTabPage로 이동
              if (userDocSnapshot.hasData && userDocSnapshot.data == true) {
                return const MainTabPage();
              } else {
                // 문서가 없으면 로그인 페이지로 이동
                // (이렇게 하면 기존에 Firestore 문서가 없을 경우 사용자가 다시
                // 로그인 후 UserDetailsPage에서 추가 정보를 입력하도록 할 수 있습니다.)
                FirebaseAuth.instance.signOut();
                return const LoginPage();
              }
            },
          );
        }
        // 사용자가 로그인되어 있지 않으면 LoginPage로 이동
        return const LoginPage();
      },
    );
  }
}
