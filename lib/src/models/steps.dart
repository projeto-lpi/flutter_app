import 'dart:io';
import 'dart:convert';

class Steps {
  late int user_id;
  late int stepCount;
  late int date;


  Steps(this.user_id, this.stepCount, this.date);
  factory Steps.fromJson(dynamic json) {
    return Steps(json['user_id'], json['step_count'], json['date']);
  }


}