import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/network/electro_stimulation_parameter_response.dart';
import 'package:sleepaid/data/network/sleep_condition_parameter_response.dart';
import 'package:sleepaid/network/base_service.dart';
import 'package:http/http.dart' as http;

class GetElectroStimulationsService extends BaseService<List<ElectroStimulationParameterResponse>> {
  GetElectroStimulationsService();

  @override
  Future<http.Response> request() async {
    return fetchGet();
  }

  @override
  setUrl() {
    return AppDAO.baseUrl + 'devices/electro-stimulations';
  }

  @override
  List<ElectroStimulationParameterResponse> success(body){
    List<ElectroStimulationParameterResponse> list = [];
    if(body is List<dynamic>){
      for (var element in body) {
        list.add(ElectroStimulationParameterResponse.fromJson(element));
      }
    }
    return list;
  }
}