import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_strings.dart';
import 'package:sleepaid/util/app_styles.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';


class HomePage extends BaseStatefulWidget {
  static const ROUTE = "Home";

  const HomePage({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<HomePage>
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
                  flex: 1,
                  child: Center(
                    child: Text(
                        AppStrings.app_logo,
                        style: AppStyles.textStyle(
                          size: AppDimens.textSizeLogo,
                          color: AppColors.white
                        ))
                  )
                ),
                const Expanded(flex: 2, child: SizedBox.shrink()),
              ],
            )
          )
        )
    );
  }

}