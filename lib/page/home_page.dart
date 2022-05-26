import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sleepaid/provider/bluetooth_provider.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/util/app_strings.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';

class HomePage extends BaseStatefulWidget {
  static const ROUTE = "Home";

  const HomePage({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<HomePage>
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
            alignment: Alignment.center,
            child: Column(
              children: [
                const Expanded(flex: 1, child: SizedBox.shrink()),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 50,
                    width: double.maxFinite,
                    child: Row(
                      children: [
                        Text(AppStrings.app_logo, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(child:const SizedBox.shrink()),
                        InkWell(
                          onTap:(){
                            openMenu();
                          },
                          child: Image.asset(AppImages.ic_menu, width: 50, height: 50)
                        )
                      ],
                    )
                  )
                ),
                Expanded(
                  child: Container(
                    child: Column(
                      children: [
                        Container(),
                      ]
                    )
                  ),
                ),
                Expanded(
                    flex: 3,
                    child: Container(
                        height: 50,
                        width: double.maxFinite,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 50, right: 50, top: 0, bottom: 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.grey,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Text("2021년 01월 01일"),
                                    Text("수면 컨디션 작성"),
                                    Text.rich(
                                      TextSpan(
                                        text: '09 ',
                                        style: Theme.of(context).textTheme.headline2,
                                        children: const <TextSpan>[
                                          TextSpan(text: '/', style: TextStyle(fontWeight: FontWeight.bold)),
                                          TextSpan(text: ' 09'),
                                        ],
                                      ),
                                    )
                                  ]
                                )
                              )
                            ),
                            Positioned(
                              left: 50, right: 50, top: 0, bottom: 50,
                              child: Container(
                                  alignment:Alignment.bottomCenter,
                                  child: AnimatedRotation(
                                    turns: context.watch<BluetoothProvider>().isDataScanning?0.125:0,
                                    duration: const Duration(milliseconds: 100),
                                    child: InkWell(
                                      onTap:() async {
                                        await toggleCollectingData();
                                      },
                                      child: Image.asset(AppImages.ic_x),
                                    )
                                  )
                                )
                            )
                          ],
                        )
                    )
                ),
              ],
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

}