import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sleepaid/provider/bluetooth_provider.dart';
import 'package:sleepaid/provider/data_provider.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/util/functions.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:provider/provider.dart';
import '../app_routes.dart';

///연결중인 장치 있을때와 없을때 구분
class HomePage extends BaseStatefulWidget {
  static const ROUTE = "Home";

  const HomePage({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<HomePage>
    with SingleTickerProviderStateMixin{
  Size? size;

  @override
  void initState() {
    super.initState();
    checkBluetoothPermission();
  }

  @override
  Widget build(BuildContext context){
    size ??= MediaQuery.of(context).size;
    checkNextDay(context);
    return WillPopScope(
      onWillPop: () async{
        await completedExit();
        return false;
      },
      child: Scaffold(
          extendBody: true,
          body: SafeArea(
              child: Container(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  alignment: Alignment.topCenter,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[Theme.of(context).colorScheme.primaryVariant, Theme.of(context).colorScheme.secondaryVariant],
                    ),
                  ),                  child: AspectRatio(
                    aspectRatio: getAspectRatio(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal:20),
                      child: SingleChildScrollView(
                        child: Container(
                          width: double.maxFinite,
                          height: geteDeviceHeight(context) - 30,
                          child: homeContent()
                        )
                      )
                    )
                  )
              )
          )
      )
    );
  }

  /// 메뉴 열기
  openMenu() {
    Navigator.pushNamed(context, Routes.menu);
  }

  // 데이터 수집/비수집 변환
  Future<void> toggleCollectingData() async{
    await context.read<BluetoothProvider>().toggleDataCollecting();
  }

  void checkBluetoothPermission() {
    context.read<BluetoothProvider>().checkBluetoothPermission();
  }

  Widget homeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(child: SizedBox.shrink(),),
        Container(
          height: 70,
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 70,
                padding: const EdgeInsets.only(left:20, right:20),
                alignment: Alignment.center,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sleep Aid',
                      style: TextStyle(
                        color: AppColors.mainBlue,
                        fontSize: 30,
                        // // fontFamily: Util.roboto,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, Routes.menu);
                      },
                      child: Container(
                        width:50, height: 50,
                        padding: const EdgeInsets.all(15),
                        child: Image.asset(AppImages.menu, fit: BoxFit.contain, width: 20, height: 20,)
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ),
        const Expanded(child: SizedBox.shrink(),),
        SizedBox(
          width: double.maxFinite,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, Routes.bodySignal);
                },
                child: contentButton(AppImages.bioSignal, '실시간 생체신호', true, '실시간 신호 출력중', ''),
              ),
              GestureDetector(
                onTap: () {
                  //todo
                  // Navigator.pushNamed(context, routeElectricStimulation);
                },
                child: contentButton(AppImages.electricalStimulation, '전기자극설정', true, '전기 자극 출력증', ''),
              ),
            ],
          ),
        ),
        const Expanded(child: SizedBox.shrink(),),
        SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  //todo
                  // Navigator.pushNamed(context, routeBinauralBeat);
                },
                child: contentButton(AppImages.binauralBeat, 'Binaural Beat', true, 'Binaural Beat 출력중', ''),
              ),
              GestureDetector(
                onTap: () {
                  //todo
                  // Navigator.pushNamed(context, routeSleepAnalysis);
                },
                child: contentButton(AppImages.sleepAnalysis, '수면분석', false, '새로운 수면 정보 확인', ''),
              ),
            ],
          ),
        ),
        const Expanded(child: SizedBox.shrink(),),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                //todo
                // Navigator.pushNamed(context, routeSleepAnalysis);
              },
              child: contentButton(AppImages.bluetoothConnect, '기기 연결 (목)', true, '배터리 잔량 100%', ''),
            ),
            GestureDetector(
                onTap: () {
                  //todo
                  // Navigator.pushNamed(context, routeSleepAnalysis);
                },
                child: contentButton(AppImages.bluetoothDisconnect, '기기 연결 (이마)', false, '배터리 잔량 -', '')
            ),
          ],
        ),
        const Expanded(child: SizedBox.shrink(),),
       InkWell(
         onTap: () {
           Navigator.pushNamed(context, Routes.conditionReview);
         },
         child:  Container(
           height: 150,
           padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
           child: Stack(
             children: [
               Container(
                 width: double.maxFinite,
                 height: 120,
                 padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
                 decoration: BoxDecoration(
                   color: Theme.of(context).cardColor,
                   borderRadius: BorderRadius.circular(14),
                 ),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text(
                       context.read<DataProvider>().getYesterdayDateTime(),
                       style: Theme.of(context).textTheme.bodyText1,
                     ),
                     Text(
                       '수면컨디션을 작성해주세요.',
                       style: Theme.of(context).textTheme.bodyText1,
                     ),
                     RichText(
                       text: TextSpan(
                         style: const TextStyle(
                           fontSize: 14,
                           // fontFamily: Util.notoSans,
                           fontWeight: FontWeight.w400,
                         ),
                         children: [
                           TextSpan(
                             text: '09',
                             style: TextStyle(color: AppColors.subTextBlack),
                           ),
                           TextSpan(
                             text: ' / 09',
                             style: TextStyle(color: AppColors.textGrey),
                           )
                         ],
                       ),
                     ),
                   ],
                 ),
               ),
               Positioned(
                 bottom: 0,
                 left: (getDeviceWidth(context) / 2) - (52/2) -35,
                 child: GestureDetector(
                   onTap: () async {
                     //todo
                     await toggleCollectingData();
                     // Navigator.pushNamed(context, routeSleepCondition);
                   },
                   child: SizedBox(
                     width: 52,
                     height: 52,
                     child: AnimatedRotation(
                         turns: context.watch<BluetoothProvider>().isDataScanning?0:0.125,
                         duration: const Duration(milliseconds: 100),
                         child: InkWell(
                           onTap:() async {
                             await toggleCollectingData();
                           },
                           child: Image.asset(AppImages.add),
                         )
                     ),
                   ),
                 ),
               )
             ],
           ),
         )
       ),
      ],
    );
  }

  Widget contentButton(String image, String title, bool isOn, String state, String route) {
    return Expanded(
      flex: 1,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        width: _getItemWidth(context),
        height: _getItemHeight(context),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              width: 38,
              height: 38,
              child: Image.asset(image, fit: BoxFit.contain),
            ),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).textSelectionTheme.selectionColor,
                fontSize: 14,
                // fontFamily: Util.notoSans,
                fontWeight: FontWeight.w400,
              ),
            ),
            stateContainer(state, isOn),
          ],
        ),
      ),
    );
  }

  Widget stateContainer(String state, bool isOn) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      height: 22,
      decoration: BoxDecoration(
        color: isOn ? AppColors.mainYellow : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(width: 1.5, color: AppColors.mainYellow),
      ),
      child: Center(
        child: Text(
          state,
          style: TextStyle(
            color: isOn ? Colors.white : AppColors.mainYellow,
            fontSize: 10,
            // fontFamily: Util.notoSans,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  double getDeviceWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  getAspectRatio(BuildContext context) {
    var portrait = MediaQuery.of(context).orientation;
    if(portrait == Orientation.portrait){
      return 280/560;
    }
    return 560/280;

  }

  double geteDeviceHeight(BuildContext context) {
    var portrait = MediaQuery.of(context).orientation;
    if(portrait == Orientation.portrait){
      return MediaQuery.of(context).size.height;
    }
    return MediaQuery.of(context).size.height * 2;
  }

  ///화면이 불려왔을 때 날짜가 변경되면 데이터 갱신 요청
  void checkNextDay(BuildContext context) {

  }

  double _getItemWidth(BuildContext context) {
    if(size==null) return 130;
    if(size!.width > 300) return (size!.width / 2) - 60;
    return 130;
  }

  double _getItemHeight(BuildContext context) {
    if(size==null) return 130;
    if(size!.height/ 4 > 130) return (size!.height/ 4) - 60;
    return 130;
  }
}

