import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sleepaid/app_routes.dart';
import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/network/sleep_analysis_response.dart';
import 'package:sleepaid/provider/data_provider.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/calendar/calendar_date_builder.dart';
import 'package:sleepaid/widget/calendar/my_calendar_widget.dart';
import 'package:provider/provider.dart';

class CalendarPage extends BaseStatefulWidget {
  static const ROUTE = "/Calendar";

  const CalendarPage({Key? key}) : super(key: key);

  @override
  CalendarState createState() => CalendarState();
}

class CalendarState extends State<CalendarPage>
    with SingleTickerProviderStateMixin{
  bool isLoaded = false;

  Map<String, SleepAnalysisResponse> sleepAnalysisMap = {};


  void onTapCallback(CalendarDateBuilder dateBuilder, DateTime dateTime,
      Map<String, SleepAnalysisResponse> data) {
    Navigator.pushNamed(context, Routes.calendarDetail,
      arguments:{
      "dateBuilder": dateBuilder,
      "selectedDate": dateTime,
      "data": data,
      });
  }

  @override
  void initState() {
    super.initState();
    loadData();
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
                child: isLoaded?MyCalendarWidget(
                  data: sleepAnalysisMap,
                  onTapCallback: onTapCallback,
                  startDate: AppDAO.authData.created,
                  endDate: DateTime.now(),
                ):Container()
            )
        )
    );
  }

  void loadData() {
    Future.delayed(const Duration(milliseconds:200),() async {
      sleepAnalysisMap = await context.read<DataProvider>().getSleepAnalysisList(AppDAO.authData.created);
      isLoaded = true;
      setState(() {});
    });
  }
}


