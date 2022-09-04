import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sleepaid/util/app_colors.dart';

/// 그래프 그리는 페인터 생성
/// 각 시간기준으로 노출
class SleepAnalysisGraphPainter extends CustomPainter {
  int maxValue = 100;
  List<int> dataList;
  SleepAnalysisGraphPainter({required this.dataList});

  @override
  void paint(Canvas canvas, Size size) {
    var i = 0;
    List<Offset> maxPoints = [];
    var t = size.width / (dataList.length - 1);
    for (var _i = 0, _len = dataList.length; _i < _len; _i++) {
      maxPoints.add(Offset( t * i , dataList[_i] * size.height / 100  ));
          // size.height / 2 +
          //     dataList[_i].value.toDouble() / maxValue * size.height / 2));
      i++;
    }

    var paint = Paint()
      ..color = AppColors.mainGreen
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    var paintBg = Paint()
      ..color = AppColors.mainYellow.withOpacity(0.3)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.square;
    canvas.drawRect(Rect.fromLTRB(0, size.height, size.width, 0), paintBg);
    canvas.drawPoints(PointMode.polygon, maxPoints, paint);
  }

  @override
  bool shouldRepaint(SleepAnalysisGraphPainter old) {
    if (dataList != old.dataList) {
      return true;
    }
    return false;
  }
}