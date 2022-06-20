import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ble_lib_ios_15/flutter_ble_lib.dart';
import 'package:permission_handler/permission_handler.dart';
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
  StreamSubscription? notifyNeckStream;
  StreamSubscription? notifyForeheadStream;

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
    if(type == BODY_TYPE.NECK){
      BleDevice newDevice = BleDevice(device.deviceName,device.rssi, device.peripheral, device.advertisementData);

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

        await device.peripheral.discoverAllServicesAndCharacteristics();
        var services = await device.peripheral.services();
        for (var service in services) {
          log("SERVICE : " + service.uuid);
          List<Characteristic> characteristics = await service.characteristics();
          for( var characteristic in characteristics ) {
            log("CHARACTER : ${characteristic.uuid}");
            log("NOTIFY : " + characteristic.isNotifiable.toString());
            log("INDICATE : " + characteristic.isIndicatable.toString());
            log("WRITE_RES : " + characteristic.isWritableWithResponse.toString());
            log("WRITE_NORES : " + characteristic.isWritableWithoutResponse.toString());
            log("READ : " + characteristic.isReadable.toString());

            if (characteristic.isNotifiable) {
              print("isNofifiable");
            }else if(characteristic.uuid == "6e400003-b5a3-f393-e0a9-e50e24dcca9e"){
              print("is not Nofifiable");
              // _writeCharacteristicUuid = characteristic.uuid;
              // _writeService = service.uuid;
            }
          }
        }

        /// 잘 연결 되었다면 notify Listener 설정

        /// 장치 변수에 할당
        connectedDeviceForNeck = newDevice;

        notifyNeckStream?.cancel();
        notifyNeckStream = newDevice.peripheral
            .observeConnectionState(emitCurrentValue: true)
            .listen((PeripheralConnectionState connectionState) async {

              newDevice.state = connectionState;
              if(device.state == PeripheralConnectionState.connected){
                await device.peripheral.discoverAllServicesAndCharacteristics();

                notifyNeckStream = device.peripheral.monitorCharacteristic(
                    SERVICE_UUID_LIST[0],
                    TX_UUID_LIST[0],
                    transactionId: "monitor"
                ).listen((task) {
                  var list = task.value.toList();
                  print("notifyNeckStream notify:: $list");
                }, onError: (error){
                  print("notifyNeckStream error:: $error");
                } ,cancelOnError: true);
              }
        });
      });
      // connectedDeviceForNeck = device;
      // connectedDeviceForNeck!.setState(PeripheralConnectionState.connected);


      // // 이마에 연결된 기기를 목에 연결시 / 목연결 기기를 이마에 연결시 기존 연결 취소 처리
      // if(device.peripheral.identifier == connectedDeviceForForehead?.peripheral.identifier){
      //   await connectedDeviceForForehead?.peripheral.disconnectOrCancelConnection();
      //   connectedDeviceForForehead = null;
      // }
      // await device.peripheral.disconnectOrCancelConnection();
      // await device.peripheral.connect(isAutoConnect: true).whenComplete((){
      //   notifyNeckStream?.cancel();
      //
      //   notifyNeckStream = device.peripheral
      //       .observeConnectionState(emitCurrentValue: true)
      //       .listen((PeripheralConnectionState connectionState) async {
      //     device.state = connectionState;
      //     if(device.state == PeripheralConnectionState.connected){
      //
      //       await device.peripheral.discoverAllServicesAndCharacteristics();
      //
      //       notifyNeckStream = device.peripheral.monitorCharacteristic(
      //           SERVICE_UUID_LIST[0],
      //           TX_UUID_LIST[0],
      //           transactionId: "monitor"
      //       ).listen((task) {
      //         var list = task.value.toList();
      //         print("notifyNeckStream notify:: $list");
      //       }, onError: (error){
      //         print("notifyNeckStream error:: $error");
      //       } ,cancelOnError: true);
      //     }
      //   });
      // });
      // connectedDeviceForNeck = device;
      // connectedDeviceForNeck!.setState(PeripheralConnectionState.connected);




      // await device.peripheral.isConnected().then((bool isConnected) async {
        // if(!isConnected) {
        //   showToast("연결실패. 다시 시도해주세요.");
        //   return;
        // }

      //   connectedDeviceForNeck = device;
      //   connectedDeviceForNeck!.setState(PeripheralConnectionState.connected);
      //   showToast("장치 연결 확인");
      //
      //   notifyNeckStream?.cancel();
      //   notifyNeckStream = device.peripheral
      //       .observeConnectionState(emitCurrentValue: true)
      //       .listen((PeripheralConnectionState connectionState) {
      //         device.state = connectionState;
      //         if(device.state == PeripheralConnectionState.connected){
      //           notifyNeckStream = connectedDeviceForNeck!.peripheral.monitorCharacteristic(
      //               SERVICE_UUID_LIST[0],
      //               TX_UUID_LIST[0],
      //               transactionId: "monitor"
      //           ).listen((task) {
      //             var list = task.value.toList();
      //             print("notifyNeckStream notify:: $list");
      //           }, onError: (error){
      //             print("notifyNeckStream error:: $error");
      //           } ,cancelOnError: true);
      //         }
      //   });
      // });
    }else if(type == BODY_TYPE.FOREHEAD){
      // 이마에 연결된 기기를 목에 연결시 / 목연결 기기를 이마에 연결시 기존 연결 취소 처리
      if(device.peripheral.identifier == connectedDeviceForNeck?.peripheral.identifier){
        await connectedDeviceForNeck?.peripheral.disconnectOrCancelConnection();
        connectedDeviceForNeck = null;
      }
      await connectedDeviceForForehead?.peripheral.disconnectOrCancelConnection();
      await device.peripheral.connect(isAutoConnect: true);
      bool connected = await device.peripheral.isConnected();
      if(!connected){
        showToast("연결실패. 다시 시도해주세요.");
      }else{
        connectedDeviceForForehead = device;
        connectedDeviceForForehead!.setState(PeripheralConnectionState.connected);
        showToast("장치 연결 확인");
      }
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

// Future<void> getBluetoothConnection(address) async {
//   //Bluetooth 주소값을 이용한 연결
//   try {
//     BluetoothConnection connection =
//     await BluetoothConnection.toAddress(address);
//     Util.log("Connected to the device.");
//
//     connection.input.listen((Uint8List data) {
//       Util.log("Data incoming : ${ascii.decode(data)}");
//       connection.output.add(data);
//       //Serialized Data 이쪽으로 받아옴
//       //총 바이트코드 length = 16
//       //[0] 펄스폭 조회
//       //[1] 펄스폭 설정
//       //[2] 펄스간격 조회
//       //[3, 4] 펄스간격 설정
//       //[5] 펄스크기 조회₩
//       //[6, 7] 펄스크기 설정
//       //[8] 펄스극성 조회
//       //[9] 펄스극성 설정
//       //[10] 펄스 OUTPUT
//       //[11] 펄스 OUTPUT ALL
//       //[12] 실행모드
//       //[13] 현상태 출력 -> 피드백 필요
//       //[14, 15] 배터리 전압 출력 -> 범위로 주어짐
//
//       if (ascii.decode(data).contains('!')) {
//         connection.finish();
//         Util.log("Disconnecting by local host");
//       }
//     }).onDone(() {
//       Util.log("Disconnected");
//     });
//   } catch (exception) {
//     Util.log("Cannot Connect, exception occured");
//   }
// }
//
// Future<List<blue.BluetoothDevice>> getBluetoothDeviceList() async {
//   //사용 가능한 Bluetooth 기기 목록 받아오기
//   //address -> device.address
//   //isConnected -> device.isConnected로 접근 가능
//   List<blue.BluetoothDevice> devicesList = [];
//   try {
//     blue.FlutterBlue flutterBlue;
//     flutterBlue.scanResults.listen((List<blue.ScanResult> results) {
//       for (blue.ScanResult result in results){
//         devicesList.add(result.device);
//       }
//     });
//   } catch (exception) {
//     Util.log("Cannot get devices list, exception occured");
//   }
//
//   return devicesList;
// }
//
// Future<List<blue.BluetoothDevice>> getPairedBluetoothDeviceList() async {
//   //페어링 된 Bluetooth 기기 목록 받아오기
//   List<blue.BluetoothDevice> devicesList = [];
//   try {
//     blue.FlutterBlue flutterBlue;
//     flutterBlue.connectedDevices.asStream().listen((List<blue.BluetoothDevice> devices){
//       for (blue.BluetoothDevice device in devices){
//         devicesList.add(device);
//       }
//     });
//   } catch (exception) {
//     Util.log("Cannot get devices list, exception occured");
//   }
//
//   return devicesList;
// }
//
// int getConnectedDeviceBattery(byteCode){
//   //바이트코드에서 배터리 받아오는 예시 코드
//   var batteryByte = ByteData.sublistView(byteCode, 14, 15);
//   int battery = batteryByte.getUint8(0);
//   //Bytedata.subListView(블루투스 기기에서 날아온 값, 바이트코드의 시작 인덱스, 바이트코드의 끝 인덱스)
//
//   return battery;
// }
}

