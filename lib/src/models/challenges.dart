class Challenge {
  late String description;
  late int value;
  late int goal;

  Challenge(this.description, this.value, this.goal);

  factory Challenge.fromJson(dynamic json) {
    return Challenge(json['description'], json['value'], json['goal']);
  }
}
