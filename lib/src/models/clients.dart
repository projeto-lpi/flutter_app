// ignore_for_file: non_constant_identifier_names

class Clients {
  late int id;
  late String age;
  late String weight;
  late String height;
  late String gender;
  late int trainer_id;
  late int nutri_id;
  late int user_id;

  Clients(this.id, this.age, this.weight, this.height, this.gender,
      this.trainer_id, this.nutri_id, this.user_id);

  factory Clients.fromJson(dynamic json) {
    return Clients(json['ID'], json['age'], json['weight'], json['height'],
        json['gender'], json["trainer_id"], json['nutri_id'], json["user_id"]);
  }
}
