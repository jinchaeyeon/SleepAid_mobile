import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sleepaid/app_routes.dart';
import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/network/sleep_analysis_response.dart';
import 'package:sleepaid/network/get_sleep_condition_service.dart';
import 'package:sleepaid/network/sleeping_analytics_service.dart';
import 'package:sleepaid/provider/auth_provider.dart';
import 'package:sleepaid/provider/data_provider.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/util/functions.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:provider/provider.dart';


/**
 * 앱 시작시 사용되는 SPLASH PAGE
 * 기본 데이터를 호출하여 로컬 상태 저장
 * 1. 인증 정보
 * 2. 기기 연결 상태
 * 3. 서버에서 갱신 된 데이터
 * 4. 신규 알림
 */
class SplashPage extends BaseStatefulWidget {
  static const ROUTE = "/";

  const SplashPage({Key? key}) : super(key: key);

  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<SplashPage>
    with SingleTickerProviderStateMixin{

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    checkState();
    return Scaffold(
        extendBody: true,
        body: SafeArea(
            child: Container(
                color: AppColors.COLOR_BG_SPASH,
                width: double.maxFinite,
                height: double.maxFinite,
                alignment: Alignment.center,
                child: Image.asset(AppImages.IMAGE_BG_SPLASH, fit: BoxFit.contain,)
            )
        )
    );
  }

  Future<void> checkState() async{
    Future.delayed(const Duration(milliseconds: 100), () async {
      await checkAppVersion();
      await checkStoragePermission();
      await checkLoginState();
    });
  }

  Future<void> checkStoragePermission() async {
    Map<Permission, PermissionStatus> statuses =
    await [Permission.storage].request();
    if(statuses[Permission.storage] == PermissionStatus.denied){
      completedExit(context);
    }
  }

  /// 로그인 했는지 서버와 통신
  /// 로그인 상태면
  ///   필수 데이터 서버에서 갱신
  ///     1. 수면컨디션 목록 정보
  ///     2. 기기 파라미터 추가 정보
  ///   이후 바로 메인홈으로 이동
  /// 비로그인 상태면 로그인 페이지로 이동
  Future<void> checkLoginState() async{
    Future.delayed(const Duration(milliseconds: 2000), () async {
      await checkNetworkState().then((connected) async {
        if(connected){
          if(AppDAO.debugData.hasDummyUserInfo){
            Navigator.pushReplacementNamed(context, Routes.home);
            return;
          }
          if(await AppDAO.authData.isLoggedIn){
            /// 로그인 되었으면 로그인 필수 데이터 가져오기
            await checkSleepCondition();
            Navigator.pushReplacementNamed(context, Routes.home);
          }else{
            Navigator.pushReplacementNamed(context, Routes.loginList);
          }
          return;
        }else{
          showToast("네트워크 연결 상태를 확인해주세요");
          completedExit(context);
        }
      });
    });
  }

  /**
   * 버전정보 체크
   */
  Future<void> checkAppVersion() async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    await AppDAO.setAppVersion(version);
  }

  checkSleepCondition() async{
    await context.read<DataProvider>().loadParameters();
    String yesterday = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(Duration(days:1)));
    List<dynamic> result = await AppDAO.getLastSleepCondition();
    if(yesterday == result[0] && result[1] != null) {
      await GetSleepConditionDetailService(id: "${result[1]!}").start().then((response){
        if(response is SleepAnalysisResponse){
          AppDAO.baseData.sleepConditionAnalysis = response;
        }
      });
    }
  }
}