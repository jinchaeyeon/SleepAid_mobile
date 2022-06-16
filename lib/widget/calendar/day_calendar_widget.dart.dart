import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';

import 'month_calendar_widget.dart.dart';

class DayCalendarWidget extends BaseStatefulWidget{
  final Function? onTapCallback;
  const DayCalendarWidget({Key? key, this.onTapCallback}) : super(key: key);

  @override
  DayCalendarState createState() => DayCalendarState();
}

class DayCalendarState extends State<DayCalendarWidget>{
  String text = "월";
  String number = "1";
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        if(widget.onTapCallback != null){
          widget.onTapCallback!(DateTime.now());
        }
      },
      child: SizedBox(
          width: double.maxFinite,
          height: 90,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(height:5),
              Text("$text", style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
              Text("$number", style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
              Container(
                  width: 10,
                  height: 10,
                  margin: EdgeInsets.only(top:10),
                  decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(5)
                  )
              ),
              SizedBox(height:5),
            ],
          )
      )
    );
  }
}