import 'base_response.dart';

class ElectroStimulationParameterResponse extends BaseResponse {
  int state = BaseResponse.STATE_NO_CONNECT;
  int id;
  bool onDisplay;
  String name;
  int interval;
  int intensity;
  int height;

  ElectroStimulationParameterResponse({
    this.id=-1,
    this.onDisplay=true,
    required this.name,
    required this.interval,
    required this.intensity,
    required this.height
  });

  factory ElectroStimulationParameterResponse.fromJson(Map<String, dynamic> json) =>
      ElectroStimulationParameterResponse(
        id: json['id'],
        onDisplay: json['on_display'],
        name: json['name'],
        interval: json['interval'],
        intensity: json['intensity'],
        height: json['height']
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['state'] = state;
    data['id'] = id;
    data['on_display'] = onDisplay;
    data['name'] = name;
    data['interval'] = interval;
    data['intensity'] = intensity;
    data['height'] = height;
    return data;
  }
}