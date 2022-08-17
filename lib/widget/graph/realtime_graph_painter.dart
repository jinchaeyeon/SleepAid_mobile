import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sleepaid/util/app_colors.dart';
import '../../data/ble_device.dart';
import '../../data/local/device_sensor_data.dart';

/// 그래프 그리는 페인터 생성
class RealtimeGraphPainter extends CustomPainter {
  int maxXValue = 100;
  int maxYValue = 65536;
  List<DeviceSensorData> dataList;
  double zoomLevel;
  DateTime? created;
  String type;

  RealtimeGraphPainter({required this.zoomLevel, required this.dataList, required this.type}){
    created=DateTime.now();
  }

  @override
  void paint(Canvas canvas, Size size) {
    var i = 0;
    List<Offset> maxPoints = [];
    var x1 = size.width / (dataList.length - 1);
    var y1 = size.height / BleDevice.getMaxYFromType(type);

    for (var _i = 0, _len = dataList.length ; _i < _len; _i++) {
      i++;
      maxPoints.add(
          Offset(
            x1 * i,
            (y1 * dataList[_i]?.getDataByType(type)?.toDouble()??0).clamp(0, size.height)
          )
      );
    }

    var paint = Paint()
      ..color = AppColors.mainGreen
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(PointMode.polygon, maxPoints, paint);
  }

  @override
  bool shouldRepaint(RealtimeGraphPainter old) {
    if (created?.toIso8601String() != old.created?.toIso8601String()) {
      return true;
    }
    if (zoomLevel != old.zoomLevel) {
      return true;
    }
    return false;
  }
}