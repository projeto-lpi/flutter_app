import 'dart:io';

import 'package:healthier_app/src/models/users.dart';

class Nutritionists extends Users {
  Nutritionists(
      int id, String email, String password, String name, String picture)
      : super(id, email, password, name, picture);

  factory Nutritionists.fromJson(dynamic json) {
    return Nutritionists(json["ID"], json['email'], json['password'],
        json['name'], json['picture']);
  }
}
