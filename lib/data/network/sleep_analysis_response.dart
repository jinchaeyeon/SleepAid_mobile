import 'package:sleepaid/data/network/sleep_condition_response.dart';

import 'base_response.dart';


class SleepAnalysisResponse extends BaseResponse{
  int id;
  String date;
  String awake;
  String rem;
  String light;
  String deep;
  int quality;
  List<SleepConditionItem> itemSet;

  SleepAnalysisResponse(
      {
        required this.id,
        required this.date,
        required this.awake,
        required this.rem,
        required this.light,
        required this.deep,
        required this.quality,
        required this.itemSet,
      });

  factory SleepAnalysisResponse.fromJson(Map<String, dynamic> json){

    return SleepAnalysisResponse(
      id : json['id'],
      date : json['date'],
      awake : json['awake'],
      rem : json['rem'],
      light : json['light'],
      deep : json['deep'],
      quality : json['quality'],
      itemSet : buildItemSet(json['item_set'] as List<dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['date'] = date;
    data['awake'] = awake;
    data['rem'] = rem;
    data['light'] = light;
    data['deep'] = deep;
    data['quality'] = quality;
    data['itemSet'] = itemSet;
    return data;
  }

  static buildItemSet(List<dynamic> list) {
    List<SleepConditionItem> itemList = [];
    for (var element in list) {
      itemList.add(SleepConditionItem.fromJson(element));
    }
    return itemList;
  }

  double getSleepAnalisysPercent(int i) {
    return 0;
  }
}