import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sleepaid/app_routes.dart';
import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/main.dart';
import 'package:sleepaid/provider/bluetooth_provider.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_strings.dart';
import 'package:sleepaid/util/app_themes.dart';
import 'package:sleepaid/util/functions.dart';
import 'package:sleepaid/util/statics.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/custom_switch_button.dart';
import 'package:provider/provider.dart';

import '../provider/main_provider.dart';


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
    print("load data");
    channels = await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.getNotificationChannels()??[];

    if(channels.isNotEmpty){
      isOnChannelDefault = false;
      isOnChannelAfternoon = false;
      channels.forEach((channel) {
        print("channel: ${channel.name}");
        if(channel.id == "default"){
          isOnChannelDefault = true;
        }
        if(channel.id == "afternoon"){
          isOnChannelAfternoon = true;
        }
      });
    }
    setState(() {isLoading = false;});
  }

  /// 채널의 상태를 토글처리
  Future<void> toggleChannelState(String channelId) async{
    if(channelId == "default"){
      if(isOnChannelDefault){
        await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()?.deleteNotificationChannel("default");
        isOnChannelDefault = false;
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
      }
    }else if(channelId == "afternoon"){
      if(isOnChannelAfternoon){
        await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()?.deleteNotificationChannel("afternoon");
        isOnChannelAfternoon = false;
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
      }
    }
    setState(() {});
  }
}