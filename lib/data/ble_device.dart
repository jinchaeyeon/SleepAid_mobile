import 'package:flutter_ble_lib_ios_15/flutter_ble_lib.dart';

enum BODY_TYPE {
  NONE,
  NECK,
  FOREHEAD
}

class BleDevice {
  String deviceName;
  Peripheral peripheral;
  int rssi;
  AdvertisementData advertisementData;
  PeripheralConnectionState state = PeripheralConnectionState.disconnected;
  BleDevice(this.deviceName, this.rssi, this.peripheral, this.advertisementData);

  void setState(PeripheralConnectionState connectionState) {
    print("Peripheral ${peripheral.identifier} connection state is $connectionState");
    state = connectionState;
  }

  String battery = "-";
  String pulseSize = "";
  String pulseRadius = "";
  String pulsePadding = "";
  List<double> ppg = [];
  List<double> eeg = [];
  List<double> actX = [];
  List<double> actY = [];
  List<double> actZ = [];

  void disconnect() {
    state = PeripheralConnectionState.disconnected;
    battery = "-";
    pulseSize = "";
    pulseRadius = "";
    pulsePadding = "";
    ppg = [];
    eeg = [];
    actX = [];
    actY = [];
    actZ = [];
  }
}