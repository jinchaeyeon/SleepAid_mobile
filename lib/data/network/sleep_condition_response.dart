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
  static const int SCORE_NONE = 0;
  int id;
  String answerType;
  String question = "";
  bool isFixed = false;
  bool? answerBool;
  int answerScore = SCORE_NONE;
  DateTime? created;

  SleepConditionItem({
    required this.id,
    required this.answerType,
    this.question = "",
    this.answerBool,
    this.created,
    this.isFixed = false,
    this.answerScore = SCORE_NONE
  });

factory SleepConditionItem.fromJson(Map<String, dynamic> json) =>
  SleepConditionItem(
    id: json['id']??0,
    answerType : json['answer_type']??"",
    question: json['question']??"",
    answerBool: json['answer_bool'],
    isFixed: json['isFixed']??false,
    answerScore: json['answer_score'],
    created: json['created'],
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['answer_type'] = answerType;
    data['question'] = question;
    data['answer_bool'] = answerBool;
    data['created'] = created;
    data['isFixed'] = isFixed;
    data['answer_score'] = answerScore;
    return data;
  }

  /// 데이터 전송시 쓰는 폼
  Map<String, dynamic> toSendDataJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['condition'] = id;
    if(answerType == "score"){
      data['answer_score'] = answerScore;
      data['answer_bool'] = false;
    }else{
      data['answer_score'] = 0;
      data['answer_bool'] = answerBool??false;
    }
    return data;
  }
}