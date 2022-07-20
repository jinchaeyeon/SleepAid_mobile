import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sleepaid/data/local/sensor_data.dart';
import 'package:sleepaid/util/app_colors.dart';

/// 그래프 그리는 페인터 생성
class GraphPainter extends CustomPainter {
  int maxValue = 100;
  List<SensorData> dataList;
  double zoomLevel;
  GraphPainter({required this.zoomLevel, required this.dataList});

  @override
  void paint(Canvas canvas, Size size) {
    print("size x:${size.width} y:${size.height}");
    var i = 0;
    List<Offset> maxPoints = [];
    var t = size.width / (dataList.length - 1);
    for (var _i = 0, _len = dataList.length; _i < _len; _i++) {
      maxPoints.add(Offset(
          t * i,
          size.height / 2 +
              dataList[_i].value.toDouble() / maxValue * size.height / 2));
      i++;
    }

    var paint = Paint()
      ..color = AppColors.mainGreen
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(PointMode.polygon, maxPoints, paint);
  }

  @override
  bool shouldRepaint(GraphPainter old) {
    if (dataList != old.dataList) {
      return true;
    }
    if (zoomLevel != old.zoomLevel) {
      return true;
    }
    return false;
  }
}