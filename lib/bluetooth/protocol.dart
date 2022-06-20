import 'dart:typed_data';

import 'package:sleepaid/data/ble_device.dart';

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
      //현재 배터리 상태값 가공
      return ((batteryLevel * 0.0032 * 6.9) / 4.7 * 100).toString();
    }catch(e){
       return "";
    }
  }
}