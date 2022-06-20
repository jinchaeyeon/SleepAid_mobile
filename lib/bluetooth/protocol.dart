import 'dart:typed_data';

import 'package:sleepaid/data/ble_device.dart';
import 'package:sleepaid/util/functions.dart';

class Protocol{
  List<int> buildBaseProtocolBody({
    List<int> channel = const [],
    List<int> id = const [],
    List<int> divider = const [],
    List<int> value = const [],
    List<int> end = const []
  }){

    return const[];
  }

  static requestBattery(BleDevice device, ) {
  }

  static String getBatteryValue(message) {
    try{
      int batteryLevel = 0xff & message[32];
      // 0xff & batteryByte 하면 0x00~0xff 규격의 batteryByte값 나옴(byte AND)
      // 혹시 모를 최대최소값을 조절하는 용도?로 보임
      print("batteryByte: ${message[32]} | batteryLevel:$batteryLevel");
      //현재 배터리 상태값 가공
      return ((batteryLevel * 0.0032 * 6.9) / 4.7 * 100).toString();
    }catch(e){
       return "";
    }
  }

  static double getPPGValue(Uint8List message) {
    String brainSignal = "";
    for (int i = 0; i < 8; i++) {
      int pos = 2 + i * 3;
      Uint8List list = message.sublist(pos, pos + 3);
      int value = (bytesToInteger(list) / 1000).round();
      brainSignal = brainSignal + value.toString() + ", ";
    }
    //ppg 신호 가져오기
    List<String> brainSignalPPGList = brainSignal.split(",");
    print("getPPGValue brainSignalPPGList: $brainSignalPPGList");
    return double.parse(brainSignalPPGList[2]);
  }
}