import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'user_details_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _signInWithGoogle() async {
    try {
      // 이전 연결 해제 시도 (없어도 무관하므로 에러는 무시)
      try {
        await _googleSignIn.disconnect();
      } catch (e) {
        debugPrint("Google Sign-In disconnect 에러 무시: $e");
      }

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // 사용자가 로그인 취소한 경우

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // 로그인 성공 시 항상 UserDetailsPage로 전환하여 추가 정보를 입력하도록 함
      if (userCredential.user != null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (_) => const UserDetailsPage()),
        );
      }
    } catch (e, st) {
      debugPrint('Google Sign-In 에러: $e\n$st');
      if (!mounted) return;
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('로그인 에러'),
          content: Text('Google Sign-In 실패: $e'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('확인'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('로그인')),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로그인 배너 이미지
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Image.asset(
                  'assets/images/login_banner.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              CupertinoButton.filled(
                onPressed: _signInWithGoogle,
                child: const Text('구글 계정으로 로그인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
