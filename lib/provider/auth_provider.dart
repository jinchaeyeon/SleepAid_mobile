import 'package:flutter/widgets.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sleepaid/app_routes.dart';
import 'package:sleepaid/data/auth_data.dart';
import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/network/auth_response.dart';
import 'package:sleepaid/data/network/base_response.dart';
import 'package:sleepaid/data/network/license_response.dart';
import 'package:sleepaid/network/license_service.dart';
import 'package:sleepaid/network/signup_email_service.dart';
import 'package:sleepaid/network/signup_sns_service.dart';
import 'package:sleepaid/network/sns_login_service.dart';
import 'package:sleepaid/util/functions.dart';
import 'package:sleepaid/util/logger/service_error.dart';

class AuthProvider with ChangeNotifier{
  /// SNS 가입자라면 라이센스 인증처리
  /// 가입 시작하는 이메일 가입자라면 이메일 가입 처리 진행 시작
  Future<int> checkLicense(String text) async{
    var response = await GetLicenseValuableService(licenseKey: text).start();
    if(response == true){
      return BaseResponse.STATE_CORRECT;
      //응답체크
      return BaseResponse.STATE_CORRECT;
    }else{
      //이상응답
      // 네트워크 이슈등이면 STATE_NO_CONNECT, 값이 이상하면 STATE_LICENSE_UNCORRECT
      // return LicenseResponse.STATE_NO_CONNECT;
      return BaseResponse.STATE_UNCORRECT;
    }
  }

  Future<int> signup(String email, String pw) async{
    String? snsUID = AppDAO.authData.temporarySNSUID;
    String? snsType = AppDAO.authData.temporarySNSType;
    String? licenseKey = AppDAO.authData.temporaryLicenseKey;
    var response;
    if(snsUID != "" && snsType != ""){
      response = await PostSignUpSNSService(
        type: snsType,
        uid : snsUID,
        email:email,
        licenseKey: licenseKey,
      ).start();
    }else{
      var params = {'email': email, 'password':pw, 'license_key':AppDAO.authData.temporaryLicenseKey};
      response = await PostSignUpEmailService(body:params).start();
    }

    if(response is LicenseResponse){
      //응답체크
      return BaseResponse.STATE_CORRECT;
    }else if(response is ServiceError){
      Fluttertoast.showToast(msg: response.message??"");
      //응답체크
      return BaseResponse.STATE_UNCORRECT;
    }
    else{
      //이상응답
      // 네트워크 이슈등이면 STATE_NO_CONNECT, 값이 이상하면 STATE_LICENSE_UNCORRECT
      // return LicenseResponse.STATE_NO_CONNECT;
      return BaseResponse.STATE_NO_CONNECT;
    }
  }

  /// 소셜 인증체크
  ///
  Future checkSNSLogin(BuildContext context, String? userType) async{
    print("userType: ${userType}");
      if(userType == null) return;
    String? uid;
    if(userType == AuthData.userTypes["naver"]){
      NaverLoginResult res = await FlutterNaverLogin.logIn();
      uid = res?.account.id;

      print("Naver result: ${res.accessToken}");
      print("Naver result: ${res.account.id}");
      print("Naver result: ${res.account.email}");
    }else if(userType == AuthData.userTypes["facebook"]){
      GoogleSignIn _googleSignIn = GoogleSignIn(
        // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
        scopes: <String>[
          'email',
          'https://www.googleapis.com/auth/contacts.readonly',
        ],
      );
      // Create an instance of FacebookLogin
      final _fb = FacebookLogin();
      final _res = await _fb.logIn(permissions: [
        FacebookPermission.publicProfile,
        FacebookPermission.email,
      ]);
      switch (_res.status) {
        case FacebookLoginStatus.success:
          final FacebookAccessToken? accessToken = _res.accessToken;
          print('Access token: ${accessToken?.token}');
          _fb.getUserProfile().then((FacebookUserProfile? _profile){
            uid = _profile?.userId;
            print("fb result: ${uid}");
          });
          break;
        case FacebookLoginStatus.cancel:
          break;
        case FacebookLoginStatus.error:
          showToast('Error while log in: ${_res.error}');
          break;
      }
    }else if(userType == AuthData.userTypes["google"]){
      GoogleSignIn _googleSignIn = GoogleSignIn(
        // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
        scopes: <String>[
          'email',
          'https://www.googleapis.com/auth/contacts.readonly',
        ],
      );
      await _googleSignIn.signIn().then((GoogleSignInAccount? account){
        print("google result: ${account?.id}");
        uid = account?.id;
      });

    }
    if(uid == null){
      showToast("인증 실패. 다시 시도해주세요.");
      return;
    }
    var result = await PostSNSLoginService(type: userType!, uid: uid!).start();
    if(result is LoginResponse){
      //로그인 완료 홈화면 이동
      showToast("로그인 성공");
    }

    if(result is ServiceError){
      //인증 성공, 로그인 실패(미가입)
      if(result.code == ServiceError.NON_FIELD_ERRORS && result.message == PostSNSLoginService.NO_SIGNED_USER_MESSAGGE){
        //소셜가입이 되어있지 않으면 가입 시작
        AppDAO.authData.temporarySNSType = userType;
        AppDAO.authData.temporarySNSUID = uid!;
        Navigator.pushNamed(context, Routes.licenseKey);
      }else{
        showToast("잠시 후 다시 시도해주세요.");
      }
    }
  }
}

