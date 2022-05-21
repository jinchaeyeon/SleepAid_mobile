import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:sleepaid/app_routes.dart';
import 'package:sleepaid/page/splash_page.dart';
import 'app_config.dart';
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
  mainInit();
}

/**
 * 기본 실행 시 호출 되어야하는 기본 값 함수
 */
void mainInit() {
  WidgetsFlutterBinding.ensureInitialized();

  //화면 회전 막는 기능
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  //Pheonix - 예상치 못한 오류 발생시 앱 새로 실행하는 패키지 적용
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: Phoenix(child: SleepAIDApp()),
      )
  );
}

/**
 * 기본 앱
 */
class SleepAIDApp extends StatelessWidget {
  //페이지를 Router를 통하여 관리하기 위한 기본 RouteObserver
  final routeObserver = RouteObserver<PageRoute>();

  SleepAIDApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // //todo 상태바 숨기기 기능(추후 UI에 따라서 수정)
    // SystemChrome.setSystemUIOverlayStyle(
    //     const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return MaterialApp(
      // 디버그모드 알림 배너 숨김
      debugShowCheckedModeBanner: false,
      //기본 테마
      theme: ThemeData(
          primarySwatch: Colors.cyan),
      initialRoute: SplashPage.ROUTE,
      navigatorObservers: [
        routeObserver
      ],
      onGenerateRoute: onGenerateRoute,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}