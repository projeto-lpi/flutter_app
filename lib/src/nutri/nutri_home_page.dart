// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, avoid_print

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:healthier_app/main.dart';
import 'package:healthier_app/src/utils/constants.dart' as constants;
import 'package:healthier_app/src/utils/jwt.dart';

class NutriHomePage extends StatefulWidget {
  const NutriHomePage({Key? key}) : super(key: key);

  @override
  State<NutriHomePage> createState() => _NutriHomePageState();
}

class _NutriHomePageState extends State<NutriHomePage> {
  late String name = "";
  String ip = constants.IP;

  @override
  void initState() {
    getUsername();
    super.initState();
  }

  getUsername() async {
    var jwt = await storage.read(key: "jwt");
    var results = parseJwtPayLoad(jwt!);
    setState(() {
      name = results["name"];
      print(name);
      print("hello");
    });
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          title: DefaultTextStyle(
            style: const TextStyle(
              fontSize: 30.0,
            ),
            child: AnimatedTextKit(
              totalRepeatCount: 3,
              repeatForever: false,
              animatedTexts: [
                TypewriterAnimatedText('Hello $name',
                    textStyle: TextStyle(
                        fontFamily: "Cairo", fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0),
      body: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: constants.bgColor,
        ),
        child: Text('hello'),
      ),
    );
  }
}
