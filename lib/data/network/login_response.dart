import 'package:intl/intl.dart';

import 'base_response.dart';

class LoginResponse extends BaseResponse{
  int state = BaseResponse.STATE_NO_CONNECT;
  int? id;
  String?email;
  DateTime? created;
  String? loginType;
  String? socialType;
  String? license;
  String? token;

  LoginResponse({this.state=BaseResponse.STATE_NO_CONNECT, this.id, this.email,
    this.loginType, this.socialType, this.license, this.token, String? joined}){
    if(joined != null){
      try{
        created = DateFormat('yyyy-MM-dd').parse(joined.substring(0,10));
      }catch(e){
        print("created parse error");
      }
    }
  }

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      LoginResponse(
        state: BaseResponse.STATE_CORRECT,
        id: json['id'],
        email: json['email'],
        loginType: json['loginType'],
        socialType: json['socialType'],
        license: json['license'],
        token: json['token'],
        joined: json['date_joined']
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['state'] = state;
    data['id'] = id;
    data['email'] = email;
    data['loginType'] = loginType;
    data['socialType'] = socialType;
    data['license'] = license;
    data['token'] = token;
    data['date_joined'] = created;
    data['created'] = created;
    return data;
  }
}