import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:sleepaid/app_routes.dart';
import 'package:sleepaid/page/splash_page.dart';
import 'package:sleepaid/provider/bluetooth_provider.dart';
import 'package:sleepaid/provider/data_provider.dart';
import 'package:sleepaid/provider/main_provider.dart';
import 'data/firebase/firebase_option.dart';
import 'data/firebase/message.dart';
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

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;


/**
 * 기본 실행 시 호출 되어야하는 기본 값 함수
 */
Future<void> mainInit() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AppDAO.init();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("fcm Token : ${fcmToken}");
  ///todo fcm API 적용

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance
      .setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.instance.onTokenRefresh
      .listen((fcmToken) {
    /// todo 업데이트 코드 입력 API 추가 처리
  })
      .onError((err) {
  });

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
          ChangeNotifierProvider(create: (_) => MainProvider()),
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

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        Navigator.pushNamed(
          context,
          '/message',
          arguments: MessageArguments(message, true),
        );
      }
    });

    ///todo 로컬 디비에 저장된 값으로 이부분 변경
    FirebaseMessaging.instance.subscribeToTopic("all");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      Navigator.pushNamed(context, Routes.splash);
    });
  }

  void changeTheme() {
    checkDarkMode();
    setState(() {});
  }

  checkDarkMode() {
    AppDAO.theme = AppDAO.isDarkMode?AppDAO.darkTheme:AppDAO.lightTheme;
  }

  @override
  Widget build(BuildContext context) {
    checkDarkMode();
    checkMicrophoneStatus(context);
    return MaterialApp(
      // 디버그모드 알림 배너 숨김
      debugShowCheckedModeBanner: false,
      //기본 테마
      theme: AppDAO.theme,
      initialRoute: SplashPage.ROUTE,
      // color: Colors.transparent,
      navigatorObservers: [
        routeObserver
      ],
      routes: {
        '/': (_) => const SplashPage(),
      },
      onGenerateRoute: (RouteSettings settings){
        return Routes.generateRoute(settings,context);
      },
    );
  }

  Future<void> checkMicrophoneStatus(BuildContext context) async {
    await context.read<MainProvider>().startMicrophoneScan();
  }
}