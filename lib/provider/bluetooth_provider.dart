import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ble_lib_ios_15/flutter_ble_lib.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sleepaid/bluetooth/protocol.dart';
import 'package:sleepaid/data/ble_device.dart';
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
    print("startDeviceScanning");
    await bleManager.createClient(
        restoreStateIdentifier: "restore-id",
        restoreStateAction: (peripherals) {
          for (var peripherals in peripherals) {
            print("Restored peripheral: ${peripherals.name}");
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
        print("Connected List device: ${device.name}");
      });
    });

    Future.delayed(Duration(seconds: 20), (){ stopDeviceScanning();   });
  }

  ///스캔 끝나면 꼭 stop처리
  Future<void> stopDeviceScanning() async {
    print("stopDeviceScanning");
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
  Future<void> checkBluetoothPermission() async {
    Map<Permission, PermissionStatus> statuses =
    await [Permission.location, Permission.bluetooth].request();
    if(
    statuses[Permission.location] == PermissionStatus.denied ||
        statuses[Permission.bluetooth] == PermissionStatus.denied
    ){
      completedExit(null);
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
        log("state: ${connectionState.index}");
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
                  print("monitoring message:: $message");
                  String batteryValue = Protocol.getBatteryValue(message);
                  setBatteryValue(connectedDeviceForNeck!, batteryValue);

                  String brainSignal = Protocol.buildBrainSignal(message);

                  List<String> brainSignalList = Protocol.buildBrainSignalList(brainSignal);
                  double ppgValue = Protocol.getPPGValue(brainSignalList);
                  setPPGValue(connectedDeviceForNeck!, ppgValue);
                  List<double> eegValue = Protocol.getEEGValue(brainSignalList);
                  setEEGValue(connectedDeviceForNeck!, eegValue);

                  List<double> actValue = Protocol.getAccelerometerValue(message, brainSignal);
                  setAccelerometerValue(connectedDeviceForNeck!, actValue);

                  List<String> pulseValue = Protocol.getPulseSizes(brainSignal);
                  setPulseValue(connectedDeviceForNeck!, pulseValue);

                  notifyListeners();
                }, onError: (error){
                  log("notifyNeckStream error:: $error");
                  // 기기 연결 이슈가 생겼으므로 재연결 다이얼로그 보여준다
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
              log("disconnected!");
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

      notifyNeckStream?.onError((handleError) {
        log("error:"+handleError.toString());
      });
    }else if(type == BODY_TYPE.FOREHEAD){
      notifyForeheadStream = peripheral
          .observeConnectionState(emitCurrentValue: true)
          .listen((PeripheralConnectionState connectionState) {
        log("state: ${connectionState.index}");
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
                  String batteryValue = Protocol.getBatteryValue(message);
                  setBatteryValue(connectedDeviceForForehead!, batteryValue);

                  String brainSignal = Protocol.buildBrainSignal(message);

                  List<String> brainSignalList = Protocol.buildBrainSignalList(brainSignal);
                  double ppgValue = Protocol.getPPGValue(brainSignalList);
                  setPPGValue(connectedDeviceForForehead!, ppgValue);
                  List<double> eegValue = Protocol.getEEGValue(brainSignalList);
                  setEEGValue(connectedDeviceForForehead!, eegValue);

                  List<double> actValue = Protocol.getAccelerometerValue(message, brainSignal);
                  setAccelerometerValue(connectedDeviceForForehead!, actValue);

                  List<String> pulseValue = Protocol.getPulseSizes(brainSignal);
                  setPulseValue(connectedDeviceForForehead!, pulseValue);

                  notifyListeners();
                }, onError: (error){
                  log("notifyForeheadStream error:: $error");
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
              log("disconnected!");
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

      notifyForeheadStream?.onError((handleError) {
        log("error:"+handleError.toString());
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

    // BleDevice newDevice = BleDevice(device.deviceName,device.rssi, device.peripheral, device.advertisementData);
    // if(type == BODY_TYPE.NECK){
    //   /// 블루투스 기기에 연결시도
    //   await newDevice.peripheral.connect(isAutoConnect: true).whenComplete(() async {
    //     if(await newDevice.peripheral.isConnected()){
    //       print("newDevice isConnected");
    //       showToast("기기 연결 성공");
    //     }else{
    //       print("newDevice is not Connected");
    //       showToast("기기 연결 실패");
    //       return;
    //     }
    //     // await device.peripheral.discoverAllServicesAndCharacteristics();
    //     /// 장치 변수에 할당
    //     connectedDeviceForNeck = newDevice;
    //
    //     notifyNeckStream?.cancel();
    //     notifyNeckStream = connectedDeviceForNeck!.peripheral
    //         .observeConnectionState(emitCurrentValue: true)
    //         .listen((PeripheralConnectionState connectionState) async {
    //
    //           connectedDeviceForNeck!.state = connectionState;
    //           if(device.state == PeripheralConnectionState.connected){
    //             await device.peripheral.discoverAllServicesAndCharacteristics();
    //
    //             notifyNeckStream = connectedDeviceForNeck!.peripheral.monitorCharacteristic(
    //                 SERVICE_UUID_LIST[0],
    //                 TX_UUID_LIST[0],
    //                 transactionId: "monitor"
    //             ).listen((task) {
    //               Uint8List message = task.value;
    //               print("neck message: ${message}");
    //               String batteryValue = Protocol.getBatteryValue(message);
    //               setBatteryValue(connectedDeviceForNeck!, batteryValue);
    //               double ppgValue = Protocol.getPPGValue(message);
    //               setPPGValue(connectedDeviceForNeck!, ppgValue);
    //               notifyListeners();
    //               // String eegValue = Protocol.getEEGValue(message);
    //               // setEEGValue(connectedDeviceForNeck!, eegValue);
    //
    //
    //             }, onError: (error){
    //               print("notifyNeckStream error:: $error");
    //             } ,cancelOnError: true);
    //           }
    //     });
    //   });
    // }else if(type == BODY_TYPE.FOREHEAD){
    //   // 이마에 연결된 기기를 목에 연결시 / 목연결 기기를 이마에 연결시 기존 연결 취소 처리
    //   /// 블루투스 기기에 연결시도
    //   newDevice.peripheral.connect(isAutoConnect: true).whenComplete(() async {
    //     if(await newDevice.peripheral.isConnected()){
    //       print("newDevice isConnected");
    //       showToast("기기 연결 성공");
    //     }else{
    //       print("newDevice is not Connected");
    //       showToast("기기 연결 실패");
    //       return;
    //     }
    //     // await device.peripheral.discoverAllServicesAndCharacteristics();
    //     /// 장치 변수에 할당
    //     connectedDeviceForForehead = newDevice;
    //
    //     notifyForeheadStream?.cancel();
    //     notifyForeheadStream = connectedDeviceForForehead!.peripheral
    //         .observeConnectionState(emitCurrentValue: true)
    //         .listen((PeripheralConnectionState connectionState) async {
    //
    //       connectedDeviceForForehead!.state = connectionState;
    //       if(device.state == PeripheralConnectionState.connected){
    //         await connectedDeviceForForehead!.peripheral.discoverAllServicesAndCharacteristics();
    //
    //         notifyForeheadStream = connectedDeviceForForehead!.peripheral.monitorCharacteristic(
    //             SERVICE_UUID_LIST[0],
    //             TX_UUID_LIST[0],
    //             transactionId: "monitor"
    //         ).listen((task) {
    //           Uint8List message = task.value;
    //           print("forehead message: ${message}");
    //           String batteryValue = Protocol.getBatteryValue(message);
    //           setBatteryValue(connectedDeviceForForehead!, batteryValue);
    //           double ppgValue = Protocol.getPPGValue(message);
    //           setPPGValue(connectedDeviceForForehead!, ppgValue);
    //           notifyListeners();
    //
    //         }, onError: (error){
    //           print("notifyForeheadStream error:: $error");
    //         } ,cancelOnError: true);
    //       }
    //     });
    //   });
    // }
    // device.peripheral.observeConnectionState(emitCurrentValue: true, completeOnDisconnect: true)
    //     .listen((connectionState) {
    //   device.setState(connectionState);
    // });
    //
    // notifyListeners();
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

  String getBatteryValue(int batteryValue) {
    //현재 배터리 상태값 가공
    return ((batteryValue * 0.0032 * 6.9) / 4.7 * 100).toString();
  }

  /// 장치에 배터리값을 변경
  void setBatteryValue(BleDevice bleDevice, String batteryValue) {
    print("Battery: $batteryValue");
    bleDevice.battery = batteryValue.split(".")[0];
    log("===setBatteryValue: ${bleDevice.battery}");
    notifyListeners();
  }

  /// ppg 신호 로컬 저장
  /// todo n개 모으면 서버 전송 처리 추가
  void setPPGValue(BleDevice bleDevice, double ppgValue) {
    if(bleDevice.ppg.length > 200) {
      bleDevice.ppg.removeAt(0);
    }
    bleDevice.ppg.add(ppgValue);
    print("===setPPGValue: ${bleDevice.ppg}");
    return;
  }

  /// ppg 신호 로컬 저장
  /// todo n개 모으면 서버 전송 처리 추가
  void setEEGValue(BleDevice bleDevice, List<double> eegValue) {
    if(bleDevice.eeg.length > 40) {
      bleDevice.eeg.removeAt(0);
    }
    bleDevice.eeg.add(eegValue[0]);
    bleDevice.eeg.add(eegValue[1]);

    print("===setEEGValue: ${bleDevice.eeg}");
    return;
  }

  /// 가속도 신호 로컬 저장
  void setAccelerometerValue(BleDevice bleDevice, List<double> actValue) {
    while(bleDevice.actX.length > 200) {
      bleDevice.actX.removeAt(0);
    }
    while(bleDevice.actY.length > 200) {
      bleDevice.actY.removeAt(0);
    }
    while(bleDevice.actZ.length > 200) {
      bleDevice.actZ.removeAt(0);
    }
    bleDevice.actX.add(actValue[0]);
    bleDevice.actY.add(actValue[1]);
    bleDevice.actZ.add(actValue[2]);

    print("===setAccelerometerValue Xs: ${bleDevice.actX}");
    print("===setAccelerometerValue Ys: ${bleDevice.actY}");
    print("===setAccelerometerValue Zs: ${bleDevice.actZ}");
  }

  void setPulseValue(BleDevice bleDevice, List<String> pulseValue) {
    bleDevice.pulseSize = pulseValue[0];
    bleDevice.pulseRadius = pulseValue[1];
    bleDevice.pulsePadding = pulseValue[2];
    print("===setPulseValue: size: ${bleDevice.pulseSize}, radius: ${bleDevice.pulseRadius}, Padding: ${bleDevice.pulsePadding}");
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

}

