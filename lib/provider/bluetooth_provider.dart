import 'package:flutter/widgets.dart';
import 'package:flutter_ble_lib_ios_15/flutter_ble_lib.dart';
import 'package:sleepaid/data/ble_device.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:sleepaid/util/util.dart';

/// 항시 연결상태 체크
/// 항시 데이터 서버 전송
/// 네트워크/서버 연결 실패하면 로컬에 담아서 보관
/// 네트워크/서버 연결 되면 로컬 데이터 서버 전송하고 삭제
class BluetoothProvider with ChangeNotifier{
  BleManager bleManager = BleManager();
  List<BleDevice> deviceList = [];
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

