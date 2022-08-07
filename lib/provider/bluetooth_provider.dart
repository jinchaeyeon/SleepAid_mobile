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
  static const int SENSOR_LEN = 1000;

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
    // if(isDataScanning){
    //   isDataScanning = false;
    // }else{
    //   isDataScanning = true;
    // }
    // notifyListeners();
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

  /// AOS 12대응
  /// 12 이상에서는
  /// if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
  // 	requestMultiplePermissions.launch(arrayOf(
  //     	Manifest.permission.BLUETOOTH_SCAN,
  //         Manifest.permission.BLUETOOTH_CONNECT))
  //     }
  //     else{
  //     	val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
  //         requestBluetooth.launch(enableBtIntent)
  // }
  ///todo 12 이하에서는 LOCATION 도 필요
  ///todo IOS 는 별도로 체크 한번 더 필요
  ///전체적으로 버전별 체크 한번 필요
  Future<void> checkBluetoothPermission({int retryCount = 0}) async {
    print("checkBluetoothPermission $retryCount");
    Map<Permission, PermissionStatus> statuses =
    await [Permission.location, Permission.bluetooth, Permission.bluetoothConnect, Permission.bluetoothScan].request();
    // await [Permission.location, Permission.bluetoothConnect].request();
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
  Future<void> choiceBodyPosition(BODY_TYPE type, {int? index, AsyncSnapshot? snapshot, BleDevice? device}) async {
    String? selectedDeviceId = "";

    if(snapshot is AsyncSnapshot<ConnectionStateUpdate>){
      selectedDeviceId = snapshot.data!.deviceId;
    }else if(snapshot is AsyncSnapshot<BleScannerState>){
      selectedDeviceId = snapshot.data!.discoveredDevices[index??0].id;
    }

    if(connectorNeck.connectedDeviceId == selectedDeviceId){
      await connectorNeck.disconnect(connectorNeck.connectedDeviceId);
    }
    if(connectorForehead.connectedDeviceId == selectedDeviceId){
      await connectorForehead.disconnect(connectorForehead.connectedDeviceId);
    }

    if(selectedDeviceId != null){
      await flutterReactiveBle.requestMtu(deviceId: selectedDeviceId, mtu: MTU);

      if(type == BODY_TYPE.NECK){
        await connectorNeck.connect(selectedDeviceId).then((value){
          final characteristic = QualifiedCharacteristic(
              serviceId: Uuid.parse(SERVICE_UUID_LIST[0]),
              characteristicId: Uuid.parse(TX_UUID_LIST[0]),
              deviceId: selectedDeviceId!);

          serviceDiscoverer.subScribeToCharacteristicNeck(characteristic).asBroadcastStream().listen((data) {
            deviceNeck ??= BleDevice(connectorNeck.connectedDeviceName, connectorNeck.connectedDeviceName);
            print("data neck :${data}");
          },onDone: (){
            // showToast("on done");
            deviceNeck = null;
            notifyListeners();
          }, onError: (dynamic error) {
            deviceNeck = null;
            notifyListeners();
          });

        },onError:(err){
          showToast("error");
        });
      }else if(type == BODY_TYPE.FOREHEAD){
        await connectorForehead.connect(selectedDeviceId).then((value){
          final characteristic = QualifiedCharacteristic(
              serviceId: Uuid.parse(SERVICE_UUID_LIST[0]),
              characteristicId: Uuid.parse(TX_UUID_LIST[0]),
              deviceId: selectedDeviceId!);

          serviceDiscoverer.subScribeToCharacteristicForehead(characteristic).asBroadcastStream().listen((data) {
            deviceForehead ??= BleDevice(connectorForehead.connectedDeviceName, connectorForehead.connectedDeviceName);
            print("data forehead:${data}");
          },onDone: (){
            deviceForehead = null;
          }, onError: (dynamic error) {
            deviceForehead = null;
          });

        },onError:(err){
          showToast("error");
        });
      }
    }


    // if(connectedDeviceForNeck?.id == device.id){
    //   await connectedDeviceForNeck?.peripheral.disconnectOrCancelConnection();
    //   await notifyNeckStream?.cancel();
    //   connectedDeviceForNeck = null;
    // }
    // if(connectedDeviceForForehead?.peripheral.identifier == peripheral.identifier){
    //   await connectedDeviceForForehead?.peripheral.disconnectOrCancelConnection();
    //   await notifyForeheadStream?.cancel();
    //   connectedDeviceForForehead = null;
    // }
    // /// 해당 슬롯에 기 연결 기기가 있음면 연결 취소 처리
    // if(type == BODY_TYPE.NECK){
    //   await connectedDeviceForNeck?.peripheral.disconnectOrCancelConnection();
    //   await notifyNeckStream?.cancel();
    //   connectedDeviceForNeck = null;
    // }
    // if(type == BODY_TYPE.FOREHEAD){
    //   await connectedDeviceForForehead?.peripheral.disconnectOrCancelConnection();
    //   await notifyForeheadStream?.cancel();
    //   connectedDeviceForForehead = null;
    // }
    //
    // /// 2. 신규 기기 연결 시도
    // if(type == BODY_TYPE.NECK){
    //   notifyNeckStream = peripheral
    //       .observeConnectionState(emitCurrentValue: true)
    //       .listen((PeripheralConnectionState connectionState) {
    //     device.setState(connectionState);
    //     switch (connectionState) {
    //       case PeripheralConnectionState.connected:
    //         {
    //           //연결됨
    //           connectedDeviceForNeck = device;
    //           peripheral.discoverAllServicesAndCharacteristics().whenComplete(() {
    //             /// 기존 연결장치 해제
    //             // await connectedDeviceForNeck?.peripheral.disconnectOrCancelConnection();
    //             /// 장치 변수에 할당
    //             connectedDeviceForNeck?.peripheral = peripheral;
    //
    //             Stream<Uint8List> characteristic = peripheral.monitorCharacteristic(
    //                 SERVICE_UUID_LIST[0],
    //                 TX_UUID_LIST[0],
    //                 transactionId: "monitor-neck"
    //             ).map((characteristic) => characteristic.value);
    //             _monitoringNeckStreamSubscription = characteristic.listen((Uint8List message) {
    //               // print("monitoring messagex:: $message");
    //               List<Uint8List> responses = divideResponse(message);
    //
    //               responses.forEach((Uint8List response) {
    //                 String batteryValue = Protocol.getBatteryValue(response);
    //                 setBatteryValue(connectedDeviceForNeck!, batteryValue);
    //
    //                 DeviceSensorData sensorData = Protocol.buildSensorData(response);
    //                 setDeviceResponse(connectedDeviceForNeck!, sensorData);
    //
    //                 // List<double> eegValue = Protocol.getEEGValue(brainSignalList);
    //                 // setEEGValue(connectedDeviceForNeck!, eegValue);
    //                 //
    //                 // List<double> actValue = Protocol.getAccelerometerValue(message, sensorData);
    //                 // setAccelerometerValue(connectedDeviceForNeck!, actValue);
    //                 //
    //                 // List<String> pulseValue = Protocol.getPulseSizes(sensorData);
    //                 // setPulseValue(connectedDeviceForNeck!, pulseValue);
    //
    //                 notifyListeners();
    //               });
    //             }, onError: (error){
    //               dPrint("notifyNeckStream error:: $error");
    //               // 기기 연결 이슈가 생겼으므로 재연결 다이얼로그 보여준다
    //               device.setState(PeripheralConnectionState.disconnected);
    //             } ,cancelOnError: true);
    //           });
    //         }
    //         break;
    //       case PeripheralConnectionState.connecting:
    //         {
    //           //  setBLEState('connecting');
    //         } //연결중
    //         break;
    //       case PeripheralConnectionState.disconnected:
    //         {
    //           //해제됨
    //           dPrint("disconnected!");
    //           connectedDeviceForNeck?.resetData();
    //         }
    //         break;
    //       case PeripheralConnectionState.disconnecting:
    //         {
    //           // setBLEState('disconnecting');
    //         } //해제중
    //         break;
    //       default:{}
    //       break;
    //     }
    //   });
    //
    //   notifyNeckStream?.onDone(() {
    //     showToast("DONE TRY RECONNECT");
    //   });
    //   notifyNeckStream?.onError((handleError) {
    //     dPrint("error:"+handleError.toString());
    //     showToast("ERRROR TRY RECONNECT");
    //   });
    //   _monitoringNeckStreamSubscription?.onDone(() {
    //     showToast("DONE TRY RECONNECT2");
    //   });
    //   _monitoringNeckStreamSubscription?.onError((handleError){
    //     showToast("ERRROR TRY RECONNECT2");
    //   });
    //
    // }else if(type == BODY_TYPE.FOREHEAD){
    //   notifyForeheadStream = peripheral
    //       .observeConnectionState(emitCurrentValue: true)
    //       .listen((PeripheralConnectionState connectionState) {
    //     device.setState(connectionState);
    //     switch (connectionState) {
    //       case PeripheralConnectionState.connected:
    //         {
    //           //연결됨
    //           connectedDeviceForForehead = device;
    //           peripheral.discoverAllServicesAndCharacteristics().whenComplete(() {
    //             /// 기존 연결장치 해제
    //             // await connectedDeviceForNeck?.peripheral.disconnectOrCancelConnection();
    //             /// 장치 변수에 할당
    //             connectedDeviceForForehead?.peripheral = peripheral;
    //
    //             Stream<Uint8List> characteristic = peripheral.monitorCharacteristic(
    //                 SERVICE_UUID_LIST[0],
    //                 TX_UUID_LIST[0],
    //                 transactionId: "monitor-forehead"
    //             ).map((characteristic) => characteristic.value);
    //             _monitoringForeheadStreamSubscription = characteristic.listen((Uint8List message) {
    //               // print("monitoring messagex:: $message");
    //               List<Uint8List> responses = divideResponse(message);
    //
    //               responses.forEach((Uint8List response) {
    //                 String batteryValue = Protocol.getBatteryValue(response);
    //                 setBatteryValue(connectedDeviceForForehead!, batteryValue);
    //
    //                 DeviceSensorData sensorData = Protocol.buildSensorData(response);
    //                 setDeviceResponse(connectedDeviceForForehead!, sensorData);
    //
    //                 // List<double> eegValue = Protocol.getEEGValue(brainSignalList);
    //                 // setEEGValue(connectedDeviceForNeck!, eegValue);
    //                 //
    //                 // List<double> actValue = Protocol.getAccelerometerValue(message, sensorData);
    //                 // setAccelerometerValue(connectedDeviceForNeck!, actValue);
    //                 //
    //                 // List<String> pulseValue = Protocol.getPulseSizes(sensorData);
    //                 // setPulseValue(connectedDeviceForNeck!, pulseValue);
    //
    //                 notifyListeners();
    //               });
    //             }, onError: (error){
    //               dPrint("notifyForeheadStream error:: $error");
    //               // 기기 연결 이슈가 생겼으므로 재연결 다이얼로그 보여준다
    //               device.setState(PeripheralConnectionState.disconnected);
    //             } ,cancelOnError: true);
    //           });
    //         }
    //         break;
    //       case PeripheralConnectionState.connecting:
    //         {
    //           //  setBLEState('connecting');
    //         } //연결중
    //         break;
    //       case PeripheralConnectionState.disconnected:
    //         {
    //           //해제됨
    //           dPrint("disconnected!");
    //           connectedDeviceForNeck?.resetData();
    //         }
    //         break;
    //       case PeripheralConnectionState.disconnecting:
    //         {
    //           // setBLEState('disconnecting');
    //         } //해제중
    //         break;
    //       default:{}
    //       break;
    //     }
    //   });
    //
    //   notifyNeckStream?.onDone(() {
    //     showToast("DONE TRY RECONNECT");
    //   });
    //   notifyNeckStream?.onError((handleError) {
    //     dPrint("error:"+handleError.toString());
    //     showToast("ERRROR TRY RECONNECT");
    //   });
    //   _monitoringNeckStreamSubscription?.onDone(() {
    //     showToast("DONE TRY RECONNECT2");
    //   });
    //   _monitoringNeckStreamSubscription?.onError((handleError){
    //     showToast("ERRROR TRY RECONNECT2");
    //   });
    // }
    //
    // bool isConnected = await peripheral.isConnected();
    // if (isConnected) {
    //   showToast("Device is Already Connected");
    //   return;
    // }
    //
    // await peripheral.connect(isAutoConnect: true, refreshGatt: true);
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
    BODY_TYPE type = BODY_TYPE.NONE;
    if(deviceId == connectorNeck.connectedDeviceId){
      type = BODY_TYPE.NECK;
    }else if(deviceId == connectorForehead.connectedDeviceId){
      type = BODY_TYPE.FOREHEAD;
    }
    print("isConnectedDevice: ${deviceId} | ${type}");
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

    await flutterReactiveBle.writeCharacteristicWithResponse(characteristic, value: list)
        .asStream().asBroadcastStream().listen((event) {
          print("write c w r ");
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

  /// 기기에서 가져온 데이터 저장
  void setDeviceResponse(BleDevice bleDevice, DeviceSensorData data) {
    while(bleDevice.sensors.length > SENSOR_LEN) {
      bleDevice.sensors.removeRange(0, SENSOR_LEN ~/ 10);
    }
    bleDevice.sensors.add(data);
    return;
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
}

