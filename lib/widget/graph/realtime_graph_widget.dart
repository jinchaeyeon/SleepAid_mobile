import 'package:flutter/material.dart';
import 'package:sleepaid/data/local/device_sensor_data.dart';
import 'package:sleepaid/widget/graph/realtime_graph_painter.dart';

import '../../util/functions.dart';


class RealtimeGraphWidget extends StatefulWidget {
  List<DeviceSensorData>? data;
  String type;

  RealtimeGraphWidget({Key? key, this.data, required this.type}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GraphState();
}

class _GraphState extends State<RealtimeGraphWidget> {
  double _baseScale = 1;
  double _scale = 1;

  List<DeviceSensorData> dataList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dataList = widget.data??[];
    return GestureDetector(
        onScaleStart: (ScaleStartDetails scaleStartDetails) {
          _baseScale = _scale;
        },
        onScaleUpdate: (ScaleUpdateDetails details) {
          if (details.scale == 1.0) {
            if(details.focalPointDelta.dx < 0){
              //left
            }else if(details.focalPointDelta.dx > 0){
              //right
            }
          }else{
            setState(() {
              _scale = (_baseScale * details.scale).clamp(1.0, 2.0);
            });
          }
        },
        child: SizedBox(
            width: double.maxFinite,
            height: double.maxFinite,
            child: CustomPaint(
              painter: RealtimeGraphPainter(zoomLevel: _scale, dataList: dataList, type: widget.type),
            )
        )
    );
  }
}
