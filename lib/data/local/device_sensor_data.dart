/// 장치에서 가져오는 센서 데이터
class DeviceSensorData{
  DateTime dateTime;
  int eeg1;
  int eeg2;
  int ppg;
  int actX;
  int actY;
  int actZ;

  DeviceSensorData({
    required this.dateTime,
    required this.eeg1,
    required this.eeg2,
    required this.ppg,
    required this.actX,
    required this.actY,
    required this.actZ
  });
}