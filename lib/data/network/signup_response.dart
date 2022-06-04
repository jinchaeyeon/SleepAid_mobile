import 'base_response.dart';

class SignUpResponse extends BaseResponse{
  int state = BaseResponse.STATE_NO_CONNECT;

  SignUpResponse({this.state=BaseResponse.STATE_NO_CONNECT});

  factory SignUpResponse.fromJson(Map<String, dynamic> json) =>
      SignUpResponse(state: json['state']);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['state'] = state;
    return data;
  }
}