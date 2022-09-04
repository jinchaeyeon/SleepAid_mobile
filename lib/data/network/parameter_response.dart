import 'base_response.dart';


class ParameterResponse extends BaseResponse {
  int state = BaseResponse.STATE_NO_CONNECT;
  int id;
  bool onDisplay;
  String name;

  ParameterResponse({
    required this.id,
    required this.onDisplay,
    required this.name
  });

  factory ParameterResponse.fromJson(Map<String, dynamic> json) =>
      ParameterResponse(
          id: json['id'],
          onDisplay: json['on_display'],
          name: json['name'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['state'] = state;
    data['id'] = id;
    data['on_display'] = onDisplay;
    data['name'] = name;
    return data;
  }
}