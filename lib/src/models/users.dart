class Users {
  late int id;
  late String name;
  late String email;
  late String password;
  late String picture;

  Users(this.id, this.email, this.password, this.name, this.picture);
  factory Users.fromJson(dynamic json) {
    return Users(json['ID'], json['email'], json['password'], json['name'],
        json['picture']);
  }
}
