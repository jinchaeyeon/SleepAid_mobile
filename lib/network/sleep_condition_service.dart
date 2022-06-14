import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/network/license_response.dart';
import 'package:sleepaid/data/network/signup_response.dart';
import 'package:sleepaid/data/network/sleep_condition_response.dart';
import 'package:sleepaid/network/base_service.dart';
import 'package:http/http.dart' as http;

class GetSleepConditionService extends BaseService<SleepConditionItemListResponse> {
  Map<String, String> body;

  GetSleepConditionService({required this.body});

  @override
  Future<http.Response?> request() async {
    return fetchPost(body: body);
  }

  @override
  setUrl() {
    return AppDAO.baseUrl + 'sleep/condition/items';
  }

  @override
  SleepConditionItemListResponse success(body) {
    SleepConditionItemListResponse responose = SleepConditionItemListResponse.fromJson(body);
    return responose;
  }
}