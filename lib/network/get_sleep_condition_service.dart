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