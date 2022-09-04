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

  RealtimeGraphPainter({required this.zoomLevel, required this.dataList, required this.type, required this.hrvDataList}){
    created=DateTime.now();
  }

  @override
  void paint(Canvas canvas, Size size) {
    /// //////////////////// SENSOR DATA LIST ////////////////////// ///
    var i = 0;
    if(dataList.isNotEmpty) {
      List<Offset> maxPoints = [];
      var x1 = size.width / (dataList.length - 1);
      var y1 = size.height / BleDevice.getMaxYFromType(type);
      for (var _i = 0, _len = dataList.length ; _i < _len; _i++) {
        i++;
        int sensorValue = dataList[_i].getDataByType(type);
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
            subList = subList.sublist(50);
          }
          // var x1 = size.width / min((hrvDataList[key]?.length ?? 1 - 1), 50);
          var x1 = size.width / (subList.length - 1);
          var y1 = size.height / BleDevice.getMaxYFromType(type);
          // for (var _i = 0, _len = min((hrvDataList[key]?.length ?? 0), 50) ; _i < _len; _i++) {
          for (var _i = 0, _len = (subList.length) ; _i < _len; _i++) {
            i++;
            // int sensorValue = hrvDataList[key]?[_i].toInt() ?? (BleDevice.getMaxYFromType(type)~/ 2);
            int sensorValue = (subList[_i].toInt());
            maxPoints.add(
                Offset(
                    x1 * i,
                    (y1 * sensorValue).clamp(0, size.height)
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