import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sleepaid/app_routes.dart';
import 'package:sleepaid/provider/auth_provider.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_strings.dart';
import 'package:sleepaid/util/app_styles.dart';
import 'package:sleepaid/util/functions.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:provider/provider.dart';


/**
 * 앱 시작시 사용되는 SPLASH PAGE
 * 기본 데이터를 호출하여 로컬 상태 저장
 * 1. 인증 정보
 * 2. 기기 연결 상태
 * 3. 서버에서 갱신 된 데이터
 * 4. 신규 알림
 */
class SplashPage extends BaseStatefulWidget {
  static const ROUTE = "splash";

  const SplashPage({Key? key}) : super(key: key);

  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<SplashPage>
    with SingleTickerProviderStateMixin{

  @override
  void initState() {
    super.initState();
    checkState();
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
                    const Expanded(flex: 2, child: SizedBox.shrink()),
                  ],
                )
            )
        )
    );
  }

  Future<void> checkState() async{
    await checkAppVersion();
  }
  Future<void> checkLoginState() async{
    Navigator.pushReplacementNamed(context, Routes.home);
    // Future.delayed(const Duration(milliseconds: 1000), () async {
    //   await checkNetworkState().then((connected){
    //     if(connected){
    //       if(context.read<AuthProvider>().isLoginState()){
    //         Navigator.pushReplacementNamed(context, Routes.home);
    //       }else{
    //         Navigator.pushReplacementNamed(context, Routes.login);
    //       }
    //     }else{
    //       // showToast();
    //       Navigator.of(context).pop(true);
    //     }
    //   });
    // });
  }

  Future<void> checkAppVersion() async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
  }
}