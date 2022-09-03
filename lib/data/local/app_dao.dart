import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/timestamp.dart';
import 'package:sleepaid/data/auth_data.dart';
import 'package:sleepaid/data/local/app_database.dart';
import 'package:sleepaid/data/network/binaural_beat_parameter_response.dart';
import 'package:sleepaid/data/network/electro_stimulation_parameter_response.dart';
import 'package:sleepaid/data/network/sleep_analysis_response.dart';
import 'package:sleepaid/data/network/sleep_condition_parameter_response.dart';
import 'package:sleepaid/util/app_themes.dart';

class AppBaseData {
  List<SleepConditionParameterResponse> sleepConditionParameters = [];
  List<ElectroStimulationParameterResponse> electroStimulationParameters = [];
  /// 사용자 맞춤설정 우선 랜덤 처리
  BinauralBeatParameterResponse binauralBeatUserTargetParameter = BinauralBeatParameterResponse(id:0, onDisplay:true, name:"사용자 맞춤 설정", toneFrequency:900, beatFrequency: 40);
  List<BinauralBeatParameterResponse> binauralBeatParameters = [];
  SleepAnalysisResponse? sleepConditionAnalysis;

  /// 저장되어 있는 어제의 수면 컨디션 숫자
  int getSleepConditionYesterdayItemSet() {
    return sleepConditionAnalysis?.itemSet.length??0;
  }
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
  static ThemeData theme = AppThemes.lightTheme;
  static ThemeData darkTheme = AppThemes.darkTheme;
  static ThemeData lightTheme = AppThemes.lightTheme;

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
    await setUserCreated(null);
    await resetSNSLogin();
    await setLastSleepCondition(null, null);
  }

  /// 컨디션 작성 날짜
  /// 어제 기준으로 작성
  static String getConditionDateString({SleepAnalysisResponse? response, DateTime? selectedDate}) {
    var dateFormat = DateFormat("yyyy년 MM월 dd일");
    if(response != null){
      List<String> dateStrings = response.date.split("-");
      return "${dateStrings[0]}년 ${dateStrings[1]}월 ${dateStrings[2]}일";
    }else if(selectedDate != null){
      return dateFormat.format(selectedDate);
    }else{
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
        // ? await _put(key: 'created', value: Timestamp.fromDateTime(created.subtract(Duration(days:90))))
        : await _delete(key: 'created');
    authData.created = created??DateTime.now().subtract(const Duration(days:1));
  }

  static Future<DateTime> get userCreated async {
    Timestamp? timestamp = await _get(key: 'created') as Timestamp?;
    print("userCreated: ${timestamp?.toIso8601String()}");
    authData.created = timestamp?.toDateTime()??DateTime.now().subtract(const Duration(days:1));
    return authData.created!;
    // return authData.created!.subtract(Duration(days: 90));
  }

  static Future init() async{
    await userCreated;
  }

  static Future<void> setLastSleepCondition(String? date, int? id) async {
    date != null
        ? await _put(key: 'last_sleep_condition_date', value: date)
        : await _delete(key: 'last_sleep_condition_date');

    id != null
        ? await _put(key: 'last_sleep_condition_id', value: id)
        : await _delete(key: 'last_sleep_condition_id');
  }

  static Future<List<dynamic>> getLastSleepCondition() async{
    String? lastDate = await _get(key: 'last_sleep_condition_date') as String?;
    int? lastID = await _get(key: 'last_sleep_condition_id') as int?;
    return [lastDate, lastID];
  }

  static Future<void> setAutoLogin(bool isAutoLogin) async{
    isAutoLogin == true
        ? await _put(key: 'is_auto_login', value: isAutoLogin)
        : await _delete(key: 'is_auto_login');
  }

  static Future<bool> isAutoLogin() async{
    bool? isAutoLogin = await _get(key: 'is_auto_login') as bool?;
    return isAutoLogin??false;
  }

  static resetSNSLogin() async{
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: <String>[
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );
    try{
      if(await _googleSignIn.isSignedIn()){
        await _googleSignIn.signOut();
      }

      final _fb = FacebookLogin();
      if(await _fb.isLoggedIn){
        await _fb.logOut();
      }

      if(await FlutterNaverLogin.isLoggedIn){
        await FlutterNaverLogin.logOutAndDeleteToken();
      }
    }catch(e){
      print("err: $e");
    }
  }

  static Future<bool> get isOnChannelDefault async {
    bool? isOnChannelDefault = await _get(key: 'is_on_channel_default') as bool?;
    return isOnChannelDefault??true;
  }

  static Future<bool> get isOnChannelAfternoon async {
    bool? isOnChannelAfternoon = await _get(key: 'is_on_channel_afternoon') as bool?;
    return isOnChannelAfternoon??true;
  }

  static Future<void> setOnChannelDefault(bool isOnChannelDefault) async{
    isOnChannelDefault == true
        ? await _put(key: 'is_on_channel_default', value: isOnChannelDefault)
        : await _delete(key: 'is_on_channel_default');
  }

  static Future<void> setOnChannelAfternoon(bool isOnChannelAfternoon) async{
    isOnChannelAfternoon == true
        ? await _put(key: 'is_on_channel_afternoon', value: isOnChannelAfternoon)
        : await _delete(key: 'is_on_channel_afternoon');
  }
}

