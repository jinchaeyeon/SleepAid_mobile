import 'package:flutter_ble_lib_ios_15/flutter_ble_lib.dart';

enum BODY_TYPE {
  NECK,
  FOREHEAD
}

class BleDevice {
  String deviceName;
  Peripheral peripheral;
  int rssi;
  AdvertisementData advertisementData;
  BleDevice(this.deviceName, this.rssi, this.peripheral, this.advertisementData);
}