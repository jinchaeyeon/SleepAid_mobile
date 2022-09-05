import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:intl/intl.dart';
import 'package:sleepaid/data/local/device_sensor_data.dart';
import 'package:sleepaid/network/sensor_service.dart';

import 'local/app_dao.dart';
import 'network/post_sensor_response.dart';

enum BODY_TYPE {
  NONE,
  NECK,
  FOREHEAD
}

class BleDevice {
  static const int SENSOR_LEN = 1000;
  static List<String> realtimeSesorTypes = ["PPG", "Actigraphy X", "Actigraphy Y", "Actigraphy Z","HRV"];

  DiscoveredDevice? discoveredDevice;
  String deviceName;
  String id;

  BleDevice(this.deviceName, this.id, this.discoveredDevice);

  String battery = "-";
  String pulseSize = "";
  String pulseRadius = "";
  String pulsePadding = "";
  List<DeviceSensorData> sensors = [];
  /// HRV에서 쓰여야하는 데이터, 서버에서 변환해서 와야하기 때문에 그래프 구조가 다름
  Map<String, List<double>> hrvData = {};


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
    /// 매 요청마다 전송 시, 서버 부하가 생기고, 파라미터 에서도 쓰여야 하기 때문에 200개씩 모아서 전송
    if(!isSendingToServer && waitingDataQueue.length > 200){
      isSendingToServer = true;
      sendingDataQueue.addAll(waitingDataQueue);
      waitingDataQueue.clear();
      PostSensorService(
        date: PostSensorService.getAnalysisDateString(),
        items: sendingDataQueue
      ).start().then((response) async {
        isSendingToServer = false;
        if(response is PostSensorResponse){
          /// 정상 동작이면 전송하기 위한 대기 데이터 초기화
          sendingDataQueue.clear();
          /// 데이터 초기화 후, 현재 존재하는 파라미터의 데이터와 관련 된 값을 업로드 후 전달받음
          await setHRVData(response.items);
        }
      }).onError((error, stackTrace){
        print("setDeviceResponse err");
        isSendingToServer = false;
      });
    }

    while(sensors.length > SENSOR_LEN) {
      sensors.removeRange(0, SENSOR_LEN ~/ 100); /// 전체 센서저장값 중 오래된 1% 삭제
    }
    sensors.add(data);
    waitingDataQueue.add(data.toSennsorResponse());
    return;
  }

  static int getMaxYFromType(String type) {
    if(type == realtimeSesorTypes[0]){
      return 65536;
    }else if(type == realtimeSesorTypes[1]){
      return 2000;
    }else if(type == realtimeSesorTypes[2]){
      return 2000;
    }else if(type == realtimeSesorTypes[3]){
      return 2000;
    }else if(type == realtimeSesorTypes[4]){
      return 10;
    }
    return 2000;
  }

  Future<void> setHRVData(List<BaseSensorResponse> items) async{
    List<int> ppgs = List.generate(items.length, (index) => items[index].ppg);
    AppDAO.selectedParameterIndexes.forEach((index) async {
      var result = await PostModifiedSensorService(type: AppDAO.parameters[index].name, values: ppgs).start();
      if(result is double){
        /// 전달받은 1개의 double값 HRV 데이터 목록에 추가
        if(hrvData[AppDAO.parameters[index].name] == null) {
          hrvData[AppDAO.parameters[index].name] = [];
        }
        hrvData[AppDAO.parameters[index].name]?.add(result);
        /// 150개가 넘게 저장되면 250개 삭제(HRV는 최근 n개까지만 보여주고 그 뒤는 이동 관련 예비값)
        if(hrvData[AppDAO.parameters[index].name]!.length > 150){
          hrvData[AppDAO.parameters[index].name]!.removeRange(0, 75);
        }
      }
    });
  }
}