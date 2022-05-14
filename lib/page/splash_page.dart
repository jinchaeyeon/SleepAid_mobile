import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';

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
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        extendBody: true,
        body: SafeArea(
          child: Container(
            width: double.maxFinite,
            height: double.maxFinite,
            child: const Text("SPLASH")
          )
        )
    );
  }
}