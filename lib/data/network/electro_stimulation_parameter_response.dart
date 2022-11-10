import 'base_response.dart';

class ElectroStimulationParameterResponse extends BaseResponse {
  int state = BaseResponse.STATE_NO_CONNECT;
  int id;
  bool onDisplay;
  String name;
  int interval; // _pulseRadius
  int intensity; // _pulseSize
  int height; // _pulsePadding
  int long;

  ElectroStimulationParameterResponse({
    this.id=-1,
    this.onDisplay=true,
    required this.name,
    required this.interval,
    required this.intensity,
    required this.height,
    required this.long,
  });

  factory ElectroStimulationParameterResponse.fromJson(Map<String, dynamic> json) =>
      ElectroStimulationParameterResponse(
        id: json['id'],
        onDisplay: json['on_display'],
        name: json['name'],
        interval: json['interval'],
        intensity: json['intensity'],
        height: json['height'],
        long: json['long'],
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
    data['long'] = long;
    return data;
  }

  static ElectroStimulationParameterResponse? firstRecipe(int index, int value) {
    int intensity = 0;
    int interval = 0;
    int height = 0;
    int long = 0;

    if(index == 0){
      intensity = value;
    }else if(index == 1){
      interval = value;
    }else if(index == 2){
      height = value;
    }else if(index == 3){
      long = value;
    }

    var recipe = ElectroStimulationParameterResponse(name:"", interval: interval, intensity: intensity, height: height, long: long);
    return recipe;
  }
}