import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/network/base_service.dart';
import 'package:http/http.dart' as http;

class GetLicenseValuableService extends BaseService<bool> {
  String licenseKey;
  GetLicenseValuableService({required this.licenseKey});

  @override
  Future<http.Response> request() async {
    return fetchGet();
  }

  @override
  setUrl() {
    return AppDAO.baseUrl + 'users/licenses/validate?license_key=$licenseKey';
  }

  @override
  bool success(body){
    return true;
  }
}