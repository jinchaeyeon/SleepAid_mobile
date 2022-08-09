import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sleepaid/app_routes.dart';
import 'package:sleepaid/data/auth_data.dart';
import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/network/base_response.dart';
import 'package:sleepaid/provider/auth_provider.dart';
import 'package:sleepaid/provider/data_provider.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/util/functions.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/sign_in_up_button.dart';
import 'package:sleepaid/widget/sign_in_up_input.dart';
import 'package:sleepaid/widget/sign_in_up_title.dart';
import 'package:provider/provider.dart';

class EmailSignUpPage extends BaseStatefulWidget {
  static const ROUTE = "/EmailSignUp";
  const EmailSignUpPage({Key? key}) : super(key: key);

  @override
  EmailSignUpState createState() => EmailSignUpState();
}

class EmailSignUpState extends State<EmailSignUpPage>
    with SingleTickerProviderStateMixin{

  TextEditingController _emailController = TextEditingController(
    text:AppDAO.debugData.inputTestInputData?AppDAO.debugData.signupEmail:""
  );
  FocusNode _emailNode = FocusNode();
  TextEditingController _passwordController = TextEditingController(
      text:AppDAO.debugData.inputTestInputData?AppDAO.debugData.signupPW:""
  );
  FocusNode _passwordNode = FocusNode();
  TextEditingController _checkPasswordController = TextEditingController(
      text:AppDAO.debugData.inputTestInputData?AppDAO.debugData.signupPW:""
  );
  FocusNode _checkPasswordNode = FocusNode();
  bool isShowingPasswordNodes = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController?.dispose();
    _emailNode?.dispose();
    _passwordController?.dispose();
    _passwordNode?.dispose();
    _checkPasswordController?.dispose();
    _checkPasswordNode?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(AppDAO.authData.temporarySNSType != AuthData.userTypes["email"]){
      /// SNS로그인은 비밀번호 안보이도록 처리
      isShowingPasswordNodes = false;
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(33.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.0,
          backgroundColor: Colors.white,
        ),
      ),
      body: getBaseWillScope(
        context, mainContent()
      )
    );
  }

  Widget mainContent(){
    return Container(
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
          SignInUpTitle(title: '회원 정보를 입력해 주세요.'),
          const SizedBox(height: 80),
          Container(
            padding: const EdgeInsets.only(left: 36.0, right: 36.0),
            margin: const EdgeInsets.only(bottom: 30),
            child: SignInUpInput(
              controller: _emailController,
              firstNode: _emailNode,
              secondNode: _passwordNode,
              textInputAction: TextInputAction.next,
              textInputType: TextInputType.emailAddress,
              hintText: '이메일 아이디',
            ),
          ),
          isShowingPasswordNodes?Container(
            padding: const EdgeInsets.only(left: 36.0, right: 36.0),
            margin: const EdgeInsets.only(bottom: 30),
            child: SignInUpInput(
              controller: _passwordController,
              firstNode: _passwordNode,
              secondNode: _checkPasswordNode,
              textInputAction: TextInputAction.next,
              textInputType: TextInputType.text,
              hintText: '비밀번호',
              isPassword: true,
            ),
          ):Container(),
          isShowingPasswordNodes?Container(
              padding: const EdgeInsets.only(left: 36.0, right: 36.0),
              margin: const EdgeInsets.only(bottom: 30),
              child: SignInUpInput(
                controller: _checkPasswordController,
                firstNode: _checkPasswordNode,
                // secondNode: _passwordNode,
                textInputAction: TextInputAction.done,
                textInputType: TextInputType.text,
                hintText: '비밀번호 확인',
                isPassword: true,
              )
          ):Container(),
          Container(
            padding: const EdgeInsets.only(left: 36.0, right: 36.0),
            child: GestureDetector(
              onTap: () async {
                if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _checkPasswordController.text.isEmpty) {
                  Fluttertoast.showToast(msg:"빈 칸을 모두 입력해 주세요.");
                  return;
                }
                if (!checkEmailPattern()) {
                  Fluttertoast.showToast(msg:"이메일 형식을 확인해주세요.");
                  return;
                }
                if (_passwordController.text != _checkPasswordController.text) {
                  Fluttertoast.showToast(msg:"비밀번호가 일치하지 않습니다.");
                  return;
                }
                if (!checkPasswordPattern()) {
                  Fluttertoast.showToast(msg:"비밀번호는 8자 이상 영문, 숫자를 포함해서 입력해 주세요.");
                  return;
                }
                await signup();
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 150),
                child: SignInUpButton(
                  buttonText: '회원가입',
                  textColor: Colors.white,
                  borderColor: Colors.transparent,
                  gradientFirst: AppColors.buttonStart,
                  gradientSecond: AppColors.buttonEnd,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> signup() async {
    ///회원가입 서버와 통신 이후에, 이슈 있으면 재시도 메세지, 이슈 없으면 메인화면
    String email = _emailController.text;
    String password = _passwordController.text;
    if(AppDAO.authData.temporarySNSType != AuthData.userTypes["email"]){
      password = AppDAO.authData.temporarySNSPW;
    }
    context.read<DataProvider>().setLoading(true);
    int response = await context.read<AuthProvider>().signup(email, password);
    context.read<DataProvider>().setLoading(false);
    if(!AppDAO.debugData.passCheckingSignupAPI){
      if(response == BaseResponse.STATE_UNCORRECT){
        return;
      }
    }
    /// 데이터로 바로 로그인하지않고, 로그인 페이지로 이동
    // Navigator.pushReplacementNamed(context, Routes.loginList);
    Fluttertoast.showToast(msg: "$email 가입완료");
    Navigator.pushNamedAndRemoveUntil(context, Routes.loginList, (route) => false);
  }

  static const String validEmail = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  bool checkEmailPattern() {
    RegExp validEmailStr = RegExp(validEmail);
    String email = _emailController.text;
    if (email.trim().isEmpty || !validEmailStr.hasMatch(email)) {
      return false;
    } else if (email.isEmpty) {
      return false;
    }
    return true;
  }

  static const String validPassword = r'^(?=.*?[a-zA-Z])(?=.*?[0-9]).{8,}$';
  bool checkPasswordPattern() {
    RegExp validPasswordStr = RegExp(validPassword);
    String password = _passwordController.text;
    if (password.trim().length < 7 || ((!validPasswordStr.hasMatch((password))))) {
      return false;
    } else if (password.isEmpty) {
      return false;
    }
    return true;
  }

}