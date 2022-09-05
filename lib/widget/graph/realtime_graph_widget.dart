import 'package:flutter/material.dart';
import 'package:sleepaid/data/ble_device.dart';
import 'package:sleepaid/data/local/device_sensor_data.dart';
import 'package:sleepaid/widget/graph/realtime_graph_painter.dart';

import '../../data/local/app_dao.dart';
import '../../util/functions.dart';


class RealtimeGraphWidget extends StatefulWidget {
  /// 실시간 센서 데이터는 data로, 서버 통한 hrvData는 hrvData로 처리
  List<DeviceSensorData>? data;
  Map<String, List<double>>? hrvData;

  String type;

  RealtimeGraphWidget({Key? key, this.data, required this.type, this.hrvData}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GraphState();
}

class _GraphState extends State<RealtimeGraphWidget> {
  double _baseScale = 1;
  double _scale = 1;
  double _leftMoved = 0;

  List<DeviceSensorData> dataList = [];
  Map<String, List<double>> hrvDataList = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dataList = widget.data??[];
    hrvDataList = widget.hrvData??{};

    return GestureDetector(
        onScaleStart: (ScaleStartDetails scaleStartDetails) {
          _baseScale = _scale;
        },
        onScaleUpdate: (ScaleUpdateDetails details) {
          if (details.scale == 1.0) {
            if(details.focalPointDelta.dx < 0){
              //left
              print("left, ${_leftMoved}");
              _leftMoved = (_leftMoved - 1).clamp(0.0, 100.0);
            }else if(details.focalPointDelta.dx > 0){
              //right
              _leftMoved = (_leftMoved + 1).clamp(0.0, 100.0);
              print("right, ${_leftMoved}");
            }
          }else{
            setState(() {
              _scale = (_baseScale * details.scale).clamp(1.0, 8.0);
            });
          }
        },
        child: SizedBox(
            width: double.maxFinite,
            height: double.maxFinite,
            child: CustomPaint(
              painter: RealtimeGraphPainter(
                  zoomLevel: _scale, dataList: dataList, hrvDataList: hrvDataList,
                  type: widget.type, leftMoved: _leftMoved),
            )
        )
    );
  }
}
