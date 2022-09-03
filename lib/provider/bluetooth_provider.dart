import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sleepaid/bluetooth/flutter_reactive_ble/ble_connector.dart';
import 'package:sleepaid/bluetooth/flutter_reactive_ble/ble_interactor.dart';
import 'package:sleepaid/bluetooth/flutter_reactive_ble/ble_logger.dart';
import 'package:sleepaid/bluetooth/flutter_reactive_ble/ble_scanner.dart';
import 'package:sleepaid/bluetooth/flutter_reactive_ble/ble_status_monitor.dart';
import 'package:sleepaid/bluetooth/protocol.dart';
import 'package:sleepaid/data/ble_device.dart';
import 'package:sleepaid/data/local/device_sensor_data.dart';
import 'package:sleepaid/util/functions.dart';

/// 항시 연결상태 체크
/// 항시 데이터 서버 전송
/// 네트워크/서버 연결 실패하면 로컬에 담아서 보관
/// 네트워크/서버 연결 되면 로컬 데이터 서버 전송하고 삭제
class BluetoothProvider with ChangeNotifier{
  static const List<String> SERVICE_UUID_LIST = ['6e400001-b5a3-f393-e0a9-e50e24dcca9e'];
  static const List<String> RX_UUID_LIST = ['6e400002-b5a3-f393-e0a9-e50e24dcca9e'];
  static const List<String> TX_UUID_LIST = ['6e400003-b5a3-f393-e0a9-e50e24dcca9e'];
  static const int MTU = 20;

  static FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();

  static BleLogger bleLogger = BleLogger();
  final scanner = BleScanner(ble: flutterReactiveBle, logMessage: bleLogger.addToLog);
  final monitor = BleStatusMonitor(flutterReactiveBle);
  final connectorNeck = BleDeviceConnector(
    ble: flutterReactiveBle,
    logMessage: bleLogger.addToLog,
  );
  final connectorForehead = BleDeviceConnector(
    ble: flutterReactiveBle,
    logMessage: bleLogger.addToLog,
  );
  final serviceDiscoverer = BleDeviceInteractor(
    bleDiscoverServices: flutterReactiveBle.discoverServices,
    readCharacteristic: flutterReactiveBle.readCharacteristic,
    writeWithResponse: flutterReactiveBle.writeCharacteristicWithResponse,
    writeWithOutResponse: flutterReactiveBle.writeCharacteristicWithoutResponse,
    subscribeToCharacteristicNeck: flutterReactiveBle.subscribeToCharacteristic,
    subscribeToCharacteristicForehead: flutterReactiveBle.subscribeToCharacteristic,
    logMessage: bleLogger.addToLog,
  );

  bool isDeviceScanning = false;
  bool isDataCollecting = true;

  BleDevice? deviceNeck;
  BleDevice? deviceForehead;

  bool get isDataSending => true;//이마 연결장치

  /// 로그아웃시, 블루투스 관련 데이터 초기화
  Future<void> clearBluetooth() async{
    // deviceList.clear();
    // connectedDeviceForNeck = null;
    // connectedDeviceForForehead = null;
  }

  ///기기가 연결되어 있으면 데이터 수집/비수집 전환한다
  Future<void> toggleDataCollecting() async{
    if(isDataCollecting){
      isDataCollecting = false;
    }else{
      isDataCollecting = true;
    }
    notifyListeners();
  }

  ///블루투스 장치 스캔(회사목록만)
  Future<void> startDeviceScanning() async {
    print("startDeviceScanning");
    isDeviceScanning = true;
    scanner.startScan([Uuid.parse(SERVICE_UUID_LIST[0])]);
    /// 계속 검색 시, OS 단에서 몇분~ 몇십분 검색 안하도록 처리할 수 있어서 1회당 20초 제한
    Future.delayed(const Duration(seconds: 20), stopDeviceScanning);
    // scanner.startScan([]); //전체 블루투스 검색 디바이스 목록
    notifyListeners();
  }

  ///스캔 끝나면 꼭 stop처리
  Future<void> stopDeviceScanning() async {
    print("stopDeviceScanning");
    isDeviceScanning = false;
    scanner.stopScan();
    notifyListeners();
  }


  ///전체적으로 버전별 체크 한번 필요
  Future<void> checkBluetoothPermission({int retryCount = 0}) async {
    print("checkBluetoothPermission $retryCount");
    Map<Permission, PermissionStatus> statuses =
    await [Permission.location, Permission.bluetooth, Permission.bluetoothConnect, Permission.bluetoothScan].request();
    if(
    // statuses[Permission.location] == PermissionStatus.denied ||
        statuses[Permission.bluetoothConnect] == PermissionStatus.denied
    ){
      showToast("앱 설정에서 필수 권한을 설정해주세요");
      if(retryCount == 1){
        completedExit(null);
      }else{
        checkBluetoothPermission(retryCount: 1);
      }
    }
  }

  /// 블루투스 꺼져있는지 체크 후, turn on 또는 알림 처리
  Future<void> requestBleTurnOn() async{
    print("requestBleTurnOn");
    if(Platform.isAndroid){
      AndroidIntent intent = const AndroidIntent(
        action: 'android.bluetooth.adapter.action.REQUEST_ENABLE');
      await intent.launch();


    }else if(Platform.isIOS){
      //ios는 해당 블루투스 바로 전환하기가 없으므로 pass
      showToast("블루투스 설정을 켜주세요.");
    }
  }

  /// 신체 연결 다이얼로그 노출 및 선택 시 해당 파트 기기 연결 처리
  /// 1. 기 연결 기기가 있으면 연결 취소 처리
  /// 2. 신규 기기 연결 시도
  /// 3. 연결 실패하면 연결에 실패하였습니다
  /// 4. 연결 성공하면 업데이트
  /// 또는 현재 연결중인 기기중에 현재 선택 기기가 있으면 연결 취소 처리
  Future<void> choiceBodyPosition(BODY_TYPE type, {int? index, required DiscoveredDevice device}) async {
    String? selectedDeviceId = device.id;
    String? selectedDeviceName = device.name;

    /// 기연결 상태면 연결 해제
    if(deviceNeck?.id == selectedDeviceId){
      await disconnect(BODY_TYPE.NECK);
      await Future.delayed(const Duration(milliseconds: 1000),(){});
    }
    if(deviceForehead?.id == selectedDeviceId){
      await disconnect(BODY_TYPE.FOREHEAD);
      await Future.delayed(const Duration(milliseconds: 1000),(){});
    }
    notifyListeners();
    /// 연결 시작
    print("연결 시작");
    if(type == BODY_TYPE.NECK){
      await connectorNeck.connect(selectedDeviceId, selectedDeviceName).then((value){
        print("넥 연결성공");
        final characteristic = QualifiedCharacteristic(
            serviceId: Uuid.parse(SERVICE_UUID_LIST[0]),
            characteristicId: Uuid.parse(TX_UUID_LIST[0]),
            deviceId: selectedDeviceId!);

        serviceDiscoverer.subScribeToCharacteristicNeck(characteristic).asBroadcastStream().listen((data) {
          deviceNeck ??= BleDevice(connectorNeck.connectedDeviceName, connectorNeck.connectedDeviceId, device);
          if(deviceNeck?.deviceName != connectorNeck.connectedDeviceName){
            deviceNeck = BleDevice(connectorNeck.connectedDeviceName, connectorNeck.connectedDeviceId, device);
          }
          DeviceSensorData sensorData = Protocol.buildSensorData(Uint8List.fromList(data));
          deviceNeck?.
          setDeviceResponse(sensorData);
          notifyListeners();
        },onDone: (){
          // showToast("on done");
          deviceNeck = null;
          connectorNeck?.init();
          notifyListeners();
        }, onError: (dynamic error) {
          deviceNeck = null;
          connectorNeck?.init();
          notifyListeners();
        });

      },onError:(err){
        print("넥 연결실패");
        deviceNeck = null;
        connectorNeck?.init();
        notifyListeners();
      });
    }else if(type == BODY_TYPE.FOREHEAD){
      await connectorForehead.connect(selectedDeviceId, selectedDeviceName).then((value){
        print("이마 연결성공");
        final characteristic = QualifiedCharacteristic(
            serviceId: Uuid.parse(SERVICE_UUID_LIST[0]),
            characteristicId: Uuid.parse(TX_UUID_LIST[0]),
            deviceId: selectedDeviceId!);

        serviceDiscoverer.subScribeToCharacteristicForehead(characteristic).asBroadcastStream().listen((data) {
          deviceForehead ??= BleDevice(connectorForehead.connectedDeviceName,
              connectorForehead.connectedDeviceId, device);
          if(deviceForehead?.deviceName != connectorForehead.connectedDeviceName){
            deviceForehead = BleDevice(connectorForehead.connectedDeviceName,
                connectorForehead.connectedDeviceId, device);
          }
          // print("data forehead:${data}");
          DeviceSensorData sensorData = Protocol.buildSensorData(Uint8List.fromList(data));
          deviceForehead?.setDeviceResponse(sensorData);
          notifyListeners();
        },onDone: (){
          deviceForehead = null;
          connectorForehead?.init();
        }, onError: (dynamic error) {
          deviceForehead = null;
          connectorForehead?.init();
        });

      },onError:(err){
        print("이마 연결실패");
        deviceForehead = null;
        connectorForehead?.init();
        notifyListeners();
      });
    }
    notifyListeners();
    return;
  }

  Future<void> toggleDeviceScanning() async{
    print("toggleDeviceScanning");
    if(isDeviceScanning){
      stopDeviceScanning();
    }else{
      startDeviceScanning();
    }
  }

  BODY_TYPE isConnectedDevice(String? deviceId) {
    print("isConnectedDevice ${deviceId} | A1:${deviceNeck?.deviceName??""}|A2:${deviceNeck?.id??""}");
    print("isConnectedDevice ${deviceId} | B1:${deviceForehead?.deviceName??""}|B2:${deviceForehead?.id??""}");
    BODY_TYPE type = BODY_TYPE.NONE;
    // if(deviceId == connectorNeck.connectedDeviceId){
    if(deviceId == (deviceNeck?.id??"")) {
      type = BODY_TYPE.NECK;
    }else if(deviceId == (deviceForehead?.id??"")){
      type = BODY_TYPE.FOREHEAD;
    }
    return type;
  }

  bool checkBluetoothConnection() {
    if(connectorNeck.connectedDeviceId != "" || connectorForehead.connectedDeviceId != ""){
      return true;
    }
    return false;
  }

  Future<void> sendData(BODY_TYPE bodyType, String requestString) async {
    String connectedDeviceId = "";
    if(bodyType == BODY_TYPE.NECK){
      connectedDeviceId = connectorNeck.connectedDeviceId;
    }else if(bodyType == BODY_TYPE.FOREHEAD){
      connectedDeviceId = connectorForehead.connectedDeviceId;
    }
    if(connectedDeviceId == ""){
      return;
    }

    List<int> list = utf8.encode(requestString);
    final characteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(SERVICE_UUID_LIST[0]),
        characteristicId: Uuid.parse(RX_UUID_LIST[0]),
        deviceId: connectedDeviceId);

    flutterReactiveBle.writeCharacteristicWithResponse(characteristic, value: list)
        .asStream().asBroadcastStream().listen((event) {
          print("write c w r");
    });
  }

  String getBatteryValue(int batteryValue) {
    //현재 배터리 상태값 가공
    return ((batteryValue * 0.0032 * 6.9) / 4.7 * 100).toString();
  }

  /// 장치에 배터리값을 변경
  void setBatteryValue(BleDevice bleDevice, String batteryValue) {
    // dPrint("Battery: $batteryValue");
    bleDevice.battery = batteryValue.split(".")[0];
    // dPrint("===setBatteryValue: ${bleDevice.battery}");
    notifyListeners();
  }

  void setPulseValue(BleDevice bleDevice, List<String> pulseValue) {
    bleDevice.pulseSize = pulseValue[0];
    bleDevice.pulseRadius = pulseValue[1];
    bleDevice.pulsePadding = pulseValue[2];
    dPrint("===setPulseValue: size: ${bleDevice.pulseSize}, radius: ${bleDevice.pulseRadius}, Padding: ${bleDevice.pulsePadding}");
  }

  /// 블루투스 데이터 송신 정지
  Future pauseParse() async{
    // _monitoringNeckStreamSubscription?.pause();
    // _monitoringForeheadStreamSubscription?.pause();
  }

  /// 블루투스 데이터 송신 재개
  Future resumeParse() async{
    // _monitoringNeckStreamSubscription?.resume();
    // _monitoringForeheadStreamSubscription?.resume();
  }

  /// 앱 종료시 블루투스 클라이언트 종료
  Future destroyClient() async{
    // await bleManager?.destroyClient();
  }

  /// 5개로 넘어오는 응답을 분리 리턴
  List<Uint8List> divideResponse(Uint8List message) {
    List<Uint8List> list = [];
    for(int i = 0; i < 5; i++){
      list.add(message.sublist(i * 33,  (i + 1)*33));
    }
    return list;
  }

  Future<void> disconnect(BODY_TYPE type) async {
    // if(type == BODY_TYPE.NECK && deviceNeck != null){
    if(type == BODY_TYPE.NECK){
      await connectorNeck?.disconnect(deviceNeck!.id);
      deviceNeck = null;
      connectorNeck.init();
    // }else if(type == BODY_TYPE.FOREHEAD && deviceForehead != null){
    }else if(type == BODY_TYPE.FOREHEAD){
      await connectorForehead?.disconnect(deviceForehead!.id);
      deviceForehead = null;
      connectorForehead.init();
    }
    await Future.delayed(Duration(milliseconds: 100));
    notifyListeners();
  }
}

