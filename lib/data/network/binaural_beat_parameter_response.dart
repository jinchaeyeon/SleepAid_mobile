import 'base_response.dart';


class BinauralBeatParameterResponse extends BaseResponse {
  int state = BaseResponse.STATE_NO_CONNECT;
  int id;
  bool onDisplay;
  String name;
  int toneFrequency;
  int beatFrequency;

  BinauralBeatParameterResponse({
    required this.id,
    required this.onDisplay,
    required this.name,
    required this.toneFrequency,
    required this.beatFrequency,
  });

  factory BinauralBeatParameterResponse.fromJson(Map<String, dynamic> json) =>
      BinauralBeatParameterResponse(
          id: json['id'],
          onDisplay: json['on_display'],
          name: json['name'],
          toneFrequency: json['tone_frequency'],
          beatFrequency: json['beat_frequency'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['state'] = state;
    data['id'] = id;
    data['on_display'] = onDisplay;
    data['name'] = name;
    data['tone_frequency'] = toneFrequency;
    data['beat_frequency'] = beatFrequency;
    return data;
  }
}