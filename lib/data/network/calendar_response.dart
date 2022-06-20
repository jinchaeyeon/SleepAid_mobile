import 'base_response.dart';

class CalendarDetailResponse extends BaseResponse{
  int state = BaseResponse.STATE_NO_CONNECT;

  CalendarDetailResponse({
    this.state=BaseResponse.STATE_NO_CONNECT,
  });
}

class CalendarResponse extends BaseResponse {
  int state = BaseResponse.STATE_NO_CONNECT;
  List<CalendarDetailResponse> list = [];

  CalendarResponse({
    this.state=BaseResponse.STATE_NO_CONNECT,
  });

  factory CalendarResponse.fromJson(Map<String, dynamic> json) =>
      CalendarResponse(
        state: json['state'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['state'] = state;
    return data;
  }
}