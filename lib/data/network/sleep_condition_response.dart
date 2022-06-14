import 'base_response.dart';

class SleepConditionItemListResponse extends BaseResponse{
  int state = BaseResponse.STATE_NO_CONNECT;
  List<SleepConditionItem> list;
  SleepConditionItemListResponse(
      {
        this.state=BaseResponse.STATE_NO_CONNECT,
        this.list=const [],
      });

  factory SleepConditionItemListResponse.fromJson(Map<String, dynamic> json){

    //todo
    return SleepConditionItemListResponse(
      state: json['state'],
      list: json['list'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['state'] = state;
    data['list'] = list;
    return data;
  }
}

class SleepConditionItem extends BaseResponse{
  static const int SCORE_NONE = 99;

  String question = "";
  bool isFixed = false;
  bool? isCorrect;
  int score = SCORE_NONE;
  DateTime? created;

  SleepConditionItem({
    this.question = "",
    this.isCorrect,
    this.created,
    this.isFixed = false,
    this.score = SCORE_NONE
  });

factory SleepConditionItem.fromJson(Map<String, dynamic> json) =>
  SleepConditionItem(
    question: json['question'],
    isCorrect: json['isCorrect'],
    isFixed: json['isFixed'],
    score: json['score'],
    created: json['created'],
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['question'] = question;
    data['isCorrect'] = isCorrect;
    data['created'] = created;
    data['isFixed'] = isFixed;
    data['score'] = score;
    return data;
  }
}