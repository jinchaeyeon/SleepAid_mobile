import 'base_response.dart';

class RecipeResponse extends BaseResponse {
  int state = BaseResponse.STATE_NO_CONNECT;
  String text = "";
  double interval = 0; //간격
  double intensity = 0; //세기
  double elevation = 0; //높이

  RecipeResponse({
    this.state=BaseResponse.STATE_NO_CONNECT,
    this.text = "",
    this.interval = 0,
    this.intensity = 0,
    this.elevation = 0
  });

  factory RecipeResponse.fromJson(Map<String, dynamic> json) =>
      RecipeResponse(
        state: json['state'],
        text: json['text'],
        interval: json['interval'],
        intensity: json['intensity'],
        elevation: json['elevation'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['state'] = state;
    data['text'] = text;
    data['interval'] = interval;
    data['intensity'] = intensity;
    data['elevation'] = elevation;
    return data;
  }
}