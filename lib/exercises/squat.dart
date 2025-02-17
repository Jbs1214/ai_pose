import 'dart:async';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// 스쿼트 분석에 사용되는 데이터 모델 (무릎, 엉덩이 좌표 및 계산된 각도)
class PoseData {
  final int frameIndex;
  final double leftKneeX;
  final double leftKneeY;
  final double rightKneeX;
  final double rightKneeY;
  final double leftHipX;
  final double leftHipY;
  final double rightHipX;
  final double rightHipY;
  final double avgKneeAngle;
  final double avgHipAngle;

  PoseData({
    required this.frameIndex,
    required this.leftKneeX,
    required this.leftKneeY,
    required this.rightKneeX,
    required this.rightKneeY,
    required this.leftHipX,
    required this.leftHipY,
    required this.rightHipX,
    required this.rightHipY,
    required this.avgKneeAngle,
    required this.avgHipAngle,
  });
}

double computeKneeAngle(PoseLandmark hip, PoseLandmark knee, PoseLandmark ankle) {
  final dx1 = hip.x - knee.x;
  final dy1 = hip.y - knee.y;
  final dx2 = ankle.x - knee.x;
  final dy2 = ankle.y - knee.y;
  final dot = dx1 * dx2 + dy1 * dy2;
  final mag1 = math.sqrt(dx1 * dx1 + dy1 * dy1);
  final mag2 = math.sqrt(dx2 * dx2 + dy2 * dy2);
  if (mag1 * mag2 == 0) return 0;
  final angleRad = math.acos(dot / (mag1 * mag2));
  return angleRad * 180 / math.pi;
}

double computeHipAngle(PoseLandmark shoulder, PoseLandmark hip, PoseLandmark knee) {
  final dx1 = shoulder.x - hip.x;
  final dy1 = shoulder.y - hip.y;
  final dx2 = knee.x - hip.x;
  final dy2 = knee.y - hip.y;
  final dot = dx1 * dx2 + dy1 * dy2;
  final mag1 = math.sqrt(dx1 * dx1 + dy1 * dy1);
  final mag2 = math.sqrt(dx2 * dx2 + dy2 * dy2);
  if (mag1 * mag2 == 0) return 0;
  final angleRad = math.acos(dot / (mag1 * mag2));
  return angleRad * 180 / math.pi;
}

class SquatAnalysisPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const SquatAnalysisPage({Key? key, required this.cameras}) : super(key: key);

  @override
  _SquatAnalysisPageState createState() => _SquatAnalysisPageState();
}

class _SquatAnalysisPageState extends State<SquatAnalysisPage> {
  late CameraController _controller;
  PoseDetector? _poseDetector;
  bool _isDetecting = false;
  bool _isStarted = false;

  List<String> _jointInfo = [];
  String _feedback = "";
  List<PoseData> _squatDataList = [];
  int _frameCount = 0;

  // 반복 횟수 관련 변수
  int _repCount = 0;
  String _repState = "up"; // "up": 일어서 있음, "down": 스쿼트 자세

  // 음성 피드백용
  DateTime? _wrongPostureStartTime;
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.cameras.first, ResolutionPreset.medium, enableAudio: false);
    _controller.initialize().then((_) {
      if (mounted) setState(() {});
    });
    _poseDetector = PoseDetector(options: PoseDetectorOptions(mode: PoseDetectionMode.stream));
  }

  void _startAnalysis() {
    setState(() {
      _isStarted = true;
    });
    _controller.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      _isDetecting = true;
      try {
        final WriteBuffer allBytes = WriteBuffer();
        for (final plane in image.planes) {
          allBytes.putUint8List(plane.bytes);
        }
        final bytes = allBytes.done().buffer.asUint8List();
        final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
        final imageRotation =
            InputImageRotationValue.fromRawValue(widget.cameras.first.sensorOrientation) ??
                InputImageRotation.rotation0deg;
        final inputImageFormat =
            InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;
        final planeData = image.planes.map((plane) => InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        )).toList();
        final inputImageData = InputImageData(
          size: imageSize,
          imageRotation: imageRotation,
          inputImageFormat: inputImageFormat,
          planeData: planeData,
        );
        final inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
        final poses = await _poseDetector!.processImage(inputImage);
        if (poses.isNotEmpty) {
          final pose = poses.first;
          final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
          final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
          final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
          final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
          final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
          final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
          final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
          final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];

          double leftKneeAngle = 0, rightKneeAngle = 0, leftHipAngle = 0, rightHipAngle = 0;
          if (leftHip != null && leftKnee != null && leftAnkle != null) {
            leftKneeAngle = computeKneeAngle(leftHip, leftKnee, leftAnkle);
          }
          if (rightHip != null && rightKnee != null && rightAnkle != null) {
            rightKneeAngle = computeKneeAngle(rightHip, rightKnee, rightAnkle);
          }
          if (leftShoulder != null && leftHip != null && leftKnee != null) {
            leftHipAngle = computeHipAngle(leftShoulder, leftHip, leftKnee);
          }
          if (rightShoulder != null && rightHip != null && rightKnee != null) {
            rightHipAngle = computeHipAngle(rightShoulder, rightHip, rightKnee);
          }
          final avgKneeAngle = (leftKneeAngle + rightKneeAngle) / 2;
          final avgHipAngle = (leftHipAngle + rightHipAngle) / 2;

          String feedbackMsg = "";
          // 피드백 조건 (반복 횟수 카운팅은 별도)
          if (avgKneeAngle > 150) {
            feedbackMsg += "스쿼트가 충분히 깊지 않습니다. 더 낮게 내려가세요. ";
          } else if (avgKneeAngle < 60) {
            feedbackMsg += "너무 깊게 내려갔습니다. 조금 일어나세요. ";
          }
          if (avgHipAngle < 70) {
            feedbackMsg += "상체가 너무 앞으로 기울어졌습니다. ";
          } else if (avgHipAngle > 120) {
            feedbackMsg += "상체가 너무 뒤로 젖혀졌습니다. ";
          }
          if (feedbackMsg.isEmpty) {
            feedbackMsg = "자세가 양호합니다.";
          }

          // Rep Counting: 상태 전환 기준 (스쿼트 동작)
          // 예: 일어서 있을 때(avgKneeAngle > 140)에서 내려가서(avgKneeAngle < 80) "down" 상태,
          // 그리고 다시 일어설 때(avgKneeAngle > 140) rep 1회 증가
          if (_repState == "up" && avgKneeAngle < 100) {
            _repState = "down";
          } else if (_repState == "down" && avgKneeAngle > 130) {
            _repCount++;
            _repState = "up";
          }

          setState(() {
            _jointInfo = [
              '왼쪽 무릎: ${leftKnee?.x.toStringAsFixed(2) ?? "N/A"}, ${leftKnee?.y.toStringAsFixed(2) ?? "N/A"}',
              '오른쪽 무릎: ${rightKnee?.x.toStringAsFixed(2) ?? "N/A"}, ${rightKnee?.y.toStringAsFixed(2) ?? "N/A"}',
              '왼쪽 엉덩이: ${leftHip?.x.toStringAsFixed(2) ?? "N/A"}, ${leftHip?.y.toStringAsFixed(2) ?? "N/A"}',
              '오른쪽 엉덩이: ${rightHip?.x.toStringAsFixed(2) ?? "N/A"}, ${rightHip?.y.toStringAsFixed(2) ?? "N/A"}',
              '무릎 각도: ${avgKneeAngle.toStringAsFixed(2)}°',
              '엉덩이 각도: ${avgHipAngle.toStringAsFixed(2)}°',
              '횟수: $_repCount회',
            ];
            _feedback = feedbackMsg;
            _squatDataList.add(PoseData(
              frameIndex: _frameCount++,
              leftKneeX: leftKnee?.x ?? 0.0,
              leftKneeY: leftKnee?.y ?? 0.0,
              rightKneeX: rightKnee?.x ?? 0.0,
              rightKneeY: rightKnee?.y ?? 0.0,
              leftHipX: leftHip?.x ?? 0.0,
              leftHipY: leftHip?.y ?? 0.0,
              rightHipX: rightHip?.x ?? 0.0,
              rightHipY: rightHip?.y ?? 0.0,
              avgKneeAngle: avgKneeAngle,
              avgHipAngle: avgHipAngle,
            ));
          });

          // 음성 피드백: 잘못된 자세가 3초 이상 지속되면 한글 음성 출력
          if (_feedback != "자세가 양호합니다.") {
            if (_wrongPostureStartTime == null) {
              _wrongPostureStartTime = DateTime.now();
            } else if (DateTime.now().difference(_wrongPostureStartTime!).inSeconds >= 3) {
              await _flutterTts.speak(_feedback);
              _wrongPostureStartTime = null;
            }
          } else {
            _wrongPostureStartTime = null;
          }
        }
      } catch (e) {
        print("Error processing image: $e");
      } finally {
        _isDetecting = false;
      }
    });
  }

  void _onStopPressed() {
    _controller.stopImageStream();
    // 필요 시 차트 페이지로 전환하는 코드를 추가하세요.
  }

  @override
  void dispose() {
    _controller.dispose();
    _poseDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text("스쿼트 분석")),
      body: Stack(
        children: [
          CameraPreview(_controller),
          if (!_isStarted)
            Center(
              child: ElevatedButton(
                child: const Text("운동 시작"),
                onPressed: _startAnalysis,
              ),
            ),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black45,
                child: Text("$_feedback\n횟수: $_repCount회", style: const TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _jointInfo.map((info) => Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.black45,
                child: Text(info, style: const TextStyle(color: Colors.white, fontSize: 16)),
              )).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: _isStarted ? FloatingActionButton(onPressed: _onStopPressed, child: const Icon(Icons.stop)) : null,
    );
  }
}
