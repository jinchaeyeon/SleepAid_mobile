import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ble_lib_ios_15/flutter_ble_lib.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sleepaid/data/ble_device.dart';
import 'package:sleepaid/data/ble_device.dart';
import 'package:sleepaid/data/ble_device.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:sleepaid/util/util.dart';

/// 항시 연결상태 체크
/// 항시 데이터 서버 전송
/// 네트워크/서버 연결 실패하면 로컬에 담아서 보관
/// 네트워크/서버 연결 되면 로컬 데이터 서버 전송하고 삭제
class BluetoothProvider with ChangeNotifier{
  static const List<String> SERVICE_UUID_LIST = ['6e400001-b5a3-f393-e0a9-e50e24dcca9e'];

  BleManager bleManager = BleManager();
  List<BleDevice> deviceList = []; //전체 검색되는 장치목록
  BleDevice? connectedDeviceForNeck; //목 연결 장치
  BleDevice? connectedDeviceForForehead; //이마 연결장치

  bool isDataScanning = false;

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
    print("startDeviceScanning");
    deviceList.clear();

    await bleManager.createClient(
      restoreStateIdentifier: "restore-id",
      restoreStateAction: (peripherals) {
        for (var peripherals in peripherals) {
          print("Restored peripheral: ${peripherals.name}");
        }
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
        deviceList.add(BleDevice(name,scanResult.rssi, scanResult.peripheral, scanResult.advertisementData));
        notifyListeners();
      }

    });
  }

  ///스캔 끝나면 꼭 stop처리
  Future<void> stopDeviceScanning() async {
    print("stopDeviceScanning");
    deviceList.clear();
    bleManager.stopPeripheralScan();
    await bleManager.destroyClient();
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
  ///12 이하에서는 LOCATION 도 필요
  ///IOS 는 별도로
  Future<void> checkBluetoothPermission() async {

    Map<Permission, PermissionStatus> statuses =
    await [Permission.location, Permission.bluetooth].request();
  }

  /// 신체 연결 다이얼로그 노출 및 선택 시 해당 파트 기기 연결 처리
  /// 기 연결 기기가 있음면 연결 취소 처리
  Future<void> choiceBodyPosition(BODY_TYPE type,BleDevice device) async {
    if(type == BODY_TYPE.NECK){
      if(connectedDeviceForNeck != null){

      }
    }else if(type == BODY_TYPE.FOREHEAD){

    }

    notifyListeners();
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

