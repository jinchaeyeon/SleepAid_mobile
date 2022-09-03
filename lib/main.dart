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

late AndroidNotificationChannel channelDefault;
late AndroidNotificationChannel channelAfternoon;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  showFlutterNotification(message);
  print('Handling a background message ${message.messageId}');
}

void showFlutterNotification(RemoteMessage message) async{
  print("showFlutterNotification");
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
  bool isOnChannelDefault = false;
  bool isOnChannelAfternoon = false;
  bool isShowNotification = false;
  List<AndroidNotificationChannel> channels = await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()?.getNotificationChannels()??[];
  channels.forEach((channel) {
    if(channel.id == "default"){
      isOnChannelDefault = true;
    }
    if(channel.id == "afternoon"){
      isOnChannelAfternoon = true;
    }
  });

  if(isOnChannelAfternoon && title.contains("수면컨디션작성알림")){
    isShowNotification = true;
  }
  if(isOnChannelDefault && title.contains("수면정보알림")){
    isShowNotification = true;
  }
  if(!isShowNotification){
    return;
  }

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

  await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      platformChannelSpecifics,
      // payload: json.encode(pushNotification));
  );
}

/**
 * 기본 실행 시 호출 되어야하는 기본 값 함수
 */
Future<void> mainInit() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initFCM();

  await AppDAO.init();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("fcm Token : ${fcmToken}");
  if(fcmToken != null){
    PostFCMTokenService(token:fcmToken).start().then((result){
      if(result is PushResponse){
        print("fcm updated }");
      }
    });
  }

  FirebaseMessaging.instance.onTokenRefresh
      .listen((fcmToken) {
    PostFCMTokenService(token:fcmToken).start().then((result){
        if(result is PushResponse){
          print("fcm updated }");
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

initFCM() async {
  FirebaseMessaging.instance.subscribeToTopic("all");
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  channelDefault = const AndroidNotificationChannel(
    'default', // id
    '수면정보알림', // title
    description:
    '전체알림을 수신받습니다', // description
    importance: Importance.max,
  );
  channelAfternoon = const AndroidNotificationChannel(
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