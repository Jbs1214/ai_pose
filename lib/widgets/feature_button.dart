// lib/widgets/feature_button.dart
import 'package:flutter/cupertino.dart';

class FeatureButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const FeatureButton({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      color: CupertinoColors.systemGrey5,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      onPressed: onTap,
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, color: CupertinoColors.black),
        textAlign: TextAlign.center,
      ),
    );
  }
}
