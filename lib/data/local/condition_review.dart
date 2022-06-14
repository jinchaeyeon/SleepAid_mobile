import 'package:intl/intl.dart';
import 'package:sleepaid/data/network/sleep_condition_response.dart';

var dateFormat = DateFormat("yyyy년 mm월 dd일");
class ConditionReview{
  DateTime yesterday;
  List<SleepConditionItem> yesterdayReviewDataList;

  ConditionReview(this.yesterday, this.yesterdayReviewDataList);

  String getYesterdayStr() {
    return dateFormat.format(yesterday);
  }
}