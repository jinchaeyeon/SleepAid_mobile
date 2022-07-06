import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sleepaid/util/app_colors.dart';

class GraphPainter extends CustomPainter {
  final List<int> oneCycleDataLeft;
  final List<int> oneCycleDataRight;
  int maxValue = 100;
  GraphPainter(this.oneCycleDataLeft, this.oneCycleDataRight);

  @override
  void paint(Canvas canvas, Size size) {
    print("size x:${size.width} y:${size.height}");
    var i = 0;
    List<Offset> maxPoints = [];
    var t = size.width / (oneCycleDataLeft.length - 1);
    for (var _i = 0, _len = oneCycleDataLeft.length; _i < _len; _i++) {
      maxPoints.add(Offset(
          t * i,
          size.height / 2 +
              oneCycleDataLeft[_i].toDouble() / maxValue * size.height / 2));
      i++;
    }

    var paint = Paint()
      ..color = AppColors.mainGreen
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(PointMode.polygon, maxPoints, paint);

    i = 0;
    maxPoints = [];
    t = size.width / (oneCycleDataRight.length - 1);
    for (var _i = 0, _len = oneCycleDataRight.length; _i < _len; _i++) {
      maxPoints.add(Offset(
          t * i,
          size.height / 2 +
              oneCycleDataRight[_i].toDouble() / maxValue * size.height / 2));
      i++;
    }

    paint = Paint()
      ..color = AppColors.mainYellow
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(PointMode.polygon, maxPoints, paint);
  }

  @override
  bool shouldRepaint(GraphPainter old) {
    if (oneCycleDataLeft != old.oneCycleDataLeft) {
      return true;
    }
    return false;
  }
}