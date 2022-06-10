import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sleepaid/app_routes.dart';
import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/main.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/util/app_strings.dart';
import 'package:sleepaid/util/app_themes.dart';
import 'package:sleepaid/util/functions.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/custom_switch_button.dart';


class MenuPage extends BaseStatefulWidget {
  static const ROUTE = "Menu";

  const MenuPage({Key? key}) : super(key: key);

  @override
  MenuState createState() => MenuState();
}

class MenuState extends State<MenuPage>
    with SingleTickerProviderStateMixin{
  Map<String, Function> listeners = {
    AppStrings.menu_bluetooth_connect: (){

    },
    AppStrings.menu_version_info: (){

    },
    AppStrings.menu_push_notificatin: (){

    },

    AppStrings.menu_dark_mode: (context) async {
      if (AppDAO.isDarkMode) {
        SleepAIDApp.of(context)?.changeTheme(AppThemes.lightTheme);
        await AppDAO.setDarkMode(false);
      } else{
        SleepAIDApp.of(context)?.changeTheme(AppThemes.darkTheme);
        await AppDAO.setDarkMode(true);
      }
    },  
    AppStrings.menu_logout: (context) async {
      await AppDAO.clearAllData();
      Navigator.pushReplacementNamed(context, Routes.login);
    },
  };

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: appBar(),
        extendBody: true,
        body: SafeArea(
            child: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    ...getButtons(),
                  ],
                )
            )
        )
    );
  }


  List<Widget> getButtons() {
    List<Widget> buttons = [];
    for (var title in AppStrings.menuStrings) {
      Widget subWidget = const SizedBox.shrink();
      if(title == AppStrings.menu_bluetooth_connect){
        subWidget = Text("연결된 블루투스명");
      }else if(title == AppStrings.menu_version_info){
        subWidget = Text(AppDAO.appVersion);
      }else if(title == AppStrings.menu_dark_mode){
        subWidget = CustomSwitchButton(
          value: AppDAO.isDarkMode,
          onChanged: (value) async {
            await listeners[title]!(context);
          },
        );
      }
      Widget button = InkWell(
        onTap:() async {
          await listeners[title]!(context);
        },
        child: Container(
            height: 50,
            padding: const EdgeInsets.only(left: 20, right: 20),
            width: double.maxFinite,
            child: Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).textSelectionTheme.selectionColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Expanded(child: SizedBox.shrink()),
                  subWidget
                ]
            )
        )
      );
      buttons.add(button);
    }

    return buttons;
  }

  onClickListener(String title) {
    if(title == AppStrings.menu_bluetooth_connect){
      Navigator.pushNamed(context,Routes.bluetoothConnect);
    }
  }

  PreferredSize appBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(123),
      child: AppBar(
        toolbarHeight: 116,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '설정',
          style: Theme.of(context).primaryTextTheme.headline5,
        ),
        automaticallyImplyLeading: false,
        // brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 123,
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 10,
                  right: 36,
                ),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {

                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        alignment: Alignment.center,
                        child: Image.asset(
                          AppImages.back, color: Theme.of(context).primaryIconTheme.color,
                          fit: BoxFit.contain, width: 12, height: 21,

                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  
}