import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'src/login_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

final storage = FlutterSecureStorage();

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<int>('steps');
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
