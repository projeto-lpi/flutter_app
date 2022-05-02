// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:healthier_app/src/utils/jwt.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:healthier_app/src/login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:convert';
import 'package:healthier_app/main.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:math';
import 'package:healthier_app/src/utils/constants.dart' as constants;

class TrainerHomePage extends StatefulWidget {
  TrainerHomePage({Key? key}) : super(key: key);

  @override
  State<TrainerHomePage> createState() => _TrainerHomePageState();
}



class _TrainerHomePageState extends State<TrainerHomePage> {
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
          image: DecorationImage(
              image: AssetImage('assets/images/background_gradient.webp'),
              fit: BoxFit.cover),
        ),
        child: Text('hello'),
      ),
    );
  }
}
