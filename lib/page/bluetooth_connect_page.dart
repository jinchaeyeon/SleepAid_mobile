import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_ble_lib_ios_15/flutter_ble_lib.dart';
import 'package:sleepaid/app_routes.dart';
import 'package:sleepaid/data/ble_device.dart';
import 'package:sleepaid/provider/auth_provider.dart';
import 'package:sleepaid/provider/bluetooth_provider.dart';
import 'package:sleepaid/provider/data_provider.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/util/app_strings.dart';
import 'package:sleepaid/util/app_styles.dart';
import 'package:sleepaid/util/functions.dart';
import 'package:sleepaid/util/statics.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:provider/provider.dart';


class BluetoothConnectPage extends BaseStatefulWidget {
  static const ROUTE = "/BluetoothConnect";

  const BluetoothConnectPage({Key? key}) : super(key: key);

  @override
  BluetoothConnectState createState() => BluetoothConnectState();
}

class BluetoothConnectState extends State<BluetoothConnectPage>
    with SingleTickerProviderStateMixin{

  @override
  void initState() {
    super.initState();
    startScanning();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: appBar(context, '블루투스 연결', isRound: false,),
        extendBody: false,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
            child: getBaseWillScope(
              context, Container(
                width: double.maxFinite,
                height: double.maxFinite,
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                    border: Border(top: BorderSide(color:AppColors.borderGrey.withOpacity(0.4), width:1))
                ),
                child: Column(
                  children: [
                    searchingStatusButton(context),
                    Expanded(
                      child: ListView.builder(
                        itemCount: context.watch<BluetoothProvider>().deviceList.length,
                        itemBuilder: (_context, index){
                          return _bluetoothDeviceListItemWidget(
                              context.read<BluetoothProvider>().deviceList, index);
                        },
                      )
                    )
                  ],
                ),
            ),
            onWillScope: () async {
              await stopScanning();
              Navigator.pop(context);
              return false;
            }
        )
      )
    );
  }

  /// 장치검색 / 검색중지 토글
  Future<void> searching() async{
    context.read<BluetoothProvider>().toggleDeviceScanning();
    //todo search
  }

  Widget searchingStatusButton(BuildContext context){
    return InkWell(
        onTap:() async {
          await searching();
        },
        child: Container(
            height: 70,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color:AppColors.borderGrey.withOpacity(0.4), width:1))
            ),
            padding: const EdgeInsets.only(left: 20, right: 20),
            width: double.maxFinite,
            child: Row(
                children: [
                  Text(
                    "기기 검색",
                    style: TextStyle(
                      color: Theme.of(context).textSelectionTheme.selectionColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width:10),
                  context.watch<BluetoothProvider>().isDeviceScanning?
                  const SizedBox(
                    width:20, height: 20,
                    child: CircularProgressIndicator(color: AppColors.grey, strokeWidth: 3,),
                  ):
                  const SizedBox(
                    width:20, height: 20,
                    child: Icon(Icons.search, color:AppColors.black,),
                  ),
                  const Expanded(child: SizedBox.shrink()),
                ]
            )
        )
    );
  }

  Widget _bluetoothDeviceListItemWidget(List<BleDevice> deviceList, int index) {
    BleDevice device = deviceList[index];
    BODY_TYPE bodyType = context.watch<BluetoothProvider>().isConnectedDevice(device);
    return InkWell(
        onTap:() async {
          await showBodyTypeDialog(context, device);
        },
        child: Container(
            height: 70,
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color:AppColors.borderGrey.withOpacity(0.4), width:1))
            ),
            padding: const EdgeInsets.only(left: 20, right: 20),
            width: double.maxFinite,
            child: Row(
                children: [
                  Text(
                    _getDeviceName(bodyType,device),
                    style: TextStyle(
                      color: Theme.of(context).textSelectionTheme.selectionColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Expanded(child: SizedBox.shrink()),
                  Text(
                    _getDeviceStatusText(bodyType, device),
                    style: TextStyle(
                      color: Theme.of(context).textSelectionTheme.selectionColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ]
            )
        )
    );
  }

  void startScanning() {
    context.read<BluetoothProvider>().startDeviceScanning();
  }

  Future<void> stopScanning() async {
    await context.read<BluetoothProvider>().stopDeviceScanning();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  Future<void> showBodyTypeDialog(BuildContext context, BleDevice device) async{
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return  Wrap(
            children: [
              Column(
                children: [
                  Container(height: 30),
                  Container(
                      height: 50,
                      width: double.maxFinite,
                      alignment: Alignment.center,
                      child: Text("기기부착 부위선택",
                          textAlign:TextAlign.center,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                              color: AppColors.textBlack))
                  ),
                  Container(
                      height: 50,
                      width: double.maxFinite,
                      alignment: Alignment.center,
                      child: Text(device.deviceName,
                          textAlign:TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                              color: AppColors.textBlack))
                  ),
                  Container(height: 70),
                  Container(
                    width: double.maxFinite,
                    height: 1,
                    color:AppColors.borderGrey,
                  ),
                  Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap:() async {
                              Navigator.pop(context);
                              context.read<DataProvider>().setLoading(true);
                              context.read<BluetoothProvider>().choiceBodyPosition(BODY_TYPE.NECK, device);
                              context.read<DataProvider>().setLoading(false);
                            },
                            child:Container(
                              height: 100,
                                alignment: Alignment.center,
                                child: Text("목",style:TextStyle(fontSize:20, color: AppColors.textBlack, fontWeight: FontWeight.bold))
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 100,
                          color:AppColors.borderGrey,
                        ),
                        Expanded(
                          child: InkWell(
                            onTap:() async {
                              Navigator.pop(context);
                              context.read<DataProvider>().setLoading(true);
                              context.read<BluetoothProvider>().choiceBodyPosition(BODY_TYPE.FOREHEAD, device);
                              context.read<DataProvider>().setLoading(false);
                            },
                            child:Container(
                                height: 100,
                                alignment: Alignment.center,
                                child: Text("이마", style:TextStyle(fontSize:20, color: AppColors.textBlack, fontWeight: FontWeight.bold))
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

  String _getDeviceName(BODY_TYPE bodyType, BleDevice device) {
    if(bodyType == BODY_TYPE.NONE){
      return device.deviceName;
    }else if(bodyType == BODY_TYPE.NECK){
      return "${device.deviceName}(목)";
    }else if(bodyType == BODY_TYPE.FOREHEAD){
      return "${device.deviceName}(이마)";
    }else{
      return device.deviceName;
    }
  }

  String _getDeviceStatusText(BODY_TYPE bodyType, BleDevice device) {
    if(bodyType == BODY_TYPE.NONE){
      return "연결안됨";
    }else if(bodyType == BODY_TYPE.NECK && device.state == PeripheralConnectionState.connected){
      return "연결됨";
    }else if(bodyType == BODY_TYPE.FOREHEAD && device.state == PeripheralConnectionState.connected){
      return "연결됨";
    }else if(bodyType == BODY_TYPE.NECK && device.state == PeripheralConnectionState.connecting){
      return "연결중";
    }else if(bodyType == BODY_TYPE.FOREHEAD && device.state == PeripheralConnectionState.connecting){
      return "연결중";
    }else{
      return "연결안됨";
    }
  }
}