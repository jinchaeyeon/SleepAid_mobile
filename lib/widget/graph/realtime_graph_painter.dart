import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/util/app_colors.dart';
import '../../data/ble_device.dart';
import '../../data/local/device_sensor_data.dart';

/// 그래프 그리는 페인터 생성
class RealtimeGraphPainter extends CustomPainter {
  int maxXValue = 100;
  int maxYValue = 65536;
  List<DeviceSensorData> dataList;
  Map<String, List<double>> hrvDataList;
  double zoomLevel;
  DateTime? created;
  String type;
  double leftMoved; /// 0이면 왼쪽치우침0, 숫자가 있으면 그만큼 왼쪽으로 치우침 0~100

  RealtimeGraphPainter({
    required this.zoomLevel, required this.dataList,
    required this.type, required this.hrvDataList,
    required this.leftMoved}){
    created=DateTime.now();
  }

  @override
  void paint(Canvas canvas, Size size) {
    /// //////////////////// SENSOR DATA LIST ////////////////////// ///
    var i = 0;
    if(dataList.isNotEmpty) {
      List<Offset> maxPoints = [];
      List<DeviceSensorData> subList = dataList;
      if(subList.length > 300){
        subList = subList.sublist((50 + (2.5 * leftMoved.toInt()).toInt()));
      }

      var x1 = (size.width) / (subList.length - 1);
      var y1 = size.height / BleDevice.getMaxYFromType(type);
      y1 = y1 * zoomLevel;

      for (var _i = 0, _len = subList.length - 1 ; _i < _len; _i++) {
        i++;
        int sensorValue = subList[_i].getDataByType(type);
        maxPoints.add(
            Offset(
                x1 * i,
                (y1 * sensorValue).clamp(0, size.height)
            )
        );
      }

      var paint = Paint()
        ..color = AppColors.mainGreen
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round;
      canvas.drawPoints(PointMode.polygon, maxPoints, paint);
    }
    /// //////////////////// HRV DATA LIST ///////////////////////// ///
    if(hrvDataList.isNotEmpty){
      int index = 0;
      List<Offset> maxPoints = [];
      for(var key in hrvDataList.keys){
        bool isSelected = false;
        /// 비선택 인덱스면 미노출
        for(var index in AppDAO.selectedParameterIndexes){
          if(AppDAO.parameters[index].name == key){
            isSelected = true;
          }
        }
        if(isSelected){
          i = 0;
          maxPoints = [];
          List<double> subList = hrvDataList[key]??[];
          if(subList.length > 100){
            subList = subList.sublist(50 + (0.5 * leftMoved.toInt()).toInt());
          }
          var x1 = (size.width) / (subList.length - 1);
          var y1 = size.height / BleDevice.getMaxYFromType(type) * 0.25;
          y1 = y1 * zoomLevel;
          for (var _i = 0, _len = (subList.length - 1) ; _i < _len; _i++) {
            i++;
            int sensorValue = (subList[_i].toInt());
            maxPoints.add(
                Offset(
                    x1 * i,
                    ((y1 * sensorValue) + (BleDevice.getMaxYFromType(type) * 0.5)).clamp(0,size.height)
                )
            );
          }

          var paint = Paint()
            ..color = Color.fromARGB(255, 255 - min(255, 10 * index), 255 - min(255, 25 * index), 255 - min(255, 25 * index))
            ..strokeWidth = 1
            ..strokeCap = StrokeCap.round;
          canvas.drawPoints(PointMode.polygon, maxPoints, paint);
          index += 1;
        }
      }
    }
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