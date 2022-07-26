import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sleepaid/app_routes.dart';
import 'package:sleepaid/data/auth_data.dart';
import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/network/base_response.dart';
import 'package:sleepaid/data/network/license_response.dart';
import 'package:sleepaid/provider/auth_provider.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/util/app_strings.dart';
import 'package:sleepaid/util/app_styles.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:provider/provider.dart';
import 'package:sleepaid/widget/sign_in_up_button.dart';


class LicenseKeyPage extends BaseStatefulWidget {
  static const ROUTE = "/LicenseKey";

  const LicenseKeyPage({Key? key}) : super(key: key);

  @override
  LicenseKeyState createState() => LicenseKeyState();
}

class LicenseKeyState extends State<LicenseKeyPage>
    with SingleTickerProviderStateMixin{

  @override
  void initState() {
    super.initState();

  }

  Future<void> showSimpleAlertDialog(BuildContext context, String text) async{
    // set up the button
    Widget okButton = TextButton(
      child: Text("확인", style: Theme.of(context).textTheme.headline3,),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text(text),
      actions: [
        okButton,
      ],
    );
    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialogIsEmpty(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("확인", style: Theme.of(context).textTheme.headline3,),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: const Text("발급받은 라이선스 키를 입력해 주세요"),
      actions: [
        okButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  final textControllerLicense = TextEditingController(
    text:AppDAO.debugData.inputTestInputData?AppDAO.debugData.licenseKey:""
  );

  Future<bool> checkLicenseKey() async {
    String textLicense = textControllerLicense.text;
    if (textLicense == '') {
      showSimpleAlertDialog(context, "발급받은 라이선스 키를 입력해 주세요");
      return false;
    } else {
    /// SNS 가입자라면 라이센스 인증처리
    /// 가입 시작하는 이메일 가입자라면 이메일 가입 처리 진행 시작
      int response = await context.read<AuthProvider>().checkLicense(textLicense);
      if(response == BaseResponse.STATE_CORRECT){
        AppDAO.authData.temporaryLicenseKey = textLicense;
        //CORRECT
        return true;
      }else if(response == BaseResponse.STATE_UNCORRECT){
        //UNCORRECT
        await showSimpleAlertDialog(context, "라이센스 키를 확인해주세요.");
        return false;
      }else{
        //NO CONNECT
        await showSimpleAlertDialog(context, "네트워크 연결에 실패하였습니다. 다음에 다시 시도해주세요.");
        return false;
      }
    }
  }

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
            child: Container(
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
                        const Text(
                          "라이선스 키를 입력해 주세요.",
                          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 80.0,
                        ),
                        TextField(
                          controller: textControllerLicense,
                          decoration: const InputDecoration(
                            hintText: '라이선스 키',
                            hintStyle: TextStyle(fontSize: 14.0),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)), //textFieldUnderline
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 24.0),
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
                          await checkValidLicenseKey();
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.buttonBlue,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30))
                          )
                        ),
                        // shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                        child: const Text(
                          '다음으로',
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

  Future checkValidLicenseKey() async{
    //정상 라이센스 값 확인
    if(!AppDAO.debugData.passCheckingLicenseKey){
      bool checked = await checkLicenseKey();
      if(!checked) return;
    }
    //개인정보수집 약관 동의 페이지로 변경
    Navigator.pushReplacementNamed(
        context, Routes.agreementTerm);
  }
}