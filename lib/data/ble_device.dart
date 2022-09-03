import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:intl/intl.dart';
import 'package:sleepaid/data/local/device_sensor_data.dart';
import 'package:sleepaid/network/sensor_service.dart';

import 'network/post_sensor_response.dart';

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

  bool isSendingToServer = false;
  /// 마지막 전송일과 새 전송일이 다르면 우선 저장된 데이터를 전송하고 남은 데이터를 전송한다
  String? lastSuccessRequestDate;
  List<BaseSensorResponse> waitingDataQueue = []; /// 로컬 저장중인 전송대기 데이터
  List<BaseSensorResponse> sendingDataQueue = []; /// 전송중인 데이터
  DateFormat serverDateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ");

  /// 기기에서 가져온 데이터 저장
  void setDeviceResponse(DeviceSensorData data) {
    /// 매 요청마다 전송 시, 서버 부하가 생기기 때문에 1000개씩 모아서 전송
    if(!isSendingToServer && waitingDataQueue.length > 100){
      isSendingToServer = true;
      sendingDataQueue.addAll(waitingDataQueue);
      PostSensorService(
        date: PostSensorService.getAnalysisDateString(),
        items: sendingDataQueue
      ).start().then((response){
        isSendingToServer = false;
        if(response is PostSensorResponse){
          /// 정상 동작이면 전송하기 위한 대기 데이터 초기화
          sendingDataQueue.clear();
        }
      }).onError((error, stackTrace){
        isSendingToServer = false;
      });
    }

    while(sensors.length > SENSOR_LEN) {
      sensors.removeRange(0, SENSOR_LEN ~/ 100);
    }
    sensors.add(data);
    waitingDataQueue.add(data.toSennsorResponse());
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