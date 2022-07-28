import 'base_response.dart';

class BinauralBeatRecipeResponse extends BaseResponse {
  int state = BaseResponse.STATE_NO_CONNECT;
  String text = "";
  int tone = 0; //Tone
  int binauralBeat = 0; //Binaural Beat

  BinauralBeatRecipeResponse({
    this.state=BaseResponse.STATE_NO_CONNECT,
    this.text = "",
    this.tone = 0,
    this.binauralBeat = 0,
  });

  factory BinauralBeatRecipeResponse.fromJson(Map<String, dynamic> json) =>
      BinauralBeatRecipeResponse(
        state: json['state'],
        text: json['text'],
        tone: json['tone'],
        binauralBeat: json['binauralBeat'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['state'] = state;
    data['text'] = text;
    data['tone'] = tone;
    data['binauralBeat'] = binauralBeat;
    return data;
  }
}