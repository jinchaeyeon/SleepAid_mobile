import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sleepaid/app_routes.dart';
import 'package:sleepaid/provider/auth_provider.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/util/app_strings.dart';
import 'package:sleepaid/util/app_styles.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:provider/provider.dart';


class MenuPage extends BaseStatefulWidget {
  static const ROUTE = "Menu";

  const MenuPage({Key? key}) : super(key: key);

  @override
  MenuState createState() => MenuState();
}

class MenuState extends State<MenuPage>
    with SingleTickerProviderStateMixin{

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
        extendBody: true,
        body: SafeArea(
            child: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Expanded(flex: 1, child: SizedBox.shrink()),
                    Expanded(
                        flex: 3,
                        child: Container(
                            height: 50,
                            width: double.maxFinite,
                            child: Row(
                              children: [
                                InkWell(
                                    onTap:(){
                                      Navigator.pop(context);
                                    },
                                    child: Image.asset(AppImages.ic_menu, width: 50, height: 50)
                                ),
                                Text(AppStrings.app_logo, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Container(
                                  width: 50, height: 50,
                                  child: SizedBox.shrink()
                                )
                              ],
                            )
                        )
                    ),
                    Expanded(
                      flex: 7,
                      child: Container(
                          child: Column(
                              children: []..addAll(getButtons())
                          )
                      ),
                    ),
                  ],
                )
            )
        )
    );
  }

  List<Widget> getButtons() {
    List<Widget> buttons = [];
    AppStrings.menuStrings.forEach((title) {
      Widget subWidget = const SizedBox.shrink();
      if(title == AppStrings.menu_bluetooth_connect){
        subWidget = Text("연결된 블루투스명");
      }else if(title == AppStrings.menu_version_info){
        // subWidget = Text("${packageInfo.version;}");
      }
      Widget button = InkWell(
        onTap:(){

        },
        child: InkWell(
          onTap: () => onClickListener(title),
          child: Container(
              height: 50,
              width: double.maxFinite,
              child: Row(
                  children: [
                    Text(title),
                    const Expanded(child: SizedBox.shrink()),
                    subWidget
                  ]
              )
          )
        )
      );
      buttons.add(button);
    });

    return buttons;
  }

  onClickListener(String title) {
    if(title == AppStrings.menu_bluetooth_connect){
      Navigator.pushNamed(context,Routes.bluetoothConnect);
    }
  }


}