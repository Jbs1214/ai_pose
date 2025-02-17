import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../exercises/barbell_curl.dart';
import '../exercises/deadlift.dart';
import '../exercises/squat.dart';

class WorkoutSelectionPage extends StatelessWidget {
  final List<CameraDescription> cameras;
  const WorkoutSelectionPage({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("운동 선택")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("스쿼트 분석"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SquatAnalysisPage(cameras: cameras),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text("데드리프트 분석"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeadliftAnalysisPage(cameras: cameras),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text("바벨컬 분석"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BarbellCurlAnalysisPage(cameras: cameras),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
