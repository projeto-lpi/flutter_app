// ignore_for_file: non_constant_identifier_names

class Steps {
  late int user_id;
  late int stepCount;
  late int date;

  Steps(this.user_id, this.stepCount, this.date);
  factory Steps.fromJson(dynamic json) {
    return Steps(json['user_id'], json['step_count'], json['date']);
  }
}
