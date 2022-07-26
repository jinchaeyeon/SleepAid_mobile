import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sleepaid/app_routes.dart';
import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/calendar/calendar_date_builder.dart';
import 'package:sleepaid/widget/calendar/my_calendar_widget.dart';

class CalendarPage extends BaseStatefulWidget {
  static const ROUTE = "/Calendar";

  const CalendarPage({Key? key}) : super(key: key);

  @override
  CalendarState createState() => CalendarState();
}

class CalendarState extends State<CalendarPage>
    with SingleTickerProviderStateMixin{

  void onTapCallback(CalendarDateBuilder dateBuilder, DateTime dateTime) {
    Navigator.pushNamed(context, Routes.calendarDetail,
      arguments:{
      "dateBuilder": dateBuilder,
      "selectedDate": dateTime,
      });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        body: SafeArea(
            child: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                alignment: Alignment.topCenter,
                child: MyCalendarWidget(
                  onTapCallback: onTapCallback,
                  // startDate: AppDAO.authData.created,
                  // endDate: DateTime.now().subtract(const Duration(days:1)),
                  startDate: DateTime.now().subtract(const Duration(days:200)),
                  endDate: DateTime.now().subtract(const Duration(days:1)),
                )
            )
        )
    );
  }
}


