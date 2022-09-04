import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/network/sleep_condition_parameter_response.dart';
import 'package:sleepaid/network/base_service.dart';
import 'package:http/http.dart' as http;

class GetSleepConditionService extends BaseService<List<SleepConditionParameterResponse>> {
  GetSleepConditionService();

  @override
  Future<http.Response> request() async {
    return fetchGet();
  }

  @override
  setUrl() {
    return AppDAO.baseUrl + 'conditions/sleep-conditions';
  }

  @override
  List<SleepConditionParameterResponse> success(body){
    List<SleepConditionParameterResponse> list = [];
    if(body is List<dynamic>){
      for (var element in body) {
        list.add(SleepConditionParameterResponse.fromJson(element));
      }
    }
    return list;
  }
}

/// 날짜 목록을 불러옴
class GetSleepConditionDateService extends BaseService<List<SleepConditionDateResponse>> {
  GetSleepConditionDateService();

  @override
  Future<http.Response> request() async {
    return fetchGet();
  }

  @override
  setUrl() {
    return AppDAO.baseUrl + 'conditions/sleep-analysis/date_list';
  }

  @override
  List<SleepConditionDateResponse> success(body){
    List<SleepConditionDateResponse> list = [];
    if(body is List<dynamic>){
      for (var element in body) {
        list.add(SleepConditionDateResponse.fromJson(element));
      }
    }
    return list;
  }
}