import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// 바벨컬 분석용 데이터 모델 (양쪽 팔꿈치 각도)
class BarbellCurlData {
  final int frameIndex;
  final double leftElbowAngle;
  final double rightElbowAngle;

  BarbellCurlData({
    required this.frameIndex,
    required this.leftElbowAngle,
    required this.rightElbowAngle,
  });
}

double computeElbowAngle(PoseLandmark shoulder, PoseLandmark elbow, PoseLandmark wrist) {
  final dx1 = shoulder.x - elbow.x;
  final dy1 = shoulder.y - elbow.y;
  final dx2 = wrist.x - elbow.x;
  final dy2 = wrist.y - elbow.y;
  final dot = dx1 * dx2 + dy1 * dy2;
  final mag1 = math.sqrt(dx1 * dx1 + dy1 * dy1);
  final mag2 = math.sqrt(dx2 * dx2 + dy2 * dy2);
  if (mag1 * mag2 == 0) return 0;
  final angleRad = math.acos(dot / (mag1 * mag2));
  return angleRad * 180 / math.pi;
}

class BarbellCurlAnalysisPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const BarbellCurlAnalysisPage({Key? key, required this.cameras}) : super(key: key);

  @override
  _BarbellCurlAnalysisPageState createState() => _BarbellCurlAnalysisPageState();
}

class _BarbellCurlAnalysisPageState extends State<BarbellCurlAnalysisPage> {
  late CameraController _controller;
  PoseDetector? _poseDetector;
  bool _isDetecting = false;
  bool _isStarted = false;

  List<String> _jointInfo = [];
  String _feedback = "";
  List<BarbellCurlData> _curlDataList = [];
  int _frameCount = 0;

  // Rep 카운팅 변수
  int _repCount = 0;
  String _repState = "up"; // "up": 팔이 펴진 상태, "down": 컬 상태

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
        final imageRotation = InputImageRotationValue.fromRawValue(widget.cameras.first.sensorOrientation)
            ?? InputImageRotation.rotation0deg;
        final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw)
            ?? InputImageFormat.nv21;
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
          final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
          final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
          final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
          final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
          final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
          final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

          double leftElbowAngle = 0, rightElbowAngle = 0;
          if (leftShoulder != null && leftElbow != null && leftWrist != null) {
            leftElbowAngle = computeElbowAngle(leftShoulder, leftElbow, leftWrist);
          }
          if (rightShoulder != null && rightElbow != null && rightWrist != null) {
            rightElbowAngle = computeElbowAngle(rightShoulder, rightElbow, rightWrist);
          }
          // 평균 또는 대표 각도로 rep 카운팅 (여기서는 왼쪽 팔꿈치 기준)
          double avgElbowAngle = (leftElbowAngle + rightElbowAngle) / 2;

          String feedbackMsg = "";
          if (avgElbowAngle > 170) {
            feedbackMsg += "팔이 너무 펴져 있습니다. 더 컬하세요. ";
          } else if (avgElbowAngle < 30) {
            feedbackMsg += "팔꿈치가 너무 많이 굽혀졌습니다. 과도한 컬입니다. ";
          }
          if ((leftElbowAngle - rightElbowAngle).abs() > 20) {
            feedbackMsg += "좌우 팔의 균형을 맞추세요. ";
          }
          if (feedbackMsg.isEmpty) {
            feedbackMsg = "자세가 양호합니다.";
          }

          // Rep Counting: 바벨컬의 경우, "up" 상태에서 팔꿈치 각도가 50° 이하로 내려가 "down" 상태,
          // 그리고 "down" 상태에서 팔꿈치 각도가 150° 이상으로 복귀하면 rep 1회 증가
          // 바벨컬: "up" 상태에서 평균 팔꿈치 각도가 60° 미만이면 "down" 상태로 전환,
// "down" 상태에서 평균 팔꿈치 각도가 140° 이상이면 rep 1회 증가 후 "up" 상태로 전환.
          if (_repState == "up" && avgElbowAngle < 60) {
            _repState = "down";
          } else if (_repState == "down" && avgElbowAngle > 140) {
            _repCount++;
            _repState = "up";
          }


          setState(() {
            _jointInfo = [
              '왼쪽 팔꿈치 각도: ${leftElbowAngle.toStringAsFixed(2)}°',
              '오른쪽 팔꿈치 각도: ${rightElbowAngle.toStringAsFixed(2)}°',
              '횟수: $_repCount회',
            ];
            _feedback = feedbackMsg;
            _curlDataList.add(BarbellCurlData(
              frameIndex: _frameCount++,
              leftElbowAngle: leftElbowAngle,
              rightElbowAngle: rightElbowAngle,
            ));
          });

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
    // 차트 페이지 전환 코드 추가 가능
  }

  @override
  void dispose() {
    _controller.dispose();
    _poseDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text("바벨컬 분석")),
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
