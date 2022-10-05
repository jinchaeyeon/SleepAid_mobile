import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sleepaid/data/ble_device.dart';
import 'package:sleepaid/data/network/parameter_response.dart';
import 'package:sleepaid/provider/bluetooth_provider.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/util/functions.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/yellow_button.dart';
import 'package:provider/provider.dart';
import '../app_routes.dart';
import '../data/local/app_dao.dart';
import '../provider/data_provider.dart';
import '../widget/graph/realtime_graph_widget.dart';

class RealtimeSignalPage extends BaseStatefulWidget {
  static const ROUTE = "/RealtimeSignal";
  const RealtimeSignalPage({Key? key}) : super(key: key);
  @override
  RealtimeSignalState createState() => RealtimeSignalState();
}

class RealtimeSignalState extends State<RealtimeSignalPage>
    with SingleTickerProviderStateMixin{

  bool isNeckMode = true;

  @override
  void initState() {
    // 서버 파라미터가 비어 있으면 기본으로 파라미터 0번 선택됨
    if(AppDAO.parameters.isNotEmpty){
      AppDAO.selectedParameterIndexes = [0];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: appBar(context, '실시간 생체신호', isRound: false,),
        extendBody: true,
        body: SafeArea(
            child: getBaseWillScope(context, mainContent(context), routes: RealtimeSignalPage.ROUTE)
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
                // if(showParameterUI)Text("  60", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textBlack)),
                // if(showParameterUI)Text("bpm", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.subTextGrey)),
                // if(showParameterUI)Text(" | 59", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textBlack)),
                // if(showParameterUI)Text("ms", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.subTextGrey)),
                Expanded(child: SizedBox.shrink()),
                showParameterUI?InkWell(
                    onTap:(){
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
                            child: Wrap(
                              children: [
                                parameterBottomSheet()
                              ],
                            ),
                          ),
                        ),
                      );
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
              child: RealtimeGraphWidget(
                type: title,
                data: isNeckMode
                  ?context.watch<BluetoothProvider>().deviceNeck?.sensors
                    :context.watch<BluetoothProvider>().deviceForehead?.sensors,
                hrvData: isNeckMode
                    ?context.watch<BluetoothProvider>().deviceNeck?.hrvData
                    :context.watch<BluetoothProvider>().deviceForehead?.hrvData,
              )
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
      decoration: BoxDecoration(
        color: AppDAO.isDarkMode?AppColors.colorDarkSplash:Colors.white,
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
                'PPG (Photoplethysmograp)',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '말초 혈류량 변화에 따른 조직에서의 광흡수도 변화를 측정. 심장 박동 주기에 따라 혈류량이 변하며, 이로 인해 신호의 크기가 변하게 됨',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'HRV (Heart rate variability)',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '심박 변이도',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'ActigraphyX',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'monitoring human rest/activity cycles',
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

  Widget parameterBottomSheet() {
    return Container(
      padding: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: AppDAO.isDarkMode?AppColors.colorDarkSplash:Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Column(
            children: [
              Text(
                '파라미터 선택',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 14),
              addParameterButtons(),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.maxFinite,
                        height: 80,
                        color: AppDAO.isDarkMode?AppColors.borderGrey:AppColors.buttonGrey,
                        child: Center(
                          child: Text(
                            '취소',
                            style: TextStyle(
                              color: AppColors.textBlack,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.maxFinite,
                        height: 80,
                        color: AppColors.buttonBlue,
                        child: const Center(
                          child: Text(
                            '적용',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    ),
                  ),
                ],
              )
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
          Text("기기를 연결해 주세요",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color:AppColors.subTextBlack)),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () async {
              await Navigator.pushNamed(context, Routes.bluetoothConnect);
            },
            style: OutlinedButton.styleFrom(
                backgroundColor: AppDAO.isDarkMode?AppColors.colorDarkSplash:AppColors.subButtonGrey,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))
                )
            ),
            child: Text(
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

  Widget mainContent(BuildContext cotext) {
    return Container(
        width: double.maxFinite,
        height: double.maxFinite,
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                ),
                width: double.maxFinite,
                height: 50,
                child: Row(
                    children:[
                      Expanded(
                          child: InkWell(
                              onTap: (){
                                isNeckMode = true;
                                setState(() {});
                              },
                              child: Container(
                                  width: double.maxFinite,
                                  height: 50,
                                  alignment: Alignment.center,
                                  child: Text("목", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textBlack))
                              ))),
                      Expanded(
                          child: InkWell(
                              onTap: (){
                                isNeckMode = false;
                                setState(() {});
                              },
                              child: Container(
                                  width: double.maxFinite,
                                  height: 50,
                                  alignment: Alignment.center,
                                  child: Text("이마", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textBlack))
                              ))),
                    ]
                )
            ),
            Container(
                width: double.maxFinite,
                height: 3,
                child: Row(
                    children:[
                      Expanded(
                          child: InkWell(
                              onTap: (){

                              },
                              child: Container(
                                  width: double.maxFinite,
                                  height: 3,
                                  color: isNeckMode
                                      ?AppColors.borderGrey
                                      :Theme.of(context).colorScheme.secondary,
                                  alignment: Alignment.center,
                                  child: SizedBox.shrink()
                              ))),
                      Expanded(
                          child: InkWell(
                              onTap: (){

                              },
                              child: Container(
                                  width: double.maxFinite,
                                  height: 3,
                                  color: !isNeckMode
                                      ?AppColors.borderGrey
                                      :Theme.of(context).colorScheme.secondary,
                                  alignment: Alignment.center,
                                  child: SizedBox.shrink()
                              ))),
                    ]
                )
            ),
            // context.watch<BluetoothProvider>().connectedDeviceForNeck == null?
            if(isNeckMode)context.watch<BluetoothProvider>().connectorNeck.connectedDeviceId == ""?
            Expanded(
                child: getRecommandConnectWidget()
            ):
            Expanded(
                child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.only(left: 30, right: 30, top: 0, bottom: 0),
                      child: Column(
                        children: [
                          getGraphWidget(BleDevice.realtimeSesorTypes[0]),
                          getGraphWidget(BleDevice.realtimeSesorTypes[1]),
                          getGraphWidget(BleDevice.realtimeSesorTypes[2]),
                          getGraphWidget(BleDevice.realtimeSesorTypes[3]),
                          getGraphWidget(BleDevice.realtimeSesorTypes[4]),
                          getGraphWidget(BleDevice.realtimeSesorTypes[5]),
                          getGraphWidget("HRV", showParameterUI:true),
                          // getGraphWidget("HRV", showParameterUI:true),
                        ],
                      ),
                    )
                )
            ),
            if(!isNeckMode)context.watch<BluetoothProvider>().connectorForehead.connectedDeviceId == ""?
            Expanded(
                child: getRecommandConnectWidget()
            ):
            Expanded(
                child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.only(left: 30, right: 30, top: 0, bottom: 0),
                      child: Column(
                        children: [
                          getGraphWidget(BleDevice.realtimeSesorTypes[0]),
                          getGraphWidget(BleDevice.realtimeSesorTypes[1]),
                          getGraphWidget(BleDevice.realtimeSesorTypes[2]),
                          getGraphWidget(BleDevice.realtimeSesorTypes[3]),
                          getGraphWidget(BleDevice.realtimeSesorTypes[4]),
                          getGraphWidget(BleDevice.realtimeSesorTypes[5]),
                          getGraphWidget("HRV", showParameterUI:true),
                        ],
                      ),
                    )
                )
            )
          ],
        )
    );
  }

  Widget addParameterButtons() {
    List<ParameterResponse> parameters = [];
    for(var parameter in AppDAO.parameters){
      if(parameter.onDisplay){
        parameters.add(parameter);
      }
    }

    void onTapCallback(int index, bool isSelected) {
      if(isSelected){
        AppDAO.selectedParameterIndexes.add(index);
      }else{
        AppDAO.selectedParameterIndexes.remove(index);
      }
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (parameters.length >= 1 && parameters[0].onDisplay)?YellowButton(
              onTapCallback: onTapCallback, isSelected: AppDAO.selectedParameterIndexes.contains(0),
                index: 0, buttonText: '${parameters[0].name}'):Container(width: 69,),
            const SizedBox(width: 20),
            (parameters.length >= 2 && parameters[1].onDisplay)?YellowButton(
                onTapCallback: onTapCallback, isSelected: AppDAO.selectedParameterIndexes.contains(1),
                index: 1, buttonText: '${parameters[1].name}'):Container(width: 69,),
            const SizedBox(width: 20),
            (parameters.length >= 3 && parameters[2].onDisplay)?YellowButton(
                onTapCallback: onTapCallback, isSelected: AppDAO.selectedParameterIndexes.contains(2),
                index: 2, buttonText: '${parameters[2].name}'):Container(width: 69,),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (parameters.length >= 4 && parameters[3].onDisplay)?YellowButton(
                onTapCallback: onTapCallback, isSelected: AppDAO.selectedParameterIndexes.contains(3),
                index: 3, buttonText: '${parameters[3].name}'):Container(width: 69,),
            const SizedBox(width: 20),
            (parameters.length >= 5 && parameters[4].onDisplay)?YellowButton(
                onTapCallback: onTapCallback, isSelected: AppDAO.selectedParameterIndexes.contains(4),
                index: 4, buttonText: '${parameters[4].name}'):Container(width: 69,),
            const SizedBox(width: 20),
            (parameters.length >= 6 && parameters[5].onDisplay)?YellowButton(
                onTapCallback: onTapCallback, isSelected: AppDAO.selectedParameterIndexes.contains(5),
                index: 5, buttonText: '${parameters[5].name}'):Container(width: 69,),
          ],
        ),
        if(parameters.length >=7) const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (parameters.length >= 7 && parameters[6].onDisplay)?YellowButton(
                onTapCallback: onTapCallback, isSelected: AppDAO.selectedParameterIndexes.contains(6),
                index: 6, buttonText: '${parameters[6].name}'):Container(width: 69,),
            const SizedBox(width: 20),
            (parameters.length >= 8 && parameters[7].onDisplay)?YellowButton(
                onTapCallback: onTapCallback, isSelected: AppDAO.selectedParameterIndexes.contains(7),
                index: 7, buttonText: '${parameters[7].name}'):Container(width: 69,),
            const SizedBox(width: 20),
            (parameters.length >= 9 && parameters[8].onDisplay)?YellowButton(
                onTapCallback: onTapCallback, isSelected: AppDAO.selectedParameterIndexes.contains(8),
                index: 8, buttonText: '${parameters[8].name}'):Container(width: 69,),
          ],
        ),
      ],
    );
  }
}