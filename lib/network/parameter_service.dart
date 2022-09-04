import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/network/binarual_beat_recipe_response.dart';
import 'package:sleepaid/data/network/binaural_beat_parameter_response.dart';
import 'package:sleepaid/data/network/electro_stimulation_parameter_response.dart';
import 'package:sleepaid/data/network/sleep_condition_parameter_response.dart';
import 'package:sleepaid/network/base_service.dart';
import 'package:http/http.dart' as http;

import '../data/network/parameter_response.dart';

class GetParameterService extends BaseService<List<ParameterResponse>> {
  GetParameterService();

  @override
  Future<http.Response> request() async {
    return fetchGet();
  }

  @override
  setUrl() {
    return AppDAO.baseUrl + 'devices/parameters';
  }

  @override
  List<ParameterResponse> success(body){
    List<ParameterResponse> list = [];
    if(body is List<dynamic>){
      for (var element in body) {
        list.add(ParameterResponse.fromJson(element));
      }
    }
    return list;
  }
}