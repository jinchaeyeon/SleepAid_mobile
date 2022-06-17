import 'package:sembast/sembast.dart';
import 'package:sleepaid/data/auth_data.dart';
import 'package:sleepaid/data/local/app_database.dart';

class DebugData{
  bool hasDummyUserInfo = false; // 더미 유저정보를 가지고 시작
  bool passCheckingLicenseKey = false;  // 라이센스키 값이 올바른지 확인하는지
  bool passCheckingSignupAPI = false; // 회원가입 API 확인 안하고 넘어가도록 처리
  bool cancelBlockRotationDevice = false; // 화면 기울임 회전 막아둔 기능 풀기

  bool inputTestInputData = true; // 테스트와 관련된 입력값 미리 넣어두기
  String licenseKey = "3xvzak5g";

  String signupEmail = "redlunak89@gmail.com";
  String signupPW = "qwer1234@@";
}

class AppDAO{

  static _put({required String key, dynamic value}) async {
    var store = StoreRef.main();
    var db = await AppDatabase.instance.database;
    await store.record(key).put(db, value);
  }

  static Future<dynamic> _get({required String key}) async {
    var store = StoreRef.main();
    var db = await AppDatabase.instance.database;
    return await store.record(key).get(db) as dynamic;
  }

  static _delete({required String key}) async {
    var store = StoreRef.main();
    var db = await AppDatabase.instance.database;
    await store.record(key).delete(db);
  }

  static DebugData debugData = DebugData();
  static AuthData authData = AuthData();
  static var appVersion = '1.0.0';
  static bool isDarkMode = false;

  static String HOST_PRODUCT = "https://neurotx.lhy.kr/api/";
  static String DEBUG_PRODUCT = "https://neurotx-dev.lhy.kr/api/";


  static String get baseUrl {
    /// 테스트버전 여기서 분기처리
    return HOST_PRODUCT;
  }

  static setAppVersion(String version) {
    appVersion = version;
  }

  ///전체 데이터 초기화
  static Future clearAllData() async{
    await setUserToken(null);
    await setUserType(null);
    await setDarkMode(null);
  }

  static Future setUserToken(String? token) async{
    token != null
        ? await _put(key: 'user_token', value: token)
        : await _delete(key: 'user_token');
  }

  static Future<String?> get userToken async {
    String? userToken = await _get(key: 'user_token') as String?;
    return userToken;
  }

  static Future setUserType(String? token) async{
    token != null
        ? await _put(key: 'user_type', value: token)
        : await _delete(key: 'user_type');
  }

  static Future<String?> get userType async {
    String? userToken = await _get(key: 'user_type') as String?;
    return userToken;
  }

  static Future setDarkMode(bool? _isDarkMode) async{
    _isDarkMode != null
        ? await _put(key: 'is_dark_mode', value: _isDarkMode)
        : await _delete(key: 'is_dark_mode');
    isDarkMode = _isDarkMode??=false;
  }

  static Future<bool> get checkDarkMode async {
    bool? _isDarkMode = await _get(key: 'is_dark_mode') as bool?;
    isDarkMode = _isDarkMode??=false;
    return isDarkMode;
  }
}

