import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sleepaid/provider/data_provider.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/util/functions.dart';
import 'package:sleepaid/widget/sign_in_up_input.dart';

import '../../app_routes.dart';

class FindPasswordPage extends StatefulWidget {
  static const ROUTE = "FindPassword";
  const FindPasswordPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FindPasswordPage();
}

class _FindPasswordPage extends State<FindPasswordPage> {

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
  Widget build(BuildContext context){

    return Scaffold(
        extendBody: true,
        body: SafeArea(
            child: getBaseWillScope(context, mainContent())
        )
    );
  }

  Widget mainContent(){
    return Stack(
        children: [
          Positioned(
              left:0, right: 0, top:0, bottom: 0,
              child: SizedBox(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  child: SingleChildScrollView(
                      child: Container(
                          width: double.maxFinite,
                          height: 600,
                          alignment: Alignment.topCenter,
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                margin:const EdgeInsets.only(left:10, top: 10),
                                child: GestureDetector(
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
                              ),
                              Container(
                                  margin: const EdgeInsets.only(left: 30, top:10),
                                  alignment: Alignment.centerLeft,
                                  child: const Text("아이디를 입력해주세요.", style: TextStyle(fontSize: 20, color: AppColors.textBlack, fontWeight: FontWeight.bold))
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30, top:80),
                                child: SignInUpInput(
                                  controller: _emailController,
                                  firstNode: _emailNode,
                                  textInputAction: TextInputAction.done,
                                  textInputType: TextInputType.emailAddress,
                                  hintText: '이메일 아이디',
                                  isEmail: true,
                                ),
                              ),
                            ],
                          )
                      )
                  )
              )
          ),
          Positioned(
              bottom: 0, left: 0, right: 0,
              child: SizedBox(
                height: 70.0,
                child: Container(
                  width: double.maxFinite,
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                  ),
                  child: OutlinedButton(
                    onPressed: () async {
                      if(_emailController.text.isEmpty) {
                        Fluttertoast.showToast(msg:"이메일을 입력해주세요.");
                        return ;
                      }
                      bool isValidEmail = checkEmailPattern(_emailController.text);
                      if(!isValidEmail){
                        Fluttertoast.showToast(msg:"이메일 형식이 아닙니다.");
                        return ;
                      }
                      bool isSendingEmail = await sendResetEmail(_emailController.text);
                      if(isSendingEmail){
                        /// 비밀번호 변경 메일 알림
                        Fluttertoast.showToast(msg: "${_emailController.text}로\n비밀번호 변경 메일이 발송되었습니다");
                      }else{
                        Fluttertoast.showToast(msg: "연결오류. 다시 시도해주세요.");
                      }
                    },
                    style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.buttonBlue,
                        shape: const RoundedRectangleBorder(

                        )
                    ),
                    // shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: const Text(
                      '비밀번호 찾기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                ),
              )
          )

        ]
    );
  }

  ///로직 변경으로 사용 X
  Future<void> showSignupBottomSheetDialog(BuildContext context)  async{
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return  Wrap(
          children: [
            Column(
              children: [
                Container(
                    height: 100,
                    width: double.maxFinite,
                    alignment: Alignment.center,
                    child: Text("등록되지 않은 이메일입니다.\n회원가입 페이지로 이동하시겠습니까?",
                        textAlign:TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                            color: AppColors.textBlack))
                ),
                Container(
                  width: double.maxFinite,
                  height: 1,
                  color:AppColors.borderGrey,
                ),
                Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap:(){
                            Navigator.pop(context);
                          },
                          child:Container(
                              alignment: Alignment.center,
                              child: Text("취소",style:TextStyle(fontSize:15, color: AppColors.textBlack, fontWeight: FontWeight.bold))
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 80,
                        color:AppColors.borderGrey,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap:(){
                            Navigator.pop(context);
                            Navigator.pushNamedAndRemoveUntil(context, Routes.licenseKey, (route) => false);
                          },
                          child:Container(
                              alignment: Alignment.center,
                              child: Text("확인",style:TextStyle(fontSize:15, color: AppColors.textBlack, fontWeight: FontWeight.bold))
                          ),
                        ),
                      ),
                    ]
                )
              ],
            ),
          ]
        );
      },
    );
  }

  Future<bool> sendResetEmail(String email) async{
    await context.read<DataProvider>().setLoading(true);
    bool isSuccess = !await context.read<DataProvider>().sendResetPasswordLinkToEmail(email);
    await context.read<DataProvider>().setLoading(false);
    return isSuccess;
  }
}