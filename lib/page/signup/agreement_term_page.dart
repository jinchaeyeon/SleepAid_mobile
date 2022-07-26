import 'package:flutter/material.dart';
import 'package:sleepaid/app_routes.dart';
import 'package:sleepaid/data/auth_data.dart';
import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/util/app_strings.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/sign_in_up_title.dart';

class AgreementTermPage extends BaseStatefulWidget {
  const AgreementTermPage({Key? key}) : super(key: key);

  static const ROUTE = "/AgreementTerm";

  @override
  State<StatefulWidget> createState() => _AgreementTermPage();
}

class _AgreementTermPage extends State<AgreementTermPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(33.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.0,
          backgroundColor: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Row(
                    children: [
                      IconButton(
                          icon: Image.asset(AppImages.back),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 36.0, right: 36.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(
                        height: 29.0,
                      ),
                      SignInUpTitle(title: '개인정보 수집 및 이용 약관을 확인해주세요.'),
                      const SizedBox(height: 56),
                      InkWell(
                        onTap: () {
                          showAgreementTermFullText();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 9),
                              width: 11,
                              height: 12,
                              child: Image.asset(
                                AppImages.triangle,
                                fit: BoxFit.contain,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            Text(
                              '개인정보 수집 및 이용',
                              style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: 14,
                                // fontFamily: Util.notoSans,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        '위의 목적으로 개인정보를 수집 및 이용하며, 회원의 개인정보를 안전하게 취급하는데 최선을 다합니다.',
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontSize: 14,
                          // fontFamily: Util.notoSans,
                          fontWeight: FontWeight.w400,
                        ),
                      )

                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 24.0),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 36.0, right: 36.0),
                  child: SizedBox(
                    height: 55.0,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      child: OutlinedButton(
                        onPressed: () async {
                          next();
                        },
                        style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.buttonBlue,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30))
                            )
                        ),
                        // shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                        child: const Text(
                          '동의하고 다음으로',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget appBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(123),
      child: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(''),
        automaticallyImplyLeading: false,
        // brightness: Brightness.light,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        flexibleSpace: Container(
          // margin: EdgeInsets.only(top: Util.statusBarHeight),
          child: Column(
            children: [
              Container(
                height: 123,
                padding: const EdgeInsets.only(top: 77, bottom: 28, left: 36),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius:
                      const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: SizedBox(
                        width: 12,
                        height: 21,
                        child: Image.asset(AppImages.back, color: Theme.of(context).colorScheme.secondary, fit: BoxFit.contain),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void showAgreementTermFullText() {
    showDialog(context: context, builder: (context){
      return Scaffold(
        body: Container(
            width: double.maxFinite,
            height: double.maxFinite,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  height: 123,
                  padding: const EdgeInsets.only(top: 0, left: 36),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius:
                    const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: SizedBox(
                          width: 12,
                          height: 21,
                          child: Image.asset(AppImages.back, color: Colors.black, fit: BoxFit.contain),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child:Container(
                      padding: EdgeInsets.all(20),
                      child: Text(AppStrings.signup_agreement, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),)
                    )
                  ),
                )
              ],
            )
        )
      );
    });
  }

  /// 다음버튼액션
  /// 만약에 SNS 가입자라면 바로 메인으로
  /// SNS 가입자가 아니라면 email 가입 페이지로 이동
  Future<void> next() async {
    if(await AppDAO.authData.userType() == null){
      //이메일 회원가입 시작
      Navigator.pushReplacementNamed(
          context, Routes.signupWithEmail);
      return;
    }else{
      //todo 동의처리필요
      //바로 메인화면 이동(SNS유저)
      Navigator.pushReplacementNamed(context, Routes.home);
      return;
    }
  }
}
