import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/network/binarual_beat_recipe_response.dart';
import 'package:sleepaid/data/network/binaural_beat_parameter_response.dart';
import 'package:sleepaid/data/network/electro_stimulation_parameter_response.dart';
import 'package:sleepaid/data/network/sleep_condition_parameter_response.dart';
import 'package:sleepaid/network/base_service.dart';
import 'package:http/http.dart' as http;

class GetBinauralBeatsService extends BaseService<List<BinauralBeatParameterResponse>> {
  GetBinauralBeatsService();

  @override
  Future<http.Response> request() async {
    return fetchGet();
  }

  @override
  setUrl() {
    return AppDAO.baseUrl + 'devices/binaural-beats';
  }

  @override
  List<BinauralBeatParameterResponse> success(body){
    List<BinauralBeatParameterResponse> list = [];
    if(body is List<dynamic>){
      for (var element in body) {
        list.add(BinauralBeatParameterResponse.fromJson(element));
      }
    }
    return list;
  }
}