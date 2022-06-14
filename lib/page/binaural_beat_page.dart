import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sleepaid/provider/bluetooth_provider.dart';
import 'package:sleepaid/provider/data_provider.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/yellow_button.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';

class BinauralBeatPage extends BaseStatefulWidget {
  static const ROUTE = "BinauralBeat";

  const BinauralBeatPage({Key? key}) : super(key: key);

  @override
  BinauralBeatState createState() => BinauralBeatState();
}

class BinauralBeatState extends State<BinauralBeatPage>
    with SingleTickerProviderStateMixin{

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: appBar(context, 'Binaural Beat 관리', isRound: true,),
        extendBody: true,
        body: SafeArea(
            child: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    context.watch<BluetoothProvider>().connectedDeviceForNeck == null?
                    Expanded(
                      child: getRecommandConnectWidget()
                    ):
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.only(left: 30, right: 30, top: 0, bottom: 0),
                          child: Column(
                            children: [
                              getGraphWidget("PPG"),
                              getGraphWidget("Actigraphy"),
                              getGraphWidget("HRV", showParameterUI:true),
                            ],
                          ),
                        )
                      )
                    )
                  ],
                )
            )
        )
    );
  }

  Widget getGraphWidget(String title, {bool showParameterUI=false} ){
    return Container(
      // color: AppColors.white,

      width: double.maxFinite,
      height: 220,
      child: Column(
        children: [
          Container(
            height: 60,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 0,top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("$title", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textBlack)),
                Text("  60", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textBlack)),
                Text("bpm", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.subTextGrey)),
                Text(" | 59", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textBlack)),
                Text("ms", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.subTextGrey)),
                Expanded(child: SizedBox.shrink()),
                showParameterUI?InkWell(
                    onTap:(){

                    },
                    child: Container(
                      width: 103,
                      height: 27,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: AppColors.buttonYellow),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: AppColors.buttonYellow,
                      ),
                      child: Center(
                        child: Text(
                          '파라미터 선택',
                          style: Theme.of(context).textTheme.headline4,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                ):const SizedBox.shrink()
              ]
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.grey ,
              width: double.maxFinite,
              height: double.maxFinite,
              child: SizedBox.shrink()
            )
          )
        ]
      )
    );
  }

  PreferredSize appBar(BuildContext context, String title, {bool isRound = true}) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(140),
      child: Container(
        width: double.maxFinite,
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
          ),
          borderRadius: isRound? const BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ): BorderRadius.zero,
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0, right: 0, bottom: 0, top: 50,
              child: Container(
                  width: double.maxFinite,
                  height: 50,
                  alignment: Alignment.center,
                  child: Container(
                    width: double.maxFinite,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 16,
                          height: 14,
                          margin: const EdgeInsets.only(right: 2),
                          child: Image.asset(AppImages.sound, fit: BoxFit.fill),
                        ),
                        const Center(
                          child: Text(
                            '이어폰을 착용해주세요.',
                            style: TextStyle(
                              color: AppColors.mainYellow,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  )
              )
            ),
            Positioned(
              left: 0, right: 0, bottom: 0, top: 0,
              child: Container(
                width: 300,
                height:double.maxFinite,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 60, height: 60,child: SizedBox.shrink(),),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 24,
                          height: 1.08,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.black.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          builder: (context) => SingleChildScrollView(
                            child: Container(
                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                              child: infoBottomSheet(),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        alignment: Alignment.center,
                        child: Image.asset(
                          AppImages.info,
                          fit: BoxFit.contain, width: 24, height: 24,

                        ),
                      ),
                    )
                  ]
                )
              ),
            ),
            Positioned(
                left: 0, top: 0, bottom: 0,
                child: Container(
                  height: 123,
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 36,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
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
                    ],
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }
  
  Widget infoBottomSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Binaural Beat?',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '특정 주파수의 소리를 이용하여 뇌의 뇌파를 조절하는 소리를 뜻합니다.',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Binaural Beat 설정 시 확인사항',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tone frequency는 1000Hz 미만까지 설정 가능하며, 두 주파수의 값 차이는 30Hz를 초과할 수 없습니다.',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget getRecommandConnectWidget() {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children:[
          const Text("기기를 연결해 주세요", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color:AppColors.subTextBlack)),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () async {
              await Navigator.pushNamed(context, Routes.bluetoothConnect);
            },
            style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.subButtonGrey,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))
                )
            ),
            child: const Text(
              '기기 연결하러 가기',
              style: TextStyle(
                fontSize: 15.0,
                color: AppColors.textBlack,
              ),
            ),
          )
        ]
      )
    );
  }
}