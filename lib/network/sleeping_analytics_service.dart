import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/network/sleep_analysis_response.dart';
import 'package:sleepaid/network/base_service.dart';
import 'package:http/http.dart' as http;

class GetSleepConditionsService extends BaseService<bool> {
  GetSleepConditionsService();

  @override
  Future<http.Response> request() async {
    return fetchGet();
  }

  @override
  setUrl() {
    return AppDAO.baseUrl + 'conditions/sleep-conditions';
  }

  @override
  bool success(body){
    return true;
  }
}


class GetSleepConditionDetailService extends BaseService<bool> {
  String id;
  GetSleepConditionDetailService({required this.id});

  @override
  Future<http.Response> request() async {
    return fetchGet();
  }

  @override
  setUrl() {
    return AppDAO.baseUrl + 'conditions/sleep-analysis/$id';
  }

  @override
  bool success(body){
    return true;
  }
}

class PostSleepConditionService extends BaseService<SleepAnalysisResponse> {
  Map<String, dynamic> body = {};

  PostSleepConditionService({
    required int id, required String date,
    required int awake, required int rem, required int light,
    required int deep, required int quality, required List<dynamic> itemSet,
  }){
    body = {
      "id":id, "date":date,
      "awake": awake, "rem":rem, "light":light,
      "deep": deep, "quality":quality, "item_set":itemSet
    };
  }

  @override
  Future<http.Response?> request() async {
    return fetchPost(body: body);
  }

  @override
  setUrl() {
    return AppDAO.baseUrl + 'conditions/sleep-analysis';
  }

  @override
  SleepAnalysisResponse success(body) {
    SleepAnalysisResponse responose = SleepAnalysisResponse.fromJson(body);
    return responose;
  }
}