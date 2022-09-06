import 'dart:developer';
import 'dart:io';

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
import 'data/network/push_response.dart';
import 'network/set_fcm_token_service.dart';
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
  mainInit();
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();
  showFlutterNotification(message);
  log('Handling a background message ${message.messageId}');
}

void showFlutterNotification(RemoteMessage message) async{
  RemoteNotification? notification = message.notification;
  Map<String, dynamic> data = message.data;
  // AndroidNotification? android = message.notification?.android;
  String title = "";
  String body = "";
  if(notification != null){
    title = notification.title??"";
    body = notification.body??"";
  }else{
    title = data["title"]??"";
    body = data["body"]??"";
  }

  await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      getPlatformSpecifics(),
      // payload: json.encode(pushNotification));
  ).then((value){
    print("showFlutterNotification \ntitle: $title\nbody:$body");
  }).onError((error, stackTrace){
    print("showFlutterNotification error");
  });
}

getPlatformSpecifics() {
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      "default",
      "default",
      importance: Importance.max,
      priority: Priority.high,
      color: Colors.white,
      icon: "launcher_icon");
  var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  return platformChannelSpecifics;
}

/**
 * 기본 실행 시 호출 되어야하는 기본 값 함수
 */
Future<void> mainInit() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(Firebase.apps.isEmpty){
    await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
    );
    }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await initFCM();

  await AppDAO.init();
  await fcmTopicInits();
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("fcm Token : ${fcmToken}");
  if(fcmToken != null){
    PostFCMTokenService(token:fcmToken).start().then((result){
      if(result is PushResponse){
        print("fcm updated ${result.id}");
      }
    });
  }

  FirebaseMessaging.instance.onTokenRefresh
      .listen((fcmToken) {
    PostFCMTokenService(token:fcmToken).start().then((result){
        if(result is PushResponse){
          print("fcm updated  ${result.id}}");
        }
      });
    }).onError((err) {
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

Future<void> fcmTopicInits() async{
  // List<AndroidNotificationChannel> channels = await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
  //     AndroidFlutterLocalNotificationsPlugin>()?.getNotificationChannels()??[];
  // /// 채널이 있는 경우 채널로 구독 초기 설정
  // for(var channel in channels){
  //   if(channel.id == "default"){
  //     log("default channel exist");
  //     await FirebaseMessaging.instance.subscribeToTopic("default").then((value){
  //       log("subscribe topic default");
  //     });
  //   }else if(channel.id == "afternoon"){
  //     log("afternoon channel exist");
  //     await FirebaseMessaging.instance.subscribeToTopic("afternoon");
  //   }else{
  //     await FirebaseMessaging.instance.unsubscribeFromTopic("default");
  //     await FirebaseMessaging.instance.unsubscribeFromTopic("afternoon");
  //   }
  // }
  /// 채널 이슈가 있는 경우 로컬 데이터로 체크
  bool isOnChannelDefault = await AppDAO.isOnChannelDefault;
  bool isOnChannelAfternoon = await AppDAO.isOnChannelAfternoon;
  if(isOnChannelDefault){
    await FirebaseMessaging.instance.subscribeToTopic("default").then((value){
      log("subscribe topic default");
    });
  }else{
    await FirebaseMessaging.instance.unsubscribeFromTopic("default");
  }

  if(isOnChannelAfternoon){
    await FirebaseMessaging.instance.subscribeToTopic("afternoon");
  }else{
    await FirebaseMessaging.instance.unsubscribeFromTopic("afternoon");
  }
}

initFCM() async {
  FirebaseMessaging.instance.subscribeToTopic("all");
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  if(Platform.isAndroid){
    var channelDefault = const AndroidNotificationChannel(
      'default', // id
      '수면정보알림', // title
      description:
      '전체알림을 수신받습니다', // description
      importance: Importance.max,
    );
    var channelAfternoon = const AndroidNotificationChannel(
      'afternoon', // id
      '수면 컨디션 작성 알림', // title
      description:
      '수면 컨디션 작성 알림을 수신받습니다', // description
      importance: Importance.max,
    );

    if(await AppDAO.isOnChannelDefault){
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channelDefault);
    }
    if(await AppDAO.isOnChannelAfternoon){
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channelAfternoon);
    }
  }else{

    if(await AppDAO.isOnChannelDefault){
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true,);
    }
    if(await AppDAO.isOnChannelAfternoon){
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true,);
    }
  }

  log("isOnChannelDefault: ${await AppDAO.isOnChannelDefault}");
  log("isOnChannelAfternoon: ${await AppDAO.isOnChannelAfternoon}");
  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    Map<String, dynamic> data = message.data;
    showFlutterNotification(message);
  });
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
  initState() {
    initFCMListener();
    super.initState();
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

  void initFCMListener() {
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

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      Navigator.pushNamed(context, Routes.splash);
    });
  }
}