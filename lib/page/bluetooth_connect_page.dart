import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sleepaid/app_routes.dart';
import 'package:sleepaid/data/ble_device.dart';
import 'package:sleepaid/provider/auth_provider.dart';
import 'package:sleepaid/provider/bluetooth_provider.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/util/app_strings.dart';
import 'package:sleepaid/util/app_styles.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:provider/provider.dart';


class BluetoothConnectPage extends BaseStatefulWidget {
  static const ROUTE = "BluetoothConnect";

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

    return WillPopScope(
      onWillPop: () async {
        await stopScanning();
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
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
                          flex: 3,
                          child: Container(
                              height: 50,
                              width: double.maxFinite,
                              child: Row(
                                children: [
                                  InkWell(
                                      onTap:(){
                                        Navigator.pop(context);
                                      },
                                      child: Image.asset(AppImages.ic_menu, width: 50, height: 50)
                                  ),
                                  Text(AppStrings.app_logo, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Container(
                                      width: 50, height: 50,
                                      child: SizedBox.shrink()
                                  )
                                ],
                              )
                          )
                      ),
                      Expanded(
                        flex: 7,
                        child: ListView.builder(
                          itemCount: context.watch<BluetoothProvider>().deviceList.length,
                          itemBuilder: (_context, index){
                            return _bluetoothDeviceListItemWidget(
                                context.watch<BluetoothProvider>().deviceList, index);
                          },
                        ),
                      ),
                    ],
                  )
              )
          )
      ));
  }

  Widget _bluetoothDeviceListItemWidget(List<BleDevice> deviceList, int index) {
    BleDevice device = deviceList[index];
    return InkWell(
      onTap:() async {
        await showBodyTypeDialog(context, device);
      },
      child: SizedBox(
          height: 50,
          width: double.maxFinite,
          child: Container(
            color: index.isEven?AppColors.baseGreen:AppColors.white,
            child: Row(
              children: [
                Text("${device.deviceName}"),
                const Expanded(child: SizedBox.shrink(),),
                Text("${device.peripheral.identifier}"),
              ],
            )
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
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0.0),
          contentPadding: const EdgeInsets.all(0.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Container(
              child: Column(
                children: [
                  Container(
                      child: Text("기기부착 부위선택")
                  ),
                  Container(
                      child: Text("~~~~~~")
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                            onTap: () async {
                              await context.read<BluetoothProvider>().choiceBodyPosition(BODY_TYPE.NECK,device);
                              Navigator.pop(context);
                            },
                            child: Container(
                                child: Text("목")
                            )
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                            onTap: () async {
                              await context.read<BluetoothProvider>().choiceBodyPosition(BODY_TYPE.FOREHEAD,device);
                              Navigator.pop(context);
                            },
                            child: Container(
                                child: Text("이마")
                            )
                        ),
                      )
                    ],
                  )
                ],
              )
            )
          ),
        );
      },
    );
  }
}