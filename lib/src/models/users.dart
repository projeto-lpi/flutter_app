class Users {
  final String name;
  final String email;
  final String password;
  final String age;
  final String weight;
  final String height;

  const Users({
    required this.name,
    required this.email,
    required this.password,
    required this.age,
    required this.weight,
    required this.height,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      name: json['name'],
      email: json['email'],
      password: json['password'],
      age: json['age'],
      weight: json['weight'],
      height: json['height'],
    );
  }
}
