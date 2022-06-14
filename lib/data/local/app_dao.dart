import 'package:sleepaid/data/auth_data.dart';
import 'package:sleepaid/data/network/sleep_condition_response.dart';

class DebugData{
  bool hasDummyUserInfo = true; // 더미 유저정보를 가지고 시작
  bool passCheckingLicenseKey = true;  // 라이센스키 값이 올바른지 확인하는지
  bool passCheckingSignupAPI = true; // 회원가입 API 확인 안하고 넘어가도록 처리
  bool cancelBlockRotationDevice = false; // 화면 기울임 회전 막아둔 기능 풀기
}

class AppDAO{
  static DebugData debugData = DebugData();
  static bool isDarkMode = false;
  static AuthData authData = AuthData();
  static var appVersion = '1.0.0';


  static String get baseUrl {
    /// 테스트버전 생기면 여기서 분기처리
    return "https://finance.yahoo.com/quote/NVAX/community?p=NVAX";
  }

  static Future<String?> get accessToken async {
    /// 디버그 모드/더미 유저모드는 더미 데이터 리턴
    if(debugData.hasDummyUserInfo){
      return "1004";
    }
    // return await _get(key: 'accessToken') as String?;
    return null;
  }

  static Future<USER_TYPE> get userType async {
    /// 디버그 모드/더미 유저모드는 더미 데이터 리턴
    if(debugData.hasDummyUserInfo){
      return USER_TYPE.EMAIL_USER;
    }
    // return await _get(key: 'accessToken') as String?;
    return USER_TYPE.NO_USER;
  }

  static setAppVersion(String version) {
    appVersion = version;
  }

  ///테마 변경
  static setDarkMode(bool isDarkMode) {
    AppDAO.isDarkMode = isDarkMode;
  }

  ///전체 데이터 초기화
  static clearAllData() {

  }


  // static Future setUuid(String? id) async {
  //   id != null
  //       ? await _put(key: 'uuid', value: id)
  //       : await _delete(key: 'uuid');
  // }
  //
  // static Future<String> get uuid async {
  //   String? id = await _get(key: 'uuid') as String?;
  //   if (id == null) {
  //     id = await UuIdGenerator.generateUuid();
  //     await AppDao.setUuid(id);
  //   }
  //
  //   return id!;
  // }
}

