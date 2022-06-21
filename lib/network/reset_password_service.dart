import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/network/base_response.dart';
import 'package:sleepaid/data/network/license_response.dart';
import 'package:sleepaid/data/network/auth_response.dart';
import 'package:sleepaid/data/network/reset_password_response.dart';
import 'package:sleepaid/network/base_service.dart';
import 'package:http/http.dart' as http;

class PostResetPasswordService extends BaseService<ResetPasswordResponse> {
  String email;

  PostResetPasswordService({required this.email});

  @override
  Future<http.Response?> request() async {
    return await fetchPost(body: {"email": email});
  }

  @override
  setUrl() {
    return AppDAO.baseUrl + 'users/reset_password';
  }

  @override
  ResetPasswordResponse success(body) {
    ResetPasswordResponse responose = ResetPasswordResponse(state:BaseResponse.STATE_CORRECT);
    return responose;
  }
}