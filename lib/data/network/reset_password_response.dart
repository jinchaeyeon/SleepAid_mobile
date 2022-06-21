import 'base_response.dart';

class ResetPasswordResponse extends BaseResponse {
  int state = BaseResponse.STATE_NO_CONNECT;
  ResetPasswordResponse({this.state=BaseResponse.STATE_NO_CONNECT});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['state'] = state;
    return data;
  }
}