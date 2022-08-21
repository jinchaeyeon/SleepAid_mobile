import 'package:intl/intl.dart';

import 'base_response.dart';

class PushResponse extends BaseResponse{
  int? id;
  String? registrationId;

  PushResponse({this.id, this.registrationId});

  factory PushResponse.fromJson(Map<String, dynamic> json) =>
      PushResponse(
        id: json['id'],
        registrationId: json['registration_id'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['registration_id'] = registrationId;
    data['id'] = id;
    return data;
  }
}