import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:sleepaid/data/local/device_sensor_data.dart';

enum BODY_TYPE {
  NONE,
  NECK,
  FOREHEAD
}

class BleDevice {
  static const int SENSOR_LEN = 1000;
  static List<String> realtimeSesorTypes = ["PPG", "Actigraphy X", "Actigraphy Y", "Actigraphy Z",];

  DiscoveredDevice? discoveredDevice;
  String deviceName;
  String id;

  BleDevice(this.deviceName, this.id, this.discoveredDevice);

  String battery = "-";
  String pulseSize = "";
  String pulseRadius = "";
  String pulsePadding = "";
  List<DeviceSensorData> sensors = [];

  setSensors(List<DeviceSensorData> sensors){
    this.sensors = sensors;
  }
  // List<int> ppg = [];
  // List<int> eeg = [];
  // List<int> actX = [];
  // List<int> actY = [];
  // List<int> actZ = [];

  void resetData() {
    // state = PeripheralConnectionState.disconnected;
    battery = "-";
    pulseSize = "";
    pulseRadius = "";
    pulsePadding = "";
    // ppg = [];
    // eeg = [];
    // actX = [];
    // actY = [];
    // actZ = [];
  }

  List<int> getSensorValues(String types) {
    List<int> values = [];
    sensors.forEach((_sensor) {
      if(types == realtimeSesorTypes[0]){
        values.add(_sensor.ppg);
      }else if(types == realtimeSesorTypes[1]){
        values.add(_sensor.actX);
      }else if(types == realtimeSesorTypes[2]){
        values.add(_sensor.actY);
      }else if(types == realtimeSesorTypes[3]){
        values.add(_sensor.actZ);
      }
    });
    return values;
  }

  /// 기기에서 가져온 데이터 저장
  void setDeviceResponse(DeviceSensorData data) {
    while(sensors.length > SENSOR_LEN) {
      sensors.removeRange(0, SENSOR_LEN ~/ 100);
    }
    sensors.add(data);
    return;
  }

  static num getMaxYFromType(String type) {
    if(type == realtimeSesorTypes[0]){
      return 65536;
    }else if(type == realtimeSesorTypes[1]){
      return 2000;
    }else if(type == realtimeSesorTypes[2]){
      return 2000;
    }else if(type == realtimeSesorTypes[3]){
      return 2000;
    }
    return 2000;
  }
}