import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/calendar/calendar_date_builder.dart';
import 'package:sleepaid/widget/calendar/my_weekly_calendar_widget.dart';

class CalendarDetailSubPage extends BaseStatefulWidget {
  final DateTime selectedDate;
  const CalendarDetailSubPage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  CalendarDetailSubState createState() => CalendarDetailSubState();
}

class CalendarDetailSubState extends State<CalendarDetailSubPage>
    with SingleTickerProviderStateMixin{

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      child: SingleChildScrollView(
        child:Container(
          color:Colors.red,
          height: 2000,
          width: double.maxFinite,
          child:Text(widget.selectedDate.toIso8601String())
        )
      )
    );
  }
}


