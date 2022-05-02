import 'dart:io';

import 'package:healthier_app/src/models/users.dart';

class Trainer extends Users {
  Trainer(int id, String email, String password, String name, String picture)
      : super(id, email, password, name, picture);

  factory Trainer.fromJson(dynamic json) {
    return Trainer(json['ID'], json['email'], json['password'], json['name'],
        json['picture']);
  }
}
