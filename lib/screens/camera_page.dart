// lib/screens/camera_page.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'; // for compute()
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// BluetoothManager (예시로 포함; 필요에 따라 수정)
class BluetoothManager {
  BluetoothManager._internal();
  static final BluetoothManager instance = BluetoothManager._internal();

  BluetoothDevice? _device;
  BluetoothCharacteristic? _characteristic;
  bool isConnected = false;

  final String serviceUUID = "0000ffe0-0000-1000-8000-00805f9b34fb";
  final String characteristicUUID = "0000ffe1-0000-1000-8000-00805f9b34fb";

  Future<void> connect() async {
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    List<ScanResult> scanResults = await FlutterBluePlus.scanResults.first;
    for (ScanResult result in scanResults) {
      if (result.advertisementData.serviceUuids.contains(serviceUUID)) {
        _device = result.device;
        break;
      }
    }
    if (_device == null && scanResults.isNotEmpty) {
      _device = scanResults.first.device;
    }
    await FlutterBluePlus.stopScan();
    if (_device != null) {
      try {
        await _device!.connect();
      } catch (e) {
        // 이미 연결된 경우 무시
      }
      List<BluetoothService> services = await _device!.discoverServices();
      for (var service in services) {
        if (service.uuid.toString().toLowerCase() == serviceUUID) {
          for (var c in service.characteristics) {
            if (c.uuid.toString().toLowerCase() == characteristicUUID) {
              _characteristic = c;
              isConnected = true;
              break;
            }
          }
        }
      }
    }
  }

  Future<void> sendWeight(double weight) async {
    if (_characteristic != null) {
      List<int> bytes = weight.toStringAsFixed(0).codeUnits;
      await _characteristic!.write(bytes, withoutResponse: true);
    }
  }
}

/// CameraPage: 카메라 스트림과 ML Kit 포즈 감지를 통한 자세 감지 화면
class CameraPage extends StatefulWidget {
  final String muscleGroup;
  final String tool;
  final String workoutName;
  final int setCount;
  final double? weight;

  const CameraPage({
    Key? key,
    required this.muscleGroup,
    required this.tool,
    required this.workoutName,
    required this.setCount,
    this.weight,
  }) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  bool _initialized = false;
  int _cameraIndex = 0;
  bool _isFlashVisible = false;

  PoseDetector? _poseDetector;
  String _poseResult = '자세 미감지';

  // 최소 500ms 간격으로 추론 실행 (원하는 간격으로 조절)
  DateTime _lastProcessingTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();

    // 운동 도구가 '바벨'이고 무게가 있다면 Bluetooth 연결 시도
    if (widget.tool == '바벨' && widget.weight != null) {
      BluetoothManager.instance.connect();
    }
  }



  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      _initCamera(_cameraIndex);
    } else {
      debugPrint('카메라 권한 거부됨');
    }
  }

  Future<void> _initCamera(int index) async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    if (index >= cameras.length) return;

    _controller?.dispose();
    final desc = cameras[index];
    // ResolutionPreset.high: 해상도와 비율은 그대로 유지
    _controller = CameraController(desc, ResolutionPreset.high, enableAudio: false);
    try {
      await _controller!.initialize();
      setState(() => _initialized = true);
      _controller!.startImageStream((CameraImage image) async {
        final currentTime = DateTime.now();
        if (currentTime.difference(_lastProcessingTime).inMilliseconds < 500) {
          return;
        }
        _lastProcessingTime = currentTime;
      });
    } catch (e) {
      debugPrint('카메라 초기화 실패: $e');
    }
  }
  Future<void> _capturePhoto() async {
    if (!(_controller?.value.isInitialized ?? false)) return;
    try {
      final XFile file = await _controller!.takePicture();
      final dir = Directory('/storage/emulated/0/DCIM/Camera');
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      final savePath = path.join(
        dir.path,
        'captured_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.saveTo(savePath);
      debugPrint('사진 저장: $savePath');
      setState(() => _isFlashVisible = true);
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() => _isFlashVisible = false);
      });
      if (widget.tool == '바벨' && widget.weight != null) {
        await BluetoothManager.instance.sendWeight(widget.weight!);
      }
    } catch (e) {
      debugPrint('사진 촬영 실패: $e');
    }
  }

  Future<void> _switchCamera() async {
    final cameras = await availableCameras();
    if (cameras.length < 2) {
      debugPrint('전/후면 카메라가 없습니다.');
      return;
    }
    setState(() => _initialized = false);
    _cameraIndex = (_cameraIndex + 1) % cameras.length;
    await _initCamera(_cameraIndex);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _poseDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('${widget.muscleGroup} | ${widget.workoutName}'),
        trailing: GestureDetector(
          onTap: _switchCamera,
          child: const Icon(CupertinoIcons.switch_camera),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  _initialized
                      ? CameraPreview(_controller!)
                      : const Center(child: CupertinoActivityIndicator()),
                  // 포즈 감지 결과 오버레이
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      color: CupertinoColors.black.withOpacity(0.5),
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        _poseResult,
                        style: const TextStyle(color: CupertinoColors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  // 촬영 시 플래시 효과
                  AnimatedOpacity(
                    opacity: _isFlashVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      color: CupertinoColors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CupertinoButton.filled(
                  child: const Icon(CupertinoIcons.camera),
                  onPressed: _capturePhoto,
                ),
                CupertinoButton(
                  child: const Text('닫기'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
