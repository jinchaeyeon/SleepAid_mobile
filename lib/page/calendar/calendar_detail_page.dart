import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sleepaid/data/network/sleep_analysis_response.dart';
import 'package:sleepaid/data/network/sleep_condition_parameter_response.dart';
import 'package:sleepaid/page/calendar/calendar_detail_sub_page.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/calendar/calendar_date_builder.dart';
import 'package:sleepaid/widget/calendar/week_calendar_widget.dart.dart';
import '../../data/local/app_dao.dart';

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

  PageController dateViewController = PageController(initialPage: 0);
  PageController weekViewController = PageController(initialPage: 0);

  Map<String, SleepConditionDateResponse> data = const {};

  int pageIndex = 0;
  int weekIndex = 0;

  bool dateControllerSwipeLeft = false;
  bool weekControllerSwipeLeft = false;

  onTapCallback(CalendarDateBuilder dateBuilder, DateTime dateTime,
      Map<String, SleepConditionDateResponse> data) {
    selectedDate = dateTime;
    dateViewController.jumpToPage(dateBuilder.getDayGap(selectedDate:selectedDate));
    setState(() {});
  }

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
      print("CalendarDetailPage | ${selectedDate?.toIso8601String()}");
      initPageController();
    }
    // onDayCallback(CalendarDateBuilder dateBuilder, DateTime? date){
    //   if(date!=null){
    //     print("onDayCallback ${date?.toIso8601String()}");
    //     selectedDate = date;
    //     setState(() {});
    //   }
    // }

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
                        controller:weekViewController,
                        itemCount :_getWeekPageCount(),
                        onPageChanged: (int page){
                          if(page.toDouble() > weekViewController.page!.toDouble()){
                            weekControllerSwipeLeft = false;
                          }else{
                            weekControllerSwipeLeft = true;
                          }
                        },
                        itemBuilder: (context, index){
                          return Container(
                            width:double.maxFinite,
                            height:double.maxFinite,
                            color:AppDAO.isDarkMode? AppColors.colorDarkSplash.withOpacity(0.5):Colors.transparent,
                            padding: const EdgeInsets.all(2),
                            child: WeekCalendarWidget(
                                onTapCallback: onTapCallback,
                                dateBuilder: dateBuilder!,
                                week: dateBuilder!.getWeekWithIndex(index, withOtherMonth: true),
                                data: data,
                                selectedDate: selectedDate,
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
                            controller:dateViewController,
                              onPageChanged: (int page){
                                if(page.toDouble() > dateViewController.page!.toDouble()){
                                  // selectedDate = selectedDate!.add(Duration(days: 1));
                                  dateControllerSwipeLeft = false;
                                }else{
                                  // selectedDate = selectedDate!.subtract(Duration(days: 1));
                                  dateControllerSwipeLeft = true;
                                }
                                setState(() {});
                              },
                            itemCount: dateBuilder?.getDayGap()??0,
                            itemBuilder: (context, index){
                              print("selectedDate:$selectedDate | index: $index | dateBuilder!.startDate: ${dateBuilder!.startDate}");
                              return CalendarDetailSubPage(
                                data:data,
                                // selectedDate: selectedDate??dateBuilder!.startDate.add(Duration(days:index))
                                  selectedDate: selectedDate??dateBuilder!.startDate.add(Duration(days:index))
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
      color:AppDAO.isDarkMode? AppColors.colorDarkSplash:Colors.transparent,
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
                  child: Text("${selectedDate?.month??0}월", style: TextStyle(height: 1, fontSize: 22,color: AppColors.textBlack, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ), // Positioned()
          ],
        )
      );
  }

  void initPageController() {
    pageIndex = dateBuilder?.getDayGap(selectedDate:selectedDate)??0;
    dateViewController = PageController(
      initialPage: pageIndex,
    );

    /// 날짜 좌우 스와이프시, 해당하는 주 위젯을 불러온다
    dateViewController.addListener(() {
      swipeListenrer("date");
    });

    weekIndex = dateBuilder?.getWeekIndex(selectedDate)??0;
    weekViewController = PageController(
      initialPage: weekIndex,
    );
    weekViewController.addListener((){
      swipeListenrer("week");
    });
  }

  // 금토
  int _getWeekPageCount() {
    return dateBuilder?.getWeeksSize()??0;
  }

  void swipeListenrer(String type) {
    if(type == "date"){
      selectedDate = dateBuilder!.dates[dateViewController.page!.toInt()];
      weekViewController.jumpToPage(dateBuilder!.getWeekIndex(selectedDate));
      selectedDate = dateBuilder!.dates[dateViewController.page!.toInt()];
    }else{
      if(weekControllerSwipeLeft){
        selectedDate = dateBuilder!.getWeekWithIndex(weekViewController?.page?.toInt()??0, withOtherMonth: true).last;
      }else{
        selectedDate = dateBuilder!.getWeekWithIndex(weekViewController?.page?.toInt()??0, withOtherMonth: true).first;
      }
    }
    setState(() {});
  }
}


