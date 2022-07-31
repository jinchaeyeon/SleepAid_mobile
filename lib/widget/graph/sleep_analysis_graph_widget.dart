import 'package:flutter/material.dart';
import 'package:sleepaid/data/local/sensor_data.dart';
import 'package:sleepaid/data/network/sleep_analysis_response.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/widget/graph/sleep_analysis_graph_painter.dart';

import 'graph_painter.dart';


class SleepAnalisysGraphWidget extends StatefulWidget {
  List<Object> data;

  SleepAnalisysGraphWidget({Key? key, required this.data}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GraphState();
}

class _GraphState extends State<SleepAnalisysGraphWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onScaleStart: (ScaleStartDetails scaleStartDetails) {
          // _baseScale = _scale;
        },
        onScaleUpdate: (ScaleUpdateDetails scaleUpdateDetails) {
          // // don't update the UI if the scale didn't change
          // if (scaleUpdateDetails.scale == 1.0) {
          //   return;
          // }
          // setState(() {
          //   _scale = (_baseScale * scaleUpdateDetails.scale).clamp(0.5, 5.0);
          // });
        },
      child:SizedBox(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  child: CustomPaint(
                    painter: SleepAnalysisGraphPainter( dataList: widget.data),
                  )
              )
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("22:00", style: Theme.of(context).textTheme.bodyText2),
                Text("23:00", style: Theme.of(context).textTheme.bodyText2),
                Text("24:00", style: Theme.of(context).textTheme.bodyText2),
                Text("01:00", style: Theme.of(context).textTheme.bodyText2),
                Text("02:00", style: Theme.of(context).textTheme.bodyText2),
                Text("03:00", style: Theme.of(context).textTheme.bodyText2),
                Text("04:00", style: Theme.of(context).textTheme.bodyText2),
                Text("05:00", style: Theme.of(context).textTheme.bodyText2),
                Text("06:00", style: Theme.of(context).textTheme.bodyText2),
              ]
            )
          ]
        )
      )
    );
  }
}
