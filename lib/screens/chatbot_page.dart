import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  late WebViewController _controller;
  bool _isLoading = true;

  final String baseChatbotUrl = 'https://www.chatbase.co/chatbot-iframe/s8cDnmZQBgTJceRV_zjP5';

  Future<String> _buildChatbotUrl() async {
    final user = FirebaseAuth.instance.currentUser;
    String initMessage = "안녕하세요!"; // 기본 메시지

    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        final userName = data?['name'] ?? '사용자';
        final height = data?['height'] ?? '';
        final weight = data?['weight'] ?? '';

        // BMI 계산
        double bmi = 0;
        try {
          double heightMeter = double.parse(height) / 100;
          double weightKg = double.parse(weight);
          bmi = weightKg / (heightMeter * heightMeter);
        } catch (_) {}

        String bmiStr = bmi > 0 ? bmi.toStringAsFixed(1) : '계산 불가';
        String bodyType = (bmi > 25) ? '비만' : (bmi > 18.5) ? '정상 체중' : '저체중';

        initMessage =
        "안녕하세요 $userName 님! 귀하의 키는 $height cm, 몸무게는 $weight kg입니다. "
            "계산한 BMI는 $bmiStr이고, 체형은 $bodyType입니다. 무엇을 도와드릴까요?";
      }
    }

    String encodedMessage = Uri.encodeComponent(initMessage);
    return "$baseChatbotUrl?initMessage=$encodedMessage";
  }

  Future<void> _loadChatbot() async {
    final chatbotUrl = await _buildChatbotUrl();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(chatbotUrl));

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadChatbot();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('고민해결 챗봇')),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : WebViewWidget(controller: _controller),
      ),
    );
  }
}
