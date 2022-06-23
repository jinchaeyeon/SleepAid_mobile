import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sleepaid/app_routes.dart';
import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/provider/data_provider.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/util/functions.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/custom_checkbox.dart';
import 'package:sleepaid/widget/sign_in_up_input.dart';
import 'package:provider/provider.dart';

class EmailLoginPage extends BaseStatefulWidget {
  static const ROUTE = "EmailLogin";

  const EmailLoginPage({Key? key}) : super(key: key);

  @override
  EmailLoginState createState() => EmailLoginState();
}

class EmailLoginState extends State<EmailLoginPage>
    with SingleTickerProviderStateMixin{

  final TextEditingController _emailController = TextEditingController(
    text:AppDAO.debugData.inputTestInputData?AppDAO.debugData.signupEmail: ""
  );
  final FocusNode _emailNode = FocusNode();
  final TextEditingController _passwordController = TextEditingController(
      text:AppDAO.debugData.inputTestInputData?AppDAO.debugData.signupPW: ""
  );
  final FocusNode _passwordNode = FocusNode();
  bool isAutoLogin = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        extendBody: true,
        body: SafeArea(
            child: getBaseWillScope(context, getHomeCotent())
        )
    );
  }

  Widget getHomeCotent() {
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
                                  child: Text("로그인 해주세요.", style: TextStyle(fontSize: 20, color: AppColors.textBlack, fontWeight: FontWeight.bold))
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30, top:80),
                                child: SignInUpInput(
                                  controller: _emailController,
                                  firstNode: _emailNode,
                                  secondNode: _passwordNode,
                                  textInputAction: TextInputAction.next,
                                  textInputType: TextInputType.emailAddress,
                                  hintText: '이메일 아이디',
                                  isEmail: true,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30, top:0),
                                child: SignInUpInput(
                                  controller: _passwordController,
                                  firstNode: _passwordNode,
                                  // secondNode: _passwordNode,
                                  textInputAction: TextInputAction.done,
                                  textInputType: TextInputType.text,
                                  hintText: '비밀번호',
                                  isPassword: true,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30, top:10),
                                width: double.maxFinite,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomCheckbox(
                                      isChecked: isAutoLogin,
                                      onChange: (bool value) {
                                        isAutoLogin = value;
                                        setState(() {});
                                      },
                                      labelText: '자동 로그인',
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(context, Routes.findPassword);
                                      },
                                      child: Container(
                                        alignment: Alignment.centerRight,
                                        width:100,
                                        height: 50,
                                        child: Text(
                                          '비밀번호 찾기',
                                          style: TextStyle(
                                            color: Theme.of(context).hintColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )
                                      ),
                                    ),
                                  ],
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
                      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                        Fluttertoast.showToast(msg:"이메일과 비밀번호를 입력해주세요.");
                      } else {
                        await login(_emailController.text, _passwordController.text);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.buttonBlue,
                        shape: const RoundedRectangleBorder(
                        )
                    ),
                    // shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: const Text(
                      '로그인',
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

  Future<void> login(String id, String pw) async{
    FocusManager.instance.primaryFocus?.unfocus();
    context.read<DataProvider>().setLoading(true);
    bool isSuccess = await context.read<DataProvider>().login(id, pw, isAutoLogin: isAutoLogin);
    context.read<DataProvider>().setLoading(false);
    if(isSuccess){
      Navigator.pushReplacementNamed(context, Routes.home);
    }
  }
}