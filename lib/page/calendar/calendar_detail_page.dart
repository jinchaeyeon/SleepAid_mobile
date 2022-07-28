import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sleepaid/data/network/sleep_analysis_response.dart';
import 'package:sleepaid/page/calendar/calendar_detail_sub_page.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/util/functions.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/calendar/calendar_date_builder.dart';
import 'package:sleepaid/widget/calendar/week_calendar_widget.dart.dart';

class CalendarDetailPage extends BaseStatefulWidget {
  static const ROUTE = "/CalendarDetail";

  const CalendarDetailPage({Key? key}) : super(key: key);

  @override
  CalendarDetailState createState() => CalendarDetailState();
}

class CalendarDetailState extends State<CalendarDetailPage>
    with SingleTickerProviderStateMixin{
  Map<String, dynamic>? args;
  CalendarDateBuilder? dateBuilder;
  DateTime? selectedDate = DateTime.now();

  PageController pageController = PageController(initialPage: 0);
  PageController weekController = PageController(initialPage: 0);

  Map<String, SleepAnalysisResponse> data = const {};
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(args == null){
      args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      dateBuilder = args!["dateBuilder"];
      selectedDate = args!["selectedDate"];
      data = args!["data"] ?? const {};
      initPageController();
    }

    onDayCallback(CalendarDateBuilder dateBuilder, DateTime? date){
      if(date!=null){
        print("onDayCallback ${date?.toIso8601String()}");
        selectedDate = date;
        setState(() {});
      }
    }

    return Scaffold(
        extendBody: true,
        body: SafeArea(
            child: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                color: AppColors.backgroundGrey,
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    _actionbar(),
                    Container(
                      height:96,
                      width:double.maxFinite,
                      child:PageView.builder(
                        controller:weekController,
                        itemCount :_getWeekPageCount(),
                        itemBuilder: (context, index){
                          showToast("index:$index");
                          return Container(
                            width:double.maxFinite,
                            height:double.maxFinite,
                            color:Colors.transparent,
                            padding: const EdgeInsets.all(2),
                            child: WeekCalendarWidget(dateBuilder: dateBuilder!,
                                week: dateBuilder!.getWeek(selectedDate!),
                                data: data
                            )
                          );
                        }

                      )
                    ),
                    Expanded(
                      child: Container(
                          width:double.maxFinite,
                          height:double.maxFinite,
                          color: AppColors.white,
                          child: PageView.builder(
                            controller:pageController,
                            itemCount: dateBuilder?.getDayGap()??0,
                            itemBuilder: (context, index){
                              return CalendarDetailSubPage(
                                selectedDate: dateBuilder!.startDate.add(Duration(days:index))
                              );
                            }
                          )
                      )
                    )
                  ],
                )
            )
        )
    );
  }

  _actionbar() {
    return Container(
      width: double.maxFinite,
      height: 80,
        child: Stack(
          children: [
            Positioned(left: 10, top:10,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  child: Image.asset(
                    AppImages.back, color: Theme.of(context).primaryIconTheme.color,
                    fit: BoxFit.contain, width: 12, height: 21,

                  ),
                ),
              ),
            ),
            Positioned(left: 70, top:10,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 200,
                  height: 60,
                  alignment: Alignment.centerLeft,
                  child: Text("${selectedDate!.month}월", style: TextStyle(height: 1, fontSize: 22,color: AppColors.textBlack, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ), // Positioned()
          ],
        )
      );
  }

  void initPageController() {
    pageController = PageController(
      initialPage: 0,
    );
  }


  // 금토
  int _getWeekPageCount() {
    if(dateBuilder == null || dateBuilder!.getDayGap() == 0){
      return 0;
    }
    int size = dateBuilder!.getDayGap() ~/ 7;
    return size;
  }
}


