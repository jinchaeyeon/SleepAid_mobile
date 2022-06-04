import 'base_response.dart';

class LicenseResponse extends BaseResponse {
  int state = BaseResponse.STATE_NO_CONNECT;
  LicenseResponse({this.state=BaseResponse.STATE_NO_CONNECT});

  factory LicenseResponse.fromJson(Map<String, dynamic> json) =>
      LicenseResponse(state: json['state']);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['state'] = state;
    return data;
  }
}