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

  /// 장치 상태 보여준다. 같은 상태라면 변경없이 false리턴
  bool setState(PeripheralConnectionState connectionState) {
    print("Peripheral ${peripheral.identifier} connection state is $connectionState");
    if(state == connectionState){
      return false;
    }
    state = connectionState;
    return true;
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

  void resetData() {
    // state = PeripheralConnectionState.disconnected;
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