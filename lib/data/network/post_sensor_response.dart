import 'package:intl/intl.dart';

import 'base_response.dart';

///센서 서버에 저장 후 리턴 값
class PostSensorResponse extends BaseResponse{
  String date;
  List<BaseSensorResponse> items;

  PostSensorResponse({required this.date, required this.items});

  factory PostSensorResponse.fromJson(Map<String, dynamic> json){
    List<BaseSensorResponse> _items = [];
    if(json['items'] is List<dynamic>){
      for(var item in json['items']){
        _items.add(BaseSensorResponse.fromJson(item));
      }
    }
    return PostSensorResponse(
        date: json['date'],
        items: _items,
    );
  }



  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['items'] = items;
    return data;
  }
}


class BaseSensorResponse extends BaseResponse{
  String datetime; //"datetime": "2019-08-24T14:15:22Z",
  int ppg;
  int eeg1;
  int eeg2;
  int actigraphyX;
  int actigraphyY;
  int actigraphyZ;

  BaseSensorResponse({
    required this.datetime,
    required this.ppg,
    required this.eeg1,
    required this.eeg2,
    required this.actigraphyX,
    required this.actigraphyY,
    required this.actigraphyZ,
  });

  factory BaseSensorResponse.fromJson(Map<String, dynamic> json) =>
      BaseSensorResponse(
        datetime: json['datetime'],
        ppg: json['ppg'],
        eeg1: json['eeg1'],
          eeg2: json['eeg2'],
        actigraphyX: json['actigraphy_x'],
        actigraphyY: json['actigraphy_y'],
        actigraphyZ: json['actigraphy_z']
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['datetime'] = datetime;
    data['ppg'] = ppg;
    data['eeg1'] = eeg1;
    data['eeg2'] = eeg2;
    data['actigraphy_x'] = actigraphyX;
    data['actigraphy_y'] = actigraphyY;
    data['actigraphy_z'] = actigraphyZ;
    return data;
  }
}