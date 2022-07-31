import 'package:sleepaid/data/network/calendar_response.dart';

enum DIRECTION_TYPE {
  DIRECTION_NONE,
  DIRECTION_UP,
  DIRECTION_DOWN,
}

class CalendarDateBuilder{
  final DateTime startDate; // 시작일
  final DateTime endDate; // 종료일
  List<DateTime> dates = [];
  List<CalendarDetailResponse>  datelist = [];
  // 2022-01 / 2022-02 등의 문자열
  List<String> monthStrings = [];
  // 각 monthStrings 별 날짜 모음 monthDays["2022-01] 에는 1월 날짜 모음
  Map<String, List<DateTime>> monthDays = {};
  // 각 주별 날짜모음, weeks["2022-01"]에는 {1주차,2주차,3주차,4주차} 데이터가 존재
  Map<String, List<List<DateTime?>>> weeksPerMonth = {};
  // 전체 주
  List<List<DateTime?>> weeks = [];

  /// from to 입력 시, 캘린더를 위한 날짜 데이터 분리
  CalendarDateBuilder(this.startDate, this.endDate, this.datelist){
    buildCalendarData();
  }
  
  ///각 달별로 날짜를 모아서 저장
  buildCalendarData(){
    final daysGap = getDayGap(); //전체날짜숫자
    if(daysGap == 0){
      return;
    }
    dates = [];
    DateTime targetDate = DateTime(startDate.year, startDate.month, startDate.day);
    for(int i=0; i<daysGap; i++){
      dates.add(DateTime(targetDate.year, targetDate.month, targetDate.day));
      monthStrings.add("${targetDate.year}-${targetDate.month}");
      /// 각 달에 날짜를 저장
      if(monthDays["${targetDate.year}-${targetDate.month}"] == null){
        monthDays["${targetDate.year}-${targetDate.month}"] =
        [DateTime(targetDate.year, targetDate.month, targetDate.day)];
      }else{
        monthDays["${targetDate.year}-${targetDate.month}"]!
            .add(DateTime(targetDate.year, targetDate.month, targetDate.day));
      }
      targetDate = targetDate.add(const Duration(days:1));
      print("targetDate: ${targetDate}");
    }
    monthStrings = monthStrings.toSet().toList();
    print("monthStrings: $monthStrings");
    /// 각달에 주 데이터를 저장
    /// weekday 1월요일 ... 7 일요일
    /// 여기서는 일요일부터 시작이라서
    /// 7 1 2 3 4 5 6 반복
    /// 0 1 2 3 4 5 6
    for (var monthString in monthStrings) {
      if(weeksPerMonth[monthString] == null){
        weeksPerMonth[monthString] = [];
      }
      print("monthDays[$monthString]: ${monthDays[monthString]}");
      List<DateTime?> iWeeks = [null, null, null, null, null, null, null];
      monthDays[monthString]?.forEach((DateTime date) {
        if(date.weekday != 6){
          iWeeks[date.weekday % 7] = date;
        // }else if(date.weekday == 6 && date != monthDays[monthString]!.last){
        }else if(date.weekday == 6){
          iWeeks[date.weekday] = date;
          weeksPerMonth[monthString]!.add(List.from(iWeeks));
          weeks.add(List.from(iWeeks));
          iWeeks = [null, null, null, null, null, null, null];
        }

        if(monthDays[monthString]!.last == date){
          if( iWeeks[0] == null &&
              iWeeks[1] == null &&
              iWeeks[2] == null &&
              iWeeks[3] == null &&
              iWeeks[4] == null &&
              iWeeks[5] == null &&
              iWeeks[6] == null ){
          }else{
            weeksPerMonth[monthString]!.add(List.from(iWeeks));
            weeks.add(List.from(iWeeks));
          }
          iWeeks = [null, null, null, null, null, null, null];
        }
      });
    }

  print("weeks: ${weeksPerMonth}");


  }

  /// yPosition은 현재 달력 스크롤의 위치
  DateTime getCurrentDateFromScrollPosition(double yPosition) {
    DateTime result = DateTime.now();
    double weekYPosition = 0;

    for (var monthString in monthStrings) {
      weekYPosition += 50;
      for (var week in weeksPerMonth[monthString]!) {
        weekYPosition += 90;
        if(weekYPosition >= yPosition){
          for (var day in week) {
            if(day!=null){
              result = day;
              return result;
            }
          }
        }
      }
    }

    return result;
  }

  /// 스크롤의 위치를 받아서 현재 달력의 N월 위치로 Jump처리하기 위한 위치 돌려줌
  double getCurrentScrollPosition(DIRECTION_TYPE direction, double yPosition) {
    double offset = (direction == DIRECTION_TYPE.DIRECTION_UP)?300:-300;
    double weekYPosition = -50;
    for (var monthString in monthStrings) {
      weekYPosition += (50+10);
      double headerPosition = weekYPosition;
      for (var week in weeksPerMonth[monthString]!) {
        weekYPosition += 90;
        if(weekYPosition >= yPosition + offset){
          print("headerPosition: $headerPosition");
          return headerPosition ;
        }
      }
    }
    return weekYPosition;
  }

  /// 선택일이 일요일이면 이후로 6일치
  /// 선택일이 수요일이면 이전으로 3일치, 이후로 3일치
  /// 선택일이 토요일이면 이전으로 6일치
  /// weekday 1월요일 ... 7 일요일
  /// 여기서는 일요일부터 시작이라서
  /// 7 1 2 3 4 5 6 반복
  /// 0 1 2 3 4 5 6
  List<DateTime?> getWeek(int weekIndex, {bool withOtherMonth=false}) {
    List<DateTime?> iWeeks = [];
    iWeeks.addAll(weeks[weekIndex]);
    ///with Other month 가 있으면 앞뒤로 다른 달의 데이터가 있을 때 가져와서 추가한다
    if(withOtherMonth){
      List<DateTime?> otherWeeks = [];
      if(iWeeks[0] == null){
        /// 전주 데이터 체크
        if(weekIndex > 0 && weeks[weekIndex-1].isNotEmpty){
          otherWeeks.addAll(weeks[weekIndex-1]);
        }
      }else if(iWeeks[6] == null){
        /// 다음주 데이터 체크
        if(weekIndex+1 < weeks.length && weeks[weekIndex+1].isNotEmpty){
          otherWeeks.addAll(weeks[weekIndex+1]);
        }
      }
      if(otherWeeks.isNotEmpty){
        for(int i = 0; i < 7; i++){
          if(iWeeks[i] == null && otherWeeks[i] != null){
            iWeeks[i] = otherWeeks[i];
          }
        }
      }
    }
    return iWeeks;
  }

  /// 주별 index 값으로 주 데이터 리턴
  List<DateTime?> getWeekWithIndex(int index, {bool withOtherMonth = false}) {
    return getWeek(index, withOtherMonth: withOtherMonth);
  }

  /// 선택된 날의 week index 리턴
  int getWeekIndex(DateTime? selectedDate) {
    bool isReturn = false;

    selectedDate ??= startDate;
    int index = 0;
    weeksPerMonth.forEach((key, list) {
      print("===KEY:${key}");
      for (var week in list) {
        print("====week: ${week.first?.toIso8601String()} ~ ${week.last?.toIso8601String()} | index[${index}]");
        if(week.contains(selectedDate)){
          isReturn = true;
        }
        if(!isReturn) {
          index += 1;
        }
      }

      print("=====index:${index}");
    });
    print("getWeekIndex(${selectedDate.toIso8601String()}) : index: $index");
    return index;
  }

  /// 날짜차이
  int getDayGap({DateTime? selectedDate}) {
    selectedDate ??= endDate;
    return selectedDate.difference(startDate).inDays;
  }

  /// 캘린더의 주 사이즈
  int getWeeksSize() {
    int weekSize = 0;
    weeksPerMonth.forEach((key, list) {
      weekSize += list.length;
    });
    return weekSize;
  }
}