// lib/bluetooth/bluetooth_manager.dart

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// BluetoothManager: 블루투스 스캔, 연결, 데이터 전송 담당 (싱글톤)
class BluetoothManager {
  BluetoothManager._internal();
  static final BluetoothManager instance = BluetoothManager._internal();

  BluetoothDevice? _device;
  BluetoothCharacteristic? _characteristic;
  bool isConnected = false;

  // 예시용 서비스와 characteristic UUID (실제 기기에 맞게 수정)
  final String serviceUUID = "0000ffe0-0000-1000-8000-00805f9b34fb";
  final String characteristicUUID = "0000ffe1-0000-1000-8000-00805f9b34fb";

  /// 블루투스 기기 검색 후 연결 및 characteristic 확보
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
        // 이미 연결된 경우 등 예외 발생 시 무시
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

  /// 현재 무게(kg)를 블루투스 기기로 전송 (문자열로 변환하여 전송)
  Future<void> sendWeight(double weight) async {
    if (_characteristic != null) {
      List<int> bytes = weight.toStringAsFixed(0).codeUnits;
      await _characteristic!.write(bytes, withoutResponse: true);
    }
  }
}
