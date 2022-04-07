import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'src/login_page.dart';

final storage = FlutterSecureStorage();

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Healthier App',
        theme: ThemeData(
          fontFamily: "Cairo",
        ),
        debugShowCheckedModeBanner: false,
        home: LoginPage());
  }
}
