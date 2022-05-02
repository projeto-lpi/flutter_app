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

class ClientHomePage extends StatefulWidget {
  ClientHomePage({Key? key}) : super(key: key);

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

enum AppState {
  DATA_NOT_FETCHED,
  FETCHING_DATA,
  DATA_READY,
  NO_DATA,
  AUTH_NOT_GRANTED,
  DATA_ADDED,
  DATA_NOT_ADDED,
  STEPS_READY,
}

class _ClientHomePageState extends State<ClientHomePage> {
  late String name = "";
  String ip = constants.IP;
  double steps = 1204;
  double goalSteps = 6000;
  double caloriesCurrent = 635;
  double caloriesGoal = 1400;
  Map<String, double> stepsMap = Map();
  Map<String, double> caloriesMap = Map();
  AppState _state = AppState.DATA_NOT_FETCHED;
  int _nofSteps = 10;
  double _mgdl = 10.0;

  @override
  void initState() {
    stepsMap.addEntries(
        <String, double>{"Steps": steps, "GoalSteps": goalSteps}.entries);
    caloriesMap.addEntries(<String, double>{
      "current": caloriesCurrent,
      "goal": caloriesGoal
    }.entries);
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
        child: GridView.count(
          crossAxisCount: 2,
          children: [
            Card(
              margin: EdgeInsets.only(top: 65, left: 35, right: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              elevation: 10,
              child: PieChart(
                chartRadius: 80,
                dataMap: stepsMap,
                chartType: ChartType.ring,
                ringStrokeWidth: 10,
                centerText: 'Steps\n${_nofSteps}/${goalSteps.toInt()}',
                centerTextStyle: TextStyle(
                    fontSize: 11,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
                chartValuesOptions: ChartValuesOptions(
                    showChartValues: false, showChartValueBackground: false),
                legendOptions: LegendOptions(
                  showLegends: false,
                ),
                colorList: [Colors.red, Colors.black26],
                initialAngleInDegree: 180,
                degreeOptions: DegreeOptions(initialAngle: 0),
              ),
            ),
            Card(
              margin: EdgeInsets.only(top: 65, left: 20, right: 35),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              elevation: 10,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Icon(
                      Icons.monitor_heart_rounded,
                      color: Colors.red[900],
                      size: 40,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      '87 bpm',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                  )
                ],
              ),
            ),
            Card(
              margin: EdgeInsets.only(top: 65, left: 35, right: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              elevation: 10,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Icon(
                      Icons.water_drop_rounded,
                      color: Colors.blue[900],
                      size: 40,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Text(
                      '0.5 / 2L',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                  )
                ],
              ),
            ),
            Card(
              margin: EdgeInsets.only(top: 65, left: 20, right: 35),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              elevation: 10,
              child: PieChart(
                chartRadius: 80,
                dataMap: caloriesMap,
                chartType: ChartType.ring,
                ringStrokeWidth: 10,
                centerText:
                    'Calories\n${caloriesCurrent.toInt()}/${caloriesGoal.toInt()} kcal',
                centerTextStyle: TextStyle(
                    fontSize: 10,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
                chartValuesOptions: ChartValuesOptions(
                    showChartValues: false, showChartValueBackground: false),
                legendOptions: LegendOptions(
                  showLegends: false,
                ),
                colorList: [Colors.red, Colors.black26],
                initialAngleInDegree: 180,
                degreeOptions: DegreeOptions(initialAngle: 0),
              ),
            )
          ],
        ),
      ),
    );
  }
}
