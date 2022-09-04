import 'package:intl/intl.dart';

import 'base_response.dart';

List<String> answerTypes = ["score", "bool"];
class SleepConditionParameterResponse extends BaseResponse {
  int state = BaseResponse.STATE_NO_CONNECT;
  int id;
  bool onDisplay;
  String question;

  String answerType;
  bool isRequired = false;
  int score = 0; // 0~ 10
  bool? isYes; // null / false / true


  SleepConditionParameterResponse({
    this.state=BaseResponse.STATE_NO_CONNECT,
    required this.id,
    required this.onDisplay,
    required this.question,
    required this.answerType,
  });

  factory SleepConditionParameterResponse.fromJson(Map<String, dynamic> json) =>
      SleepConditionParameterResponse(
        id: json['id'],
        onDisplay: json['on_display'],
        question: json['question'],
        answerType: json['answer_type']
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['state'] = state;
    data['id'] = id;
    data['on_display'] = onDisplay;
    data['question'] = question;
    data['answer_type'] = answerType;
    return data;
  }

  /// 데이터 전송시 쓰는 폼
  Map<String, dynamic> toSendDataJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['condition'] = id;
    if(answerType == answerTypes[0]){
      data['answer_score'] = score;
    }else{
      data['answer_bool'] = isYes??false;
    }
    return data;
  }
}


class SleepConditionDateResponse extends BaseResponse {
  static DateFormat format = DateFormat('yyyy-MM-dd');

  int state = BaseResponse.STATE_NO_CONNECT;
  int id;
  DateTime date;
  String dateString = "";

  SleepConditionDateResponse({
    this.state=BaseResponse.STATE_NO_CONNECT,
    required this.id,
    required this.date,
  }){
    dateString = format.format(date);
  }




  factory SleepConditionDateResponse.fromJson(Map<String, dynamic> json){
    return SleepConditionDateResponse(
      id: json['id'],
      date: format.parse(json['date'] as String),
    );
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['state'] = state;
    data['id'] = id;
    data['date'] = format.format(date);
    data['dateString'] = dateString;
    return data;
  }
}