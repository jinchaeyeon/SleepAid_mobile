import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/statics.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/custom_switch_button.dart';

class PushSettingPage extends BaseStatefulWidget {
  static const ROUTE = "/PushSetting";

  const PushSettingPage({Key? key}) : super(key: key);

  @override
  PushSettingState createState() => PushSettingState();
}

class PushSettingState extends State<PushSettingPage>
    with SingleTickerProviderStateMixin{
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  List<AndroidNotificationChannel> channels = [];
  Map<String, Function> listeners  = {};
  bool isLoading = true;
  bool isOnChannelDefault = false;
  bool isOnChannelAfternoon = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    if(isLoading){
      loadData(context);
      return Container();
    }
    return Scaffold(
        appBar: appBar(context,"푸시알림설정", isRound: false,),
        extendBody: false,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
            child: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                    border: Border(top: BorderSide(color:AppColors.borderGrey.withOpacity(0.4), width:1))
                ),
                child: Column(
                  children: [
                    Container(
                        height: 60,
                        decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color:AppColors.borderGrey.withOpacity(0.4), width:1))
                        ),
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        width: double.maxFinite,
                        child: Row(
                            children: [
                              Text(
                                "수면정보 알림 ",
                                style: TextStyle(
                                  color: Theme.of(context).textSelectionTheme.selectionColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Expanded(child: SizedBox.shrink()),
                              CustomSwitchButton(
                                value: isOnChannelDefault,
                                onChanged: (value) async {
                                  await toggleChannelState("default");
                                },
                              )
                            ]
                        )
                    ),
                    Container(
                        height: 60,
                        decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color:AppColors.borderGrey.withOpacity(0.4), width:1))
                        ),
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        width: double.maxFinite,
                        child: Row(
                            children: [
                              Text(
                                "수면 컨디션 작성 알림",
                                style: TextStyle(
                                  color: Theme.of(context).textSelectionTheme.selectionColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Expanded(child: SizedBox.shrink()),
                              CustomSwitchButton(
                                value: isOnChannelAfternoon,
                                onChanged: (value) async {
                                  await toggleChannelState("afternoon");
                                },
                              )
                            ]
                        )
                    )
                  ],
                )
            )
        )
    );
  }

  Future<void> loadData(BuildContext context) async {
    log("loadData start");
    // channels = await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
    //     AndroidFlutterLocalNotificationsPlugin>()?.getNotificationChannels()??[];
    isOnChannelDefault = await AppDAO.isOnChannelDefault;
    isOnChannelAfternoon = await AppDAO.isOnChannelAfternoon;

    log("isOnChannelDefault: ${isOnChannelDefault}");
    log("isOnChannelAfternoon: ${isOnChannelAfternoon}");
    setState(() {isLoading = false;});
  }

  /// 채널의 상태를 토글처리
  Future<void> toggleChannelState(String channelId) async{
    if(channelId == "default"){
      if(isOnChannelDefault){
        await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()?.deleteNotificationChannel("default");
        isOnChannelDefault = false;
        AppDAO.setOnChannelDefault(false);
      }else {
        var channelDefault = const AndroidNotificationChannel(
          'default', // id
          '수면정보알림', // title
          description:
          '전체알림을 수신받습니다', // description
          importance: Importance.max,
        );
        await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channelDefault);
        isOnChannelDefault = true;
        AppDAO.setOnChannelDefault(true);
      }
    }else if(channelId == "afternoon"){
      if(isOnChannelAfternoon){
        await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()?.deleteNotificationChannel("afternoon");
        isOnChannelAfternoon = false;
        AppDAO.setOnChannelAfternoon(false);
      }else {
        var channelAfternoon = const AndroidNotificationChannel(
          'afternoon', // id
          '수면 컨디션 작성 알림', // title
          description:
          '수면 컨디션 작성 알림을 수신받습니다', // description
          importance: Importance.max,
        );
        await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channelAfternoon);
        isOnChannelAfternoon = true;
        AppDAO.setOnChannelAfternoon(true);
      }
    }
    await fcmTopicInits();
    setState(() {});
  }

  Future<void> fcmTopicInits() async{
    List<AndroidNotificationChannel> channels = await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.getNotificationChannels()??[];
    for(var channel in channels){
      if(channel.id == "default"){
        log("default channel exist");
        await FirebaseMessaging.instance.subscribeToTopic("default");
      }else if(channel.id == "afternoon"){
        log("afternoon channel exist");
        await FirebaseMessaging.instance.subscribeToTopic("afternoon");
      }else{
        await FirebaseMessaging.instance.unsubscribeFromTopic("default");
        await FirebaseMessaging.instance.unsubscribeFromTopic("afternoon");
        log("default channel not exist");
        log("afternoon channel not exist");
      }
    }
  }

  updateLocalNotificationChannelState(bool isOnChannelDefault, bool isOnChannelAfternoon) async{
    await AppDAO.setOnChannelDefault(isOnChannelDefault);
    await AppDAO.setOnChannelAfternoon(isOnChannelAfternoon);
    setState(() {});
  }
}