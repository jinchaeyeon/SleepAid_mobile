import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:sleepaid/bluetooth/flutter_reactive_ble/ble_scanner.dart';
import 'package:sleepaid/data/ble_device.dart';
import 'package:sleepaid/provider/bluetooth_provider.dart';
import 'package:sleepaid/provider/data_provider.dart';
import 'package:sleepaid/util/app_colors.dart';
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
    Future.delayed(const Duration(milliseconds: 100), (){
      startScanning();
    });
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
                    context.watch<BluetoothProvider>().deviceNeck == null ?Container()
                    : _bluetoothDeviceListItemWidget(device: context.watch<BluetoothProvider>().deviceNeck),
                    context.watch<BluetoothProvider>().deviceForehead == null ?Container()
                        : _bluetoothDeviceListItemWidget(device: context.watch<BluetoothProvider>().deviceForehead),
                    Expanded(
                      child: StreamBuilder<BleScannerState>(
                        stream: context.watch<BluetoothProvider>().scanner.state.asBroadcastStream(),
                        builder: (
                            BuildContext context,
                            AsyncSnapshot<BleScannerState> snapshot,
                        ){
                          if(snapshot.data != null){
                            return ListView.builder(
                                itemCount: snapshot.data!.discoveredDevices.length,
                                itemBuilder: (_context, index){
                                  // 연결된 기기는 숨기기
                                  if(BODY_TYPE.NONE != context.watch<BluetoothProvider>().isConnectedDevice(snapshot.data?.discoveredDevices[index].id)){
                                    return Container();
                                  }
                                  return _bluetoothDeviceListItemWidget(snapshot: snapshot, index: index);
                                },
                              );
                          }else{
                            return Container();
                          }
                        }
                      )
                      // child: ListView.builder(
                      //   itemCount: context.watch<BluetoothProvider>().scanner.,
                      //   itemBuilder: (_context, index){
                      //     return _bluetoothDeviceListItemWidget(
                      //         context.read<BluetoothProvider>().deviceList, index);
                      //   },
                      // )
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

  Widget _bluetoothDeviceListItemWidget({BleDevice? device, AsyncSnapshot? snapshot, int? index}) {
    String selectedDeviceId = "";
    String name = "";
    if(device != null){
      selectedDeviceId = device.id;
    }else if(snapshot is AsyncSnapshot<ConnectionStateUpdate>){
      selectedDeviceId = snapshot.data!.deviceId;
    }else if(snapshot is AsyncSnapshot<BleScannerState>){
      selectedDeviceId = snapshot.data!.discoveredDevices[index!].id;
    }
    BODY_TYPE bodyType = context.watch<BluetoothProvider>().isConnectedDevice(selectedDeviceId);
    if(device != null){
      name = _getDeviceName(bodyType, null, index: index, name: device.deviceName);
    }else{
      name = _getDeviceName(bodyType, snapshot!, index: index);
    }
    return InkWell(
        onTap:() async {
          await showBodyTypeDialog(context, device: device, snapshot: snapshot, index: index);
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
                    name,
                    style: TextStyle(
                      color: Theme.of(context).textSelectionTheme.selectionColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Expanded(child: SizedBox.shrink()),
                  Text(
                    _getDeviceStatusText(bodyType, selectedDeviceId),
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

  Future<void> showBodyTypeDialog(BuildContext context, {int? index, AsyncSnapshot? snapshot, BleDevice? device}) async{
    String name = "";
    if(snapshot != null){
      name = snapshot.connectionState.name;
    }else if(device != null){
      name = device!.deviceName;
    }

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
                      child: Text(name,
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
                              context.read<BluetoothProvider>().choiceBodyPosition(BODY_TYPE.NECK, snapshot: snapshot, index: index, device: device);
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
                              context.read<BluetoothProvider>().choiceBodyPosition(BODY_TYPE.FOREHEAD, snapshot: snapshot, device: device);
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

  String _getDeviceName(BODY_TYPE bodyType, AsyncSnapshot? snapshot, {int? index, String? name}) {
    String name = "";
    if(bodyType == BODY_TYPE.NECK){
      name = context.watch<BluetoothProvider>().connectorNeck.connectedDeviceName;
    }else if(bodyType == BODY_TYPE.FOREHEAD){
      name = context.watch<BluetoothProvider>().connectorForehead.connectedDeviceName;
    }else{
      if(snapshot is AsyncSnapshot<BleScannerState>){
        name = snapshot.data?.discoveredDevices[index!].name??"";
      }
    }

    if(bodyType == BODY_TYPE.NONE){
      return name;
    }else if(bodyType == BODY_TYPE.NECK){
      return "${name}(목)";
    }else if(bodyType == BODY_TYPE.FOREHEAD){
      return "${name}(이마)";
    }else{
      return name;
    }
  }

  String _getDeviceStatusText(BODY_TYPE bodyType, String deviceId) {
    if(bodyType == BODY_TYPE.NONE){
      return "연결안됨";
    }else if(
      deviceId == context.read<BluetoothProvider>().connectorNeck.connectedDeviceId ||
      deviceId == context.read<BluetoothProvider>().connectorForehead.connectedDeviceId
    ){
      return "연결됨";
    }else{
      return "연결안됨";
    }
  }
}