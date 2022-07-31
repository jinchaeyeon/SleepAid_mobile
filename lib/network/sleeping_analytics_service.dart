import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/network/sleep_analysis_response.dart';
import 'package:sleepaid/network/base_service.dart';
import 'package:http/http.dart' as http;

class GetSleepConditionsService extends BaseService<List<SleepAnalysisResponse>> {
  GetSleepConditionsService();

  @override
  Future<http.Response> request() async {
    return fetchGet();
  }

  @override
  setUrl() {
    return AppDAO.baseUrl + 'conditions/sleep-analysis';
  }

  @override
  List<SleepAnalysisResponse> success(body){
    List<SleepAnalysisResponse> list = [];
    if(body is List<dynamic>){
      for (var element in body) {
        list.add(SleepAnalysisResponse.fromJson(element));
      }
    }
    return list;
  }
}


class GetSleepConditionDetailService extends BaseService<SleepAnalysisResponse> {
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
  SleepAnalysisResponse success(body){
    SleepAnalysisResponse responose = SleepAnalysisResponse.fromJson(body);
    return responose;
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