import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sleepaid/app_routes.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/util/commons.dart';
import 'package:sleepaid/widget/sign_in_up_button.dart';
import 'package:sleepaid/widget/sign_in_up_input.dart';
import 'package:sleepaid/widget/sign_in_up_title.dart';

class ChangePasswordPage extends StatefulWidget {
  static const ROUTE = "/ChangePassword";
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChangePasswordPage();
}

class _ChangePasswordPage extends State<ChangePasswordPage> {
  TextEditingController _emailController = TextEditingController();
  FocusNode _emailNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: "");
  }

  @override
  void dispose() {
    super.dispose();
    _emailController?.dispose();
    _emailNode?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        fieldChangeUnFocus(context);
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: ScrollConfiguration(
              behavior: NoBehavior(),
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        homeContent(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget appBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(123),
      child: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(''),
        automaticallyImplyLeading: false,
        // brightness: Brightness.light,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        flexibleSpace: Container(
          child: Column(
            children: [
              Container(
                height: 123,
                padding: EdgeInsets.only(top: 77, bottom: 28, left: 36),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius:
                  BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 12,
                        height: 21,
                        child: Image.asset(AppImages.back, color: Theme.of(context).accentColor, fit: BoxFit.contain),
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

  Widget homeContent() {
    return Container(
      height: 123,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SignInUpTitle(title: '아이디를 입력해 주세요.'),
                SizedBox(height: 80),
                Container(
                  margin: EdgeInsets.only(bottom: 30),
                  child: SignInUpInput(
                    controller: _emailController,
                    firstNode: _emailNode,
                    textInputAction: TextInputAction.done,
                    textInputType: TextInputType.emailAddress,
                    hintText: '이메일 아이디',
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_emailController.text.isEmpty) {
                Fluttertoast.showToast(msg:"이메일 아이디를 입력해 주세요.");
              } else {
                Navigator.pushNamed(context, Routes.changePassword);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 150),
              child: SignInUpButton(
                buttonText: '비밀번호 찾기',
                textColor: Colors.white,
                borderColor: Colors.transparent,
                gradientFirst: AppColors.buttonStart,
                gradientSecond: AppColors.buttonEnd,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
