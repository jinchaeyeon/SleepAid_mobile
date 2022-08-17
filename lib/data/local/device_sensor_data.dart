import '../ble_device.dart';

/// 장치에서 가져오는 센서 데이터
class DeviceSensorData{
  DateTime dateTime;
  int eeg1;
  int eeg2;
  int ppg;
  int actX;
  int actY;
  int actZ;

  DeviceSensorData({
    required this.dateTime,
    required this.eeg1,
    required this.eeg2,
    required this.ppg,
    required this.actX,
    required this.actY,
    required this.actZ
  });

  getDataByType(String type) {
    if(type == BleDevice.realtimeSesorTypes[0]){
      return ppg;
    }else if(type == BleDevice.realtimeSesorTypes[1]){
      return actX;
    }else if(type == BleDevice.realtimeSesorTypes[2]){
      return actY;
    }else if(type == BleDevice.realtimeSesorTypes[3]){
      return actZ;
    }
  }
}