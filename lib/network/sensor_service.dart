import 'package:intl/intl.dart';
import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/network/base_service.dart';
import 'package:http/http.dart' as http;
import '../data/network/post_sensor_response.dart';
import 'dart:developer';

///센서값 서버로 전송
class PostSensorService extends BaseService<PostSensorResponse> {
  String date;
  List<BaseSensorResponse> items;
  PostSensorService({required this.date, required this.items});

  @override
  Future<http.Response> request() async {
    List<Map<String, dynamic>> _items = [];
    for(var item in items){
      _items.add(item.toJson());
    }
    Map<String, dynamic> body = {
      "date": date,
      "items": _items,
    };

    log("body: ${body}");
    return fetchPost(body: body);
  }

  @override
  setUrl() {
    return AppDAO.baseUrl + 'conditions/sleep-analysis-sensor-values';
  }

  @override
  PostSensorResponse success(body){
    List<BaseSensorResponse> _items = [];
    if(body['items'] is List<dynamic>){
      for(var item in body['items']){
        _items.add(BaseSensorResponse.fromJson(item));
      }
    }

    return PostSensorResponse(
      date: body['date'],
      items: _items
    );
  }

  static DateFormat serverDateFormat = DateFormat("yyyy-MM-dd");
  /// 분석에서 사용하도록 당일 21시부터 다음날 21시 직전까지 오늘 데이터로 분류한다
  /// 이 때 사용하는 날자 분류
  static String getAnalysisDateString() {
    DateTime now = DateTime.now();
    if(now.hour < 21){
      return serverDateFormat.format(now.subtract(Duration(days: 1)));
    }else{
      return serverDateFormat.format(now);
    }
  }
}

/// 파라미터를 통해 수정 된 센서값 가져오기
class PostModifiedSensorService extends BaseService<List<int>> {
  ///Enum: "sdnn" "rmssd" "pnn20" "pnn50" "lf_abs" "hf_abs" "vlf_abs"
  String type;
  List<int> values;
  PostModifiedSensorService({required this.type, required this.values});

  @override
  Future<http.Response> request() async {
    Map<String, dynamic> body = {
      "type": type,
      "values": values,
    };
    return fetchPost(body: body);
  }

  @override
  setUrl() {
    return AppDAO.baseUrl + 'conditions/realtime-signals';
  }

  @override
  List<int> success(body) {
    if (body['values'] is List<int>) {
      return body['values'] ?? [];
    }
    return [];
  }
}