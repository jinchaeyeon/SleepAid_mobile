import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/network/license_response.dart';
import 'package:sleepaid/network/base_service.dart';
import 'package:http/http.dart' as http;

class PostLicenseValuableService extends BaseService<LicenseResponse> {
  Map<String, String> body;

  PostLicenseValuableService({required this.body});

  @override
  Future<http.Response> request() async {
    return fetchPost();
  }

  @override
  setUrl() {
    return AppDAO.baseUrl + 'check/license';
  }

  @override
  LicenseResponse success(body) {
    LicenseResponse licenseResponose = LicenseResponse.fromJson(body);
    return licenseResponose;
  }
}