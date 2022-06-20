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
  static StreamSubscription? notifyForeheadStream;

  bool isDeviceScanning = false; //장치스캔
  bool isDataScanning = false; //장치에서 데이터 스캔

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
    deviceList.clear();
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
  }

  ///스캔 끝나면 꼭 stop처리
  Future<void> stopDeviceScanning() async {
    print("stopDeviceScanning");
    isDeviceScanning = false;
    // deviceList.clear();
    bleManager.stopPeripheralScan();
    await bleManager.destroyClient();
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
      completedExit();
    }
  }

  /// 신체 연결 다이얼로그 노출 및 선택 시 해당 파트 기기 연결 처리
  /// 1. 기 연결 기기가 있음면 연결 취소 처리
  /// 2. 신규 기기 연결 시도
  /// 3. 연결 실패하면 연결에 실패하였습니다
  /// 4. 연결 성공하면 업데이트
  Future<void> choiceBodyPosition(BODY_TYPE type,BleDevice device) async {
    BleDevice newDevice = BleDevice(device.deviceName,device.rssi, device.peripheral, device.advertisementData);
    if(type == BODY_TYPE.NECK){
      /// 블루투스 기기에 연결시도
      await newDevice.peripheral.connect(isAutoConnect: true).whenComplete(() async {
        if(await newDevice.peripheral.isConnected()){
          print("newDevice isConnected");
          showToast("기기 연결 성공");
        }else{
          print("newDevice is not Connected");
          showToast("기기 연결 실패");
          return;
        }
        // await device.peripheral.discoverAllServicesAndCharacteristics();
        /// 장치 변수에 할당
        connectedDeviceForNeck = newDevice;

        notifyNeckStream?.cancel();
        notifyNeckStream = connectedDeviceForNeck!.peripheral
            .observeConnectionState(emitCurrentValue: true)
            .listen((PeripheralConnectionState connectionState) async {

              connectedDeviceForNeck!.state = connectionState;
              if(device.state == PeripheralConnectionState.connected){
                await device.peripheral.discoverAllServicesAndCharacteristics();

                notifyNeckStream = connectedDeviceForNeck!.peripheral.monitorCharacteristic(
                    SERVICE_UUID_LIST[0],
                    TX_UUID_LIST[0],
                    transactionId: "monitor"
                ).listen((task) {
                  Uint8List message = task.value;
                  print("neck message: ${message}");
                  String batteryValue = Protocol.getBatteryValue(message);
                  setBatteryValue(connectedDeviceForNeck!, batteryValue);
                  double ppgValue = Protocol.getPPGValue(message);
                  setPPGValue(connectedDeviceForNeck!, ppgValue);
                  notifyListeners();
                  // String eegValue = Protocol.getEEGValue(message);
                  // setEEGValue(connectedDeviceForNeck!, eegValue);


                }, onError: (error){
                  print("notifyNeckStream error:: $error");
                } ,cancelOnError: true);
              }
        });
      });
    }else if(type == BODY_TYPE.FOREHEAD){
      // 이마에 연결된 기기를 목에 연결시 / 목연결 기기를 이마에 연결시 기존 연결 취소 처리
      /// 블루투스 기기에 연결시도
      newDevice.peripheral.connect(isAutoConnect: true).whenComplete(() async {
        if(await newDevice.peripheral.isConnected()){
          print("newDevice isConnected");
          showToast("기기 연결 성공");
        }else{
          print("newDevice is not Connected");
          showToast("기기 연결 실패");
          return;
        }
        // await device.peripheral.discoverAllServicesAndCharacteristics();
        /// 장치 변수에 할당
        connectedDeviceForForehead = newDevice;

        notifyForeheadStream?.cancel();
        notifyForeheadStream = connectedDeviceForForehead!.peripheral
            .observeConnectionState(emitCurrentValue: true)
            .listen((PeripheralConnectionState connectionState) async {

          connectedDeviceForForehead!.state = connectionState;
          if(device.state == PeripheralConnectionState.connected){
            await connectedDeviceForForehead!.peripheral.discoverAllServicesAndCharacteristics();

            notifyForeheadStream = connectedDeviceForForehead!.peripheral.monitorCharacteristic(
                SERVICE_UUID_LIST[0],
                TX_UUID_LIST[0],
                transactionId: "monitor"
            ).listen((task) {
              Uint8List message = task.value;
              print("forehead message: ${message}");
              String batteryValue = Protocol.getBatteryValue(message);
              setBatteryValue(connectedDeviceForForehead!, batteryValue);
              double ppgValue = Protocol.getPPGValue(message);
              setPPGValue(connectedDeviceForForehead!, ppgValue);
              notifyListeners();

            }, onError: (error){
              print("notifyForeheadStream error:: $error");
            } ,cancelOnError: true);
          }
        });
      });
    }
    device.peripheral.observeConnectionState(emitCurrentValue: true, completeOnDisconnect: true)
        .listen((connectionState) {
      device.setState(connectionState);
    });

    notifyListeners();
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
  void setBatteryValue(BleDevice connectedDevice, String batteryValue) {
    print("Battery: $batteryValue");
    connectedDevice.battery = batteryValue.split(".")[0];
    notifyListeners();
  }

  bool setPPGValue(BleDevice bleDevice, double ppgValue) {
    //ppg 신호 가져오기

    if(bleDevice.ppg.length > 20000) {
      bleDevice.ppg.removeAt(0);
    }
    bleDevice.ppg.add(ppgValue);
    print("bleDevice.ppg: ${bleDevice.ppg}");
    return true;
  }


}

