import 'package:flutter/material.dart';
import 'package:sleepaid/data/local/sensor_data.dart';
import 'package:sleepaid/util/app_colors.dart';

import 'graph_painter.dart';


class GraphWidget extends StatefulWidget {

  GraphWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GraphState();
}

class _GraphState extends State<GraphWidget> {
  double _baseScale = 1;
  double _scale = 1;

  List<SensorData> dataList = [
    SensorData(DateTime.now(),-10),
    SensorData(DateTime.now().add(Duration(seconds:1)),20),
    SensorData(DateTime.now().add(Duration(seconds:2)),-30),
    SensorData(DateTime.now().add(Duration(seconds:3)),-40),
    SensorData(DateTime.now().add(Duration(seconds:4)),50),
    SensorData(DateTime.now().add(Duration(seconds:5)),60),
    SensorData(DateTime.now().add(Duration(seconds:6)),70),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onScaleStart: (ScaleStartDetails scaleStartDetails) {
          _baseScale = _scale;
        },
        onScaleUpdate: (ScaleUpdateDetails scaleUpdateDetails) {
          // don't update the UI if the scale didn't change
          if (scaleUpdateDetails.scale == 1.0) {
            return;
          }
          setState(() {
            _scale = (_baseScale * scaleUpdateDetails.scale).clamp(0.5, 5.0);
          });
        },
      child:Container(
        width: double.maxFinite,
        height: double.maxFinite,
        child: CustomPaint(
          painter: GraphPainter(zoomLevel: _scale, dataList: dataList),
        )
      )
    );
  }
}
