import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:sleepaid/app_routes.dart';
import 'package:sleepaid/page/splash_page.dart';
import 'package:sleepaid/provider/bluetooth_provider.dart';
import 'package:sleepaid/provider/data_provider.dart';
import 'package:sleepaid/util/app_themes.dart';
import 'data/local/app_dao.dart';
import 'util/app_config.dart';
import 'provider/auth_provider.dart';


/**
 * 플러터 기본 실행 함수
 */
void main() async {
  //global 프로덕트 / 개발 모드 설정
  gFlavor = Flavor.PROD;
  if (kReleaseMode) {
    gFlavor = Flavor.PROD;
  } else {
    gFlavor = Flavor.DEV;
  }
  await mainInit();
}

/**
 * 기본 실행 시 호출 되어야하는 기본 값 함수
 */
Future<void> mainInit() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDAO.init();
  //화면 회전 막는 기능
  if(!AppDAO.debugData.cancelBlockRotationDevice){
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }
  await AppDAO.checkDarkMode;
  //Pheonix - 예상치 못한 오류 발생시 앱 새로 실행하는 패키지 적용
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => BluetoothProvider()),
          ChangeNotifierProvider(create: (_) => DataProvider()),
        ],
        child: Phoenix(child: SleepAIDApp()),
      )
  );
}

/**
 * 기본 앱
 */
class SleepAIDApp extends StatefulWidget {
  SleepAIDApp({Key? key}) : super(key: key);
  static _SleepAIDApp? of(BuildContext context) => context.findAncestorStateOfType<_SleepAIDApp>();
  State<StatefulWidget> createState() => _SleepAIDApp();
}

class _SleepAIDApp extends State<SleepAIDApp> {
  //페이지를 Router를 통하여 관리하기 위한 기본 RouteObserver
  final routeObserver = RouteObserver<PageRoute>();

  ThemeData _theme = AppThemes.lightTheme;

  void changeTheme(ThemeData themeData) {
    _theme = themeData;
    setState(() {});
  }

  checkDarkMode() {
    _theme = AppDAO.isDarkMode?AppThemes.darkTheme:AppThemes.lightTheme;
  }

  @override
  Widget build(BuildContext context) {
    // //todo 상태바 숨기기 기능(추후 UI에 따라서 수정)
    // SystemChrome.setSystemUIOverlayStyle(
    //     const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    checkDarkMode();
    return MaterialApp(
      // 디버그모드 알림 배너 숨김
      debugShowCheckedModeBanner: false,
      //기본 테마
      theme: _theme,
      initialRoute: SplashPage.ROUTE,
      // color: Colors.transparent,
      navigatorObservers: [
        routeObserver
      ],
      onGenerateRoute: (RouteSettings settings){
        return Routes.generateRoute(settings,context);
      },
    );
  }
}