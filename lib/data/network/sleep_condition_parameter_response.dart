import 'base_response.dart';

class SleepConditionParameterResponse extends BaseResponse {
  int state = BaseResponse.STATE_NO_CONNECT;
  int id;
  bool onDisplay;
  String question;

  SleepConditionParameterResponse({
    this.state=BaseResponse.STATE_NO_CONNECT,
    required this.id,
    required this.onDisplay,
    required this.question,
  });

  factory SleepConditionParameterResponse.fromJson(Map<String, dynamic> json) =>
      SleepConditionParameterResponse(
        id: json['id'],
        onDisplay: json['on_display'],
        question: json['question'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['state'] = state;
    data['id'] = id;
    data['on_display'] = onDisplay;
    data['question'] = question;
    return data;
  }
}