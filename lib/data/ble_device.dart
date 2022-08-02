import 'package:sleepaid/data/local/device_sensor_data.dart';

enum BODY_TYPE {
  NONE,
  NECK,
  FOREHEAD
}

class BleDevice {
  static List<String> realtimeSesorTypes = ["PPG", "Actigraphy X", "Actigraphy Y", "Actigraphy Z",];

  String deviceName;
  // Peripheral peripheral;
  int rssi;
  var id;
  // AdvertisementData advertisementData;
  // PeripheralConnectionState state = PeripheralConnectionState.disconnected;


  // BleDevice(this.deviceName, this.rssi, this.peripheral, this.advertisementData);
  BleDevice(this.deviceName, this.rssi, this.id);

  String battery = "-";
  String pulseSize = "";
  String pulseRadius = "";
  String pulsePadding = "";
  List<DeviceSensorData> sensors = [];
  // List<int> ppg = [];
  // List<int> eeg = [];
  // List<int> actX = [];
  // List<int> actY = [];
  // List<int> actZ = [];

  void resetData() {
    // state = PeripheralConnectionState.disconnected;
    battery = "-";
    pulseSize = "";
    pulseRadius = "";
    pulsePadding = "";
    // ppg = [];
    // eeg = [];
    // actX = [];
    // actY = [];
    // actZ = [];
  }

  List<int> getSensorValues(String types) {
    List<int> values = [];
    sensors.forEach((_sensor) {
      if(types == realtimeSesorTypes[0]){
        values.add(_sensor.ppg);
      }else if(types == realtimeSesorTypes[1]){
        values.add(_sensor.actX);
      }else if(types == realtimeSesorTypes[2]){
        values.add(_sensor.actY);
      }else if(types == realtimeSesorTypes[3]){
        values.add(_sensor.actZ);
      }

    });
    return values;
  }

}