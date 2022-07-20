/// 센서의 값
class SensorData{
  String sensorName;
  DateTime dateTime;
  int value;
  SensorData(this.dateTime, this.value,{this.sensorName="PPG"});
}