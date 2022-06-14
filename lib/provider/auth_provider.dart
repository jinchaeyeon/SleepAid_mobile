import 'package:flutter/widgets.dart';
import 'package:sleepaid/data/network/base_response.dart';
import 'package:sleepaid/data/network/license_response.dart';
import 'package:sleepaid/network/license_service.dart';
import 'package:sleepaid/network/signup_service.dart';

class AuthProvider with ChangeNotifier{
  /// SNS 가입자라면 라이센스 인증처리
  /// 가입 시작하는 이메일 가입자라면 이메일 가입 처리 진행 시작
  Future<int> checkLicense(String text) async{
    var params = {'licenseKey': text};
    var response = await PostLicenseValuableService(body:params).start();
    if(response is LicenseResponse){
      //응답체크
      return BaseResponse.STATE_CORRECT;
    }else{
      //이상응답
      // 네트워크 이슈등이면 STATE_NO_CONNECT, 값이 이상하면 STATE_LICENSE_UNCORRECT
      // return LicenseResponse.STATE_NO_CONNECT;
      return BaseResponse.STATE_UNCORRECT;
    }
  }

  Future<int> signup(String email, String encPW) async{
    var params = {'email': email, 'password':encPW};
    var response = await PostSignUpService(body:params).start();
    if(response is LicenseResponse){
      //응답체크
      return BaseResponse.STATE_CORRECT;
    }else{
      //이상응답
      // 네트워크 이슈등이면 STATE_NO_CONNECT, 값이 이상하면 STATE_LICENSE_UNCORRECT
      // return LicenseResponse.STATE_NO_CONNECT;
      return BaseResponse.STATE_UNCORRECT;
    }
  }
}

