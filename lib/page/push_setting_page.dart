import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
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


class PushSettingPage extends BaseStatefulWidget {
  static const ROUTE = "/PushSetting";

  const PushSettingPage({Key? key}) : super(key: key);

  @override
  PushSettingState createState() => PushSettingState();
}

class PushSettingState extends State<PushSettingPage>
    with SingleTickerProviderStateMixin{

  Map<String, Function> listeners  = {};
  bool isDarkMode = false;
  @override
  void initState() {
    isDarkMode = AppDAO.isDarkMode;
    super.initState();
  }

  @override
  Widget build(BuildContext context){

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
                                value: isDarkMode,
                                onChanged: (value) async {
                                  // await listeners[title]!(context);
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
                                value: isDarkMode,
                                onChanged: (value) async {
                                  // await listeners[title]!(context);
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
}