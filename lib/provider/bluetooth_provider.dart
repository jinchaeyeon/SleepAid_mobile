import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ble_lib_ios_15/flutter_ble_lib.dart';
import 'package:permission_handler/permission_handler.dart';
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
  static const int SENSOR_LEN = 1000;
  BleManager bleManager = BleManager();
  List<BleDevice> deviceList = []; //전체 검색되는 장치목록
  BleDevice? connectedDeviceForNeck; //목 연결 장치
  BleDevice? connectedDeviceForForehead; //이마 연결장치

  static StreamSubscription? notifyNeckStream;
  static StreamSubscription? monitoringNeckStream;
  static StreamSubscription? notifyForeheadStream;

  bool isDeviceScanning = false; //장치스캔
  bool isDataScanning = false; //장치에서 데이터 스캔

  StreamSubscription? _monitoringNeckStreamSubscription; // 데이터 응답 스트림 구독
  StreamSubscription? _monitoringForeheadStreamSubscription;  // 데이터 응답 스트림 구독

  /// 로그아웃시, 블룰투스 관련 데이터 초기화
  Future<void> clearBluetooth() async{
    deviceList.clear();
    connectedDeviceForNeck = null;
    connectedDeviceForForehead = null;
  }

  ///기기가 연결되어 있으면 데이터 수집/비수집 전환한다
  Future<void> toggleDataCollecting() async{
    if(isDataScanning){
      isDataScanning = false;
    }else{
      isDataScanning = true;
    }
    notifyListeners();
  }

  ///블루투스 장치 스캔(회사목록만)
  Future<void> startDeviceScanning() async {
    isDeviceScanning = true;
    dPrint("startDeviceScanning");
    await bleManager.createClient(
        restoreStateIdentifier: "restore-id",
        restoreStateAction: (peripherals) {
          for (var peripherals in peripherals) {
            dPrint("Restored peripheral: ${peripherals.name}");
          }
          notifyListeners();
        });

    bleManager.startPeripheralScan(
      uuids: SERVICE_UUID_LIST,
    ).listen((scanResult) {
      //실시간 스캔
      //같은 id를 가졌으면 추가하지 않는다
      bool isAleadyExist = false;
      for (var device in deviceList) {
        if(device.peripheral.identifier == scanResult.peripheral.identifier){
          isAleadyExist = true;
          //중복이면 업데이트
          device.peripheral = scanResult.peripheral;
          device.advertisementData = scanResult.advertisementData;
          notifyListeners();
        }
      }
      if(!isAleadyExist){
        //중복 아니면 추가
        var name = scanResult.peripheral.name ?? scanResult.advertisementData.localName ?? "Unknown";

        if (name.contains("NEUROTX")) {
          deviceList.add(BleDevice(name,scanResult.rssi, scanResult.peripheral, scanResult.advertisementData));
          notifyListeners();
        }
      }
      notifyListeners();
    });

    await bleManager.connectedPeripherals(SERVICE_UUID_LIST).then((List<Peripheral> connectedDeviceList) {
      connectedDeviceList.forEach((device) {
        dPrint("Connected List device: ${device.name}");
      });
    });

    Future.delayed(Duration(seconds: 20), (){ stopDeviceScanning();   });
  }

  ///스캔 끝나면 꼭 stop처리
  Future<void> stopDeviceScanning() async {
    dPrint("stopDeviceScanning");
    isDeviceScanning = false;
    // deviceList.clear();
    bleManager.stopPeripheralScan();
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
    await [Permission.location, Permission.bluetooth, Permission.bluetoothConnect].request();
    // await [Permission.location, Permission.bluetoothConnect].request();
    if(
    statuses[Permission.location] == PermissionStatus.denied ||
        statuses[Permission.bluetoothConnect] == PermissionStatus.denied
    ){
      showToast("앱 설정에서 필수 권한을 설정해주세요");
      if(retryCount == 1){
        completedExit(null);
      }else{
        await AppSettings.openAppSettings();
        checkBluetoothPermission(retryCount: 1);
      }
    }
  }

  /// 신체 연결 다이얼로그 노출 및 선택 시 해당 파트 기기 연결 처리
  /// 1. 기 연결 기기가 있음면 연결 취소 처리
  /// 2. 신규 기기 연결 시도
  /// 3. 연결 실패하면 연결에 실패하였습니다
  /// 4. 연결 성공하면 업데이트
  Future<void> choiceBodyPosition(BODY_TYPE type,BleDevice device) async {
    Peripheral peripheral = device.peripheral;

    /// 또는 현재 연결중인 기기중에 현재 선택 기기가 있으면 연결 취소 처리
    if(connectedDeviceForNeck?.peripheral.identifier == peripheral.identifier){
      await connectedDeviceForNeck?.peripheral.disconnectOrCancelConnection();
      await notifyNeckStream?.cancel();
      connectedDeviceForNeck = null;
    }
    if(connectedDeviceForForehead?.peripheral.identifier == peripheral.identifier){
      await connectedDeviceForForehead?.peripheral.disconnectOrCancelConnection();
      await notifyForeheadStream?.cancel();
      connectedDeviceForForehead = null;
    }
    /// 해당 슬롯에 기 연결 기기가 있음면 연결 취소 처리
    if(type == BODY_TYPE.NECK){
      await connectedDeviceForNeck?.peripheral.disconnectOrCancelConnection();
      await notifyNeckStream?.cancel();
      connectedDeviceForNeck = null;
    }
    if(type == BODY_TYPE.FOREHEAD){
      await connectedDeviceForForehead?.peripheral.disconnectOrCancelConnection();
      await notifyForeheadStream?.cancel();
      connectedDeviceForForehead = null;
    }

    /// 2. 신규 기기 연결 시도
    if(type == BODY_TYPE.NECK){
      notifyNeckStream = peripheral
          .observeConnectionState(emitCurrentValue: true)
          .listen((PeripheralConnectionState connectionState) {
        device.setState(connectionState);
        switch (connectionState) {
          case PeripheralConnectionState.connected:
            {
              //연결됨
              connectedDeviceForNeck = device;
              peripheral.discoverAllServicesAndCharacteristics().whenComplete(() {
                /// 기존 연결장치 해제
                // await connectedDeviceForNeck?.peripheral.disconnectOrCancelConnection();
                /// 장치 변수에 할당
                connectedDeviceForNeck?.peripheral = peripheral;

                Stream<Uint8List> characteristic = peripheral.monitorCharacteristic(
                    SERVICE_UUID_LIST[0],
                    TX_UUID_LIST[0],
                    transactionId: "monitor-neck"
                ).map((characteristic) => characteristic.value);
                _monitoringNeckStreamSubscription = characteristic.listen((Uint8List message) {
                  // print("monitoring messagex:: $message");
                  List<Uint8List> responses = divideResponse(message);

                  responses.forEach((Uint8List response) {
                    String batteryValue = Protocol.getBatteryValue(response);
                    setBatteryValue(connectedDeviceForNeck!, batteryValue);

                    DeviceSensorData sensorData = Protocol.buildSensorData(response);
                    setDeviceResponse(connectedDeviceForNeck!, sensorData);

                    // List<double> eegValue = Protocol.getEEGValue(brainSignalList);
                    // setEEGValue(connectedDeviceForNeck!, eegValue);
                    //
                    // List<double> actValue = Protocol.getAccelerometerValue(message, sensorData);
                    // setAccelerometerValue(connectedDeviceForNeck!, actValue);
                    //
                    // List<String> pulseValue = Protocol.getPulseSizes(sensorData);
                    // setPulseValue(connectedDeviceForNeck!, pulseValue);

                    notifyListeners();
                  });
                }, onError: (error){
                  dPrint("notifyNeckStream error:: $error");
                  // 기기 연결 이슈가 생겼으므로 재연결 다이얼로그 보여준다
                  device.setState(PeripheralConnectionState.disconnected);
                } ,cancelOnError: true);
              });
            }
            break;
          case PeripheralConnectionState.connecting:
            {
              //  setBLEState('connecting');
            } //연결중
            break;
          case PeripheralConnectionState.disconnected:
            {
              //해제됨
              dPrint("disconnected!");
              connectedDeviceForNeck?.resetData();
            }
            break;
          case PeripheralConnectionState.disconnecting:
            {
              // setBLEState('disconnecting');
            } //해제중
            break;
          default:{}
          break;
        }
      });

      notifyNeckStream?.onDone(() {
        showToast("DONE TRY RECONNECT");
      });
      notifyNeckStream?.onError((handleError) {
        dPrint("error:"+handleError.toString());
        showToast("ERRROR TRY RECONNECT");
      });
      _monitoringNeckStreamSubscription?.onDone(() {
        showToast("DONE TRY RECONNECT2");
      });
      _monitoringNeckStreamSubscription?.onError((handleError){
        showToast("ERRROR TRY RECONNECT2");
      });

    }else if(type == BODY_TYPE.FOREHEAD){
      notifyForeheadStream = peripheral
          .observeConnectionState(emitCurrentValue: true)
          .listen((PeripheralConnectionState connectionState) {
        device.setState(connectionState);
        switch (connectionState) {
          case PeripheralConnectionState.connected:
            {
              //연결됨
              connectedDeviceForForehead = device;
              peripheral.discoverAllServicesAndCharacteristics().whenComplete(() {
                /// 기존 연결장치 해제
                // await connectedDeviceForNeck?.peripheral.disconnectOrCancelConnection();
                /// 장치 변수에 할당
                connectedDeviceForForehead?.peripheral = peripheral;

                Stream<Uint8List> characteristic = peripheral.monitorCharacteristic(
                    SERVICE_UUID_LIST[0],
                    TX_UUID_LIST[0],
                    transactionId: "monitor-forehead"
                ).map((characteristic) => characteristic.value);

                _monitoringForeheadStreamSubscription = characteristic.listen((Uint8List message) {
                  print("monitoring message:: $message");
                  List<Uint8List> responses = divideResponse(message);
                  responses.forEach((Uint8List response) {
                    String batteryValue = Protocol.getBatteryValue(response);
                    setBatteryValue(connectedDeviceForForehead!, batteryValue);

                    DeviceSensorData sensorData = Protocol.buildSensorData(response);


                    // List<String> brainSignalList = Protocol.buildBrainSignalList(sensorData);
                    // double ppgValue = Protocol.getPPGValue(brainSignalList);
                    // setPPGValue(connectedDeviceForNeck!, ppgValue);
                    // List<double> eegValue = Protocol.getEEGValue(brainSignalList);
                    // setEEGValue(connectedDeviceForNeck!, eegValue);
                    //
                    // List<double> actValue = Protocol.getAccelerometerValue(message, sensorData);
                    // setAccelerometerValue(connectedDeviceForNeck!, actValue);
                    //
                    // List<String> pulseValue = Protocol.getPulseSizes(sensorData);
                    // setPulseValue(connectedDeviceForNeck!, pulseValue);

                    notifyListeners();
                  });

                  // String batteryValue = Protocol.getBatteryValue(message);
                  // setBatteryValue(connectedDeviceForForehead!, batteryValue);
                  //
                  // String brainSignal = Protocol.buildSensorData(message);
                  //
                  // List<String> brainSignalList = Protocol.buildBrainSignalList(brainSignal);
                  // double ppgValue = Protocol.getPPGValue(brainSignalList);
                  // setPPGValue(connectedDeviceForForehead!, ppgValue);
                  // List<double> eegValue = Protocol.getEEGValue(brainSignalList);
                  // setEEGValue(connectedDeviceForForehead!, eegValue);
                  //
                  // List<double> actValue = Protocol.getAccelerometerValue(message, brainSignal);
                  // setAccelerometerValue(connectedDeviceForForehead!, actValue);
                  //
                  // List<String> pulseValue = Protocol.getPulseSizes(brainSignal);
                  // setPulseValue(connectedDeviceForForehead!, pulseValue);
                  //
                  // notifyListeners();






                }, onError: (error){
                  dPrint("notifyForeheadStream error:: $error");
                  device.setState(PeripheralConnectionState.disconnected);
                } ,cancelOnError: true);
              });
            }
            break;
          case PeripheralConnectionState.connecting:
            {
              //  setBLEState('connecting');
            } //연결중
            break;
          case PeripheralConnectionState.disconnected:
            {
              //해제됨
              dPrint("disconnected!");
              connectedDeviceForForehead?.resetData();
            }
            break;
          case PeripheralConnectionState.disconnecting:
            {
              // setBLEState('disconnecting');
            } //해제중
            break;
          default:{}
          break;
        }
      });

      notifyForeheadStream?.onDone(() {
        showToast("DONE TRY RECONNECT");
      });
      notifyForeheadStream?.onError((handleError) {
        dPrint("error:"+handleError.toString());
        showToast("ERRROR TRY RECONNECT");
      });

      _monitoringForeheadStreamSubscription?.onDone(() {
        showToast("DONE TRY RECONNECT2");
      });
      _monitoringForeheadStreamSubscription?.onError((handleError){
        showToast("ERRROR TRY RECONNECT2");
      });
    }

    bool isConnected = await peripheral.isConnected();
    if (isConnected) {
      showToast("Device is Already Connected");
      return;
    }

    await peripheral.connect(isAutoConnect: true, refreshGatt: true);
    notifyListeners();

    return;
  }

  Future<void> toggleDeviceScanning() async{
    if(isDeviceScanning){
      stopDeviceScanning();
    }else{
      startDeviceScanning();
    }
  }

  BODY_TYPE isConnectedDevice(BleDevice device) {
    if(device.peripheral.identifier == connectedDeviceForNeck?.peripheral.identifier){
      return BODY_TYPE.NECK;
    }else if(device.peripheral.identifier == connectedDeviceForForehead?.peripheral.identifier){
      return BODY_TYPE.FOREHEAD;
    }else{
      return BODY_TYPE.NONE;
    }
  }

  bool checkBluetoothConnection() {
    if(connectedDeviceForNeck != null || connectedDeviceForForehead != null){
      return true;
    }
    return false;
  }

  void sendData(BleDevice? device, String requestString) {
    if(device!=null){
      print("requestString:$requestString");
      List<int> list = utf8.encode(requestString);
      print("request list:$list");
      Uint8List bytes = Uint8List.fromList(list);
      print("sendData: $bytes");
      device.peripheral.writeCharacteristic(SERVICE_UUID_LIST[0], RX_UUID_LIST[0], bytes, true);
    }
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
    _monitoringNeckStreamSubscription?.pause();
    _monitoringForeheadStreamSubscription?.pause();
  }

  /// 블루투스 데이터 송신 재개
  Future resumeParse() async{
    _monitoringNeckStreamSubscription?.resume();
    _monitoringForeheadStreamSubscription?.resume();
  }

  /// 앱 종료시 블루투스 클라이언트 종료
  Future destroyClient() async{
    await bleManager?.destroyClient();
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

