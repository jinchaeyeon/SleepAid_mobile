import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/src/provider.dart';
import 'package:sleepaid/app_routes.dart';
import 'package:sleepaid/data/auth_data.dart';
import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/provider/auth_provider.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/util/functions.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/sign_in_up_button.dart';


class LoginListPage extends BaseStatefulWidget {
  static const ROUTE = "/Login";

  const LoginListPage({Key? key}) : super(key: key);

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<LoginListPage>
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
            child: WillPopScope(
              onWillPop:() async {
                await completedExit(context);
                return true;
              },
              child: mainContent())
        )
    );
  }

  Widget snsBottomSheet() {
    return Container(
      padding: const EdgeInsets.only(top: 34, bottom: 62),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Column(
              children: [
                Text(
                  'SNS 계정 선택',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textBlack,
                    fontSize: 16,
                    // fontFamily: Util.notoSans,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        await _actionSNSLogin(AuthData.userTypes["naver"]);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              width: 50,
                              height: 50,
                              child: Image.asset(AppImages.naver, fit: BoxFit.contain),
                            ),
                            const Text(
                              'Naver',
                              style: TextStyle(
                                color: AppColors.subTextBlack,
                                fontSize: 14,
                                // fontFamily: Util.roboto,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                      )
                    ),
                    InkWell(
                      onTap: () async {
                        await _actionSNSLogin(AuthData.userTypes["facebook"]);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              width: 50,
                              height: 50,
                              child: Image.asset(AppImages.facebook, fit: BoxFit.contain),
                            ),
                            const Text(
                              'Facebook',
                              style: TextStyle(
                                color: AppColors.subTextBlack,
                                fontSize: 14,
                                // fontFamily: Util.roboto,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        )
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        await _actionSNSLogin(AuthData.userTypes["google"]);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              width: 50,
                              height: 50,
                              child: Image.asset(AppImages.google, fit: BoxFit.contain),
                            ),
                            const Text(
                              'Google',
                              style: TextStyle(
                                color: AppColors.subTextBlack,
                                fontSize: 14,
                                // fontFamily: Util.roboto,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        )
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget mainContent() {
    return Container(
        width: double.maxFinite,
        height: double.maxFinite,
        alignment: Alignment.center,
        child: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppImages.IMAGE_BG_LOGIN),
                  fit: BoxFit.cover,
                )
            ),
            child: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: Center(
                        child: Text(
                          AppDAO.isDarkMode ? "Sleep Aid" : "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, Routes.emailLogin);
                          },
                          child: SignInUpButton(
                            buttonText: '기존 아이디로 로그인',
                            textColor: Theme.of(context).highlightColor,
                            borderColor: Colors.white,
                            innerColor: Colors.white,
                            isGradient: false,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.black.withOpacity(0.3),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                              builder: (context) => SingleChildScrollView(
                                child: Container(
                                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                  child: snsBottomSheet(),
                                ),
                              ),
                            );
                          },
                          child: SignInUpButton(
                            buttonText: 'SNS 계정으로 로그인',
                            textColor: Colors.white,
                            borderColor: Colors.white,
                            innerColor: Colors.transparent,
                            isGradient: false,
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () {
                            AppDAO.authData.temporarySNSType = AuthData.userTypes["email"]!;
                            Navigator.pushNamed(context, Routes.licenseKey);
                          },
                          child: const Text(
                            '회원가입',
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
        )
    );
  }

  /// SNS 로그인 요청 처리
  Future<void> _actionSNSLogin(String? userType) async{
    Navigator.pop(context);
    await context.read<AuthProvider>().checkSNSLogin(context, userType);
  }
}