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

  static requestBattery(BleDevice device) {
  }
}