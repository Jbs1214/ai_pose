import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show TextInputType;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_tab_page.dart';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({super.key});

  @override
  UserDetailsPageState createState() => UserDetailsPageState();
}

class UserDetailsPageState extends State<UserDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _age = '20';
  String _height = '';
  String _weight = '';

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState?.save();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('UserDetailsPage: 현재 로그인된 사용자가 없음');
      if (!mounted) return;
      await showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('로그인 오류'),
          content: const Text('로그인 세션이 만료되었습니다. 다시 로그인해주세요.'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('확인'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _name,
        'age': _age,
        'height': _height,
        'weight': _weight,
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      debugPrint('UserDetailsPage: Firestore 저장 에러: $e\n$st');
    }

    if (!mounted) return;
    // 추가 정보 입력 완료 후 MainTabPage로 전환
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(builder: (_) => const MainTabPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('신체 정보 입력')),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: CupertinoScrollbar(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildTextField(
                  label: '이름',
                  placeholder: '이름을 입력하세요',
                  onSaved: (val) => _name = val ?? '',
                  validator: (val) => (val == null || val.isEmpty) ? '이름은 필수' : null,
                ),
                const SizedBox(height: 20),
                _buildAgePicker(),
                const SizedBox(height: 20),
                _buildTextField(
                  label: '키(cm)',
                  placeholder: '키를 입력하세요',
                  keyboardType: TextInputType.number,
                  onSaved: (val) => _height = val ?? '',
                  validator: (val) => (val == null || val.isEmpty) ? '키는 필수' : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  label: '몸무게(kg)',
                  placeholder: '몸무게를 입력하세요',
                  keyboardType: TextInputType.number,
                  onSaved: (val) => _weight = val ?? '',
                  validator: (val) => (val == null || val.isEmpty) ? '몸무게는 필수' : null,
                ),
                const SizedBox(height: 40),
                CupertinoButton.filled(
                  onPressed: _submitForm,
                  child: const Text('제출'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        CupertinoTextFormFieldRow(
          placeholder: placeholder,
          keyboardType: keyboardType,
          onSaved: onSaved,
          validator: validator,
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        ),
      ],
    );
  }

  Widget _buildAgePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('나이', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CupertinoPicker(
            scrollController: FixedExtentScrollController(initialItem: int.parse(_age) - 1),
            itemExtent: 40,
            onSelectedItemChanged: (index) {
              setState(() {
                _age = (index + 1).toString();
              });
            },
            children: List.generate(
              100,
                  (index) => Center(child: Text('${index + 1}')),
            ),
          ),
        ),
      ],
    );
  }
}
