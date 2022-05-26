import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sleepaid/app_routes.dart';
import 'package:sleepaid/provider/auth_provider.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_strings.dart';
import 'package:sleepaid/util/app_styles.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:provider/provider.dart';


class LoginPage extends BaseStatefulWidget {
  static const ROUTE = "Login";

  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<LoginPage>
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
                color: AppColors.baseGreen,
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
                    Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.only(bottom:30),
                          child: Column(
                            children: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.black, //<-- SEE HERE
                                ),
                                onPressed: () {},
                                child: const Text(
                                  'Outlined Button',
                                  style: TextStyle(fontSize: 40),
                                ),
                              ),
                            ],
                          )
                        )
                    ),
                  ],
                )
            )
        )
    );
  }


}