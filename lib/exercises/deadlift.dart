import 'dart:async';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:fl_chart/fl_chart.dart';

/// 데드리프트 분석용 관절 데이터 모델 (무릎, 엉덩이 좌표 및 계산된 무릎 각도)
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
  final double avgKneeAngle;  // (hip, knee, ankle)로 계산한 무릎 각도
  final double avgHipAngle;   // 여기서는 데드리프트에서는 등 피드백은 제외

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

/// 세 점(hip, knee, ankle)로 무릎 각도(°) 계산
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

class DeadliftAnalysisPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const DeadliftAnalysisPage({Key? key, required this.cameras}) : super(key: key);

  @override
  _DeadliftAnalysisPageState createState() => _DeadliftAnalysisPageState();
}

// 데드리프트 분석 페이지는 앞서 제공한 코드를 기반으로 합니다.
class _DeadliftAnalysisPageState extends State<DeadliftAnalysisPage> {
  late CameraController _controller;
  PoseDetector? _poseDetector;
  bool _isDetecting = false;
  bool _isStarted = false;

  List<String> _jointInfo = [];
  String _feedback = "";
  List<PoseData> _deadliftDataList = [];
  int _frameCount = 0;

  // Rep 카운팅 변수
  int _repCount = 0;
  String _repState = "up"; // "up": 시작 상태, "down": 하강 상태

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
          final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
          final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
          final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
          final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
          final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
          final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

          double avgKneeAngle = 0.0;
          if (leftHip != null && leftKnee != null && leftAnkle != null &&
              rightHip != null && rightKnee != null && rightAnkle != null) {
            final leftKneeAngle = computeKneeAngle(leftHip, leftKnee, leftAnkle);
            final rightKneeAngle = computeKneeAngle(rightHip, rightKnee, rightAnkle);
            avgKneeAngle = (leftKneeAngle + rightKneeAngle) / 2;
          }

          String feedbackMsg = "";
          if (avgKneeAngle < 130) {
            feedbackMsg += "무릎이 너무 굽혀졌습니다. 약간 펴주세요. ";
          } else if (avgKneeAngle > 170) {
            feedbackMsg += "무릎이 너무 펴져 있습니다. 약간 굽혀주세요. ";
          }
          if (feedbackMsg.isEmpty) {
            feedbackMsg = "자세가 양호합니다.";
          }

          // Rep Counting: 데드리프트의 경우, 예를 들어 "up" 상태에서 무릎 각도가 150° 미만으로 내려가 "down" 상태가 되고,
          // 다시 "up" 상태(무릎 각도 > 150°)로 복귀할 때 rep 카운트
          if (_repState == "up" && avgKneeAngle < 120) {
            _repState = "down";
          } else if (_repState == "down" && avgKneeAngle > 150) {
            _repCount++;
            _repState = "up";
          }

          setState(() {
            _jointInfo = [
              '왼쪽 엉덩이: ${leftHip?.x.toStringAsFixed(2) ?? "N/A"}, ${leftHip?.y.toStringAsFixed(2) ?? "N/A"}',
              '오른쪽 엉덩이: ${rightHip?.x.toStringAsFixed(2) ?? "N/A"}, ${rightHip?.y.toStringAsFixed(2) ?? "N/A"}',
              '무릎 각도: ${avgKneeAngle.toStringAsFixed(2)}°',
              '횟수: $_repCount회',
            ];
            _feedback = feedbackMsg;
            _deadliftDataList.add(PoseData(
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
              avgHipAngle: 0.0,
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
      appBar: AppBar(title: const Text("데드리프트 분석")),
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


/// Deadlift Chart Page (차트 페이지는 기존 코드와 동일)
class DeadliftChartPage extends StatelessWidget {
  final List<PoseData> data;
  const DeadliftChartPage({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<FlSpot> kneeSpots = data.map((d) => FlSpot(d.frameIndex.toDouble(), d.avgKneeAngle)).toList();
    double minX = 0;
    double maxX = data.isNotEmpty ? data.last.frameIndex.toDouble() : 0;
    double minKnee = data.map((d) => d.avgKneeAngle).fold(double.infinity, (prev, e) => e < prev ? e : prev);
    double maxKnee = data.map((d) => d.avgKneeAngle).fold(-double.infinity, (prev, e) => e > prev ? e : prev);

    return Scaffold(
      appBar: AppBar(title: const Text("데드리프트 데이터 차트")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text("무릎 각도 변화", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      minX: minX,
                      maxX: maxX,
                      minY: minKnee,
                      maxY: maxKnee,
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: kneeSpots,
                          isCurved: false,
                          barWidth: 2,
                          color: Colors.blue,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
