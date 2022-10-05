import '../ble_device.dart';
import '../network/post_sensor_response.dart';

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

  int getDataByType(String type) {
    if(type == BleDevice.realtimeSesorTypes[0]){
      return eeg1;
    }else if(type == BleDevice.realtimeSesorTypes[1]){
      return eeg2;
    } else if(type == BleDevice.realtimeSesorTypes[2]){
      return ppg;
    }else if(type == BleDevice.realtimeSesorTypes[3]){
      return actX;
    }else if(type == BleDevice.realtimeSesorTypes[4]){
      return actY;
    }else if(type == BleDevice.realtimeSesorTypes[5]){
      return actZ;
    }
    return 0;
  }

  BaseSensorResponse toSennsorResponse(){
    return BaseSensorResponse(
      datetime: dateTime.toIso8601String(),
      ppg: ppg,
      eeg1: eeg1,
      eeg2: eeg2,
      actigraphyX: actX,
      actigraphyY: actY,
      actigraphyZ: actZ
    );
  }
}