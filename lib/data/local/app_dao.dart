import 'package:headset_connection_event/headset_event.dart';
import 'package:intl/intl.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/timestamp.dart';
import 'package:sleepaid/data/auth_data.dart';
import 'package:sleepaid/data/local/app_database.dart';
import 'package:sleepaid/data/network/binaural_beat_parameter_response.dart';
import 'package:sleepaid/data/network/electro_stimulation_parameter_response.dart';
import 'package:sleepaid/data/network/sleep_analysis_response.dart';
import 'package:sleepaid/data/network/sleep_condition_parameter_response.dart';

class AppBaseData {
  List<SleepConditionParameterResponse> sleepConditionParameters = [];
  List<ElectroStimulationParameterResponse> electroStimulationParameters = [];
  List<BinauralBeatParameterResponse> binauralBeatParameters = [];
  SleepAnalysisResponse? sleepConditionAnalysis;
}

class DebugData{
  bool showDebugPrint = true; //디버그 프린트 할지 처리
  bool hasDummyUserInfo = false; // 더미 유저정보를 가지고 시작
  bool passCheckingLicenseKey = false;  // 라이센스키 값이 올바른지 확인하는지
  bool passCheckingSignupAPI = false; // 회원가입 API 확인 안하고 넘어가도록 처리
  bool cancelBlockRotationDevice = false; // 화면 기울임 회전 막아둔 기능 풀기

  bool inputTestInputData = true; // 테스트와 관련된 입력값 미리 넣어두기
  String licenseKey = "jf0wxfdz";
  String signupEmail = "redlunak89@gmail.com";
  String signupPW = "qwer1234@@";
}

class AppDAO{
  static bool completeInit = false;

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
  static AppBaseData baseData = AppBaseData();
  static DebugData debugData = DebugData();
  static AuthData authData = AuthData();
  static var appVersion = '1.0.0';
  static bool isDarkMode = false;

  static String HOST_PRODUCT = "https://sleepaid.co.kr/api/";
  static String DEBUG_PRODUCT = "https://dev.sleepaid.co.kr/api/";


  static String get baseUrl {
    /// 테스트버전 여기서 분기처리
    return HOST_PRODUCT;
  }

  static setAppVersion(String version) {
    appVersion = version;
  }

  /// 전체 데이터 초기화
  static Future clearAllData() async{
    await setUserToken(null);
    await setUserType(null);
    await setDarkMode(false);
  }

  /// 컨디션 작성 날짜
  /// 어제 기준으로 작성
  static String getConditionDateString() {
    if(AppDAO.baseData.sleepConditionAnalysis != null){
      List<String> dateStrings = AppDAO.baseData.sleepConditionAnalysis!.date.split("-");
      return "${dateStrings[0]}년 ${dateStrings[0]}월 ${dateStrings[2]}일";
    }else{
      var dateFormat = DateFormat("yyyy년 mm월 dd일");
      var yesterday = DateTime.now().subtract(const Duration(days: 1));
      return dateFormat.format(yesterday);
    }
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

  static Future setUserCreated(DateTime? created) async{
    created != null
        ? await _put(key: 'created', value: Timestamp.fromDateTime(created))
        : await _delete(key: 'created');
  }

  static Future<DateTime> get userCreated async {
    Timestamp? timestamp = await _get(key: 'created') as Timestamp?;
    authData.created = timestamp?.toDateTime()??DateTime.now().subtract(Duration(days:1));
    return authData.created!;
  }

  static Future init() async{
    await userCreated;
  }

  static Future<void> setLastSleepCondition(String date, int id) async {
    await _put(key: 'last_sleep_condition_date', value: date);
    await _put(key: 'last_sleep_condition_id', value: id);
  }

  static Future<List<String?>> getLastSleepCondition() async{
    String? lastDate = await _get(key: 'last_sleep_condition_date') as String?;
    String? lastID = await _get(key: 'last_sleep_condition_id') as String?;
    return [lastDate, lastID];
  }
}

