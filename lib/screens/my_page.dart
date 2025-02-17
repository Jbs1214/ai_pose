import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Map<String, dynamic>? userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        userData = doc.data();
      }
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _logout() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      }
    } catch (e) {
      debugPrint('MyPage - 문서 삭제 에러: $e');
    }

    try {
      await _googleSignIn.disconnect();
    } catch (e) {
      debugPrint('Google Sign-In disconnect 에러 무시: $e');
    }
    await _googleSignIn.signOut();
    await _auth.signOut();

    if (!mounted) return;
    // 전체 네비게이션 스택 제거 후 LoginPage로 전환
    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('마이페이지')),
      child: SafeArea(
        child: _loading
            ? const Center(child: CupertinoActivityIndicator())
            : Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '이메일: ${_auth.currentUser?.email ?? "없음"}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              if (userData != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('이름: ${userData!['name']}', style: const TextStyle(fontSize: 16)),
                    Text('나이: ${userData!['age']}', style: const TextStyle(fontSize: 16)),
                    Text('키: ${userData!['height']} cm', style: const TextStyle(fontSize: 16)),
                    Text('몸무게: ${userData!['weight']} kg', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              const Spacer(),
              CupertinoButton.filled(
                onPressed: _logout,
                child: const Text('로그아웃'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
