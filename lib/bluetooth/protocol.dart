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

  static String buildBrainSignal(Uint8List message) {
    String brainSignal = "";
    for (int i = 0; i < 8; i++) {
      int pos = 2 + i * 3;
      Uint8List list = message.sublist(pos, pos + 3);
      print(list);
      int value = (bytesToInteger(list) / 1000).round();
      brainSignal = brainSignal + value.toString() + ", ";
    }
    print("braiSiginal:$brainSignal");
    return brainSignal;
  }

  static List<String> buildBrainSignalList(String brainSignal){
    //ppg 신호 가져오기
    List<String> brainSignalList = brainSignal.split(",");
    return brainSignalList;
  }
  /// PPG 응답 신호값 처리
  static double getPPGValue(List<String> brainSignal) {
    //ppg 신호 가져오기
    return double.parse(brainSignal[2]);
  }
  /// EEG 응답 신호값 처리
  static List<double> getEEGValue(List<String> brainSignal) {
    //ppg 신호 가져오기
    return [double.parse(brainSignal[0]), double.parse(brainSignal[1])];
  }

  static List<double> getAccelerometerValue(Uint8List message, String brainSignal) {
    String actSignal = "";
    for (int i = 0; i < 3; i++) {
      int pos = 26 + i * 2;
      Uint8List list = message.sublist(pos, pos + 2);
      int value = (bytesToInteger(list)).round();
      actSignal = brainSignal + value.toString() + ", ";
    }

    List<String> brainSignalActList = actSignal.split(",");
    return [double.parse(brainSignalActList[0]),double.parse(brainSignalActList[0]),double.parse(brainSignalActList[0])];
  }

  static List<String> getPulseSizes(String brainSignal) {
    //펄스 속성값 가공
    List<String> brainSignalArr = brainSignal.split(",");
    // int pulseSize = int.tryParse(brainSignalArr[3]);
    // // pulseSize = (pulseSize * 2 / 1638 * 100).round();
    // int pulseRadius = int.tryParse(brainSignalArr[4]);
    // // pulseRadius = (pulseRadius * 2 / 1638 * 100).round();
    // int pulsePadding = int.tryParse(brainSignalArr[5]);
    // // pulsePadding = (pulsePadding * 2 / 1638 * 100).round();
    return [brainSignalArr[3], brainSignalArr[4], brainSignalArr[5]];
  }
}