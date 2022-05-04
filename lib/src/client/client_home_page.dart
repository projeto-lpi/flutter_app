// ignore_for_file: prefer_const_constructors

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:healthier_app/src/client/running_page.dart';
import 'package:healthier_app/src/utils/jwt.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:healthier_app/src/login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:convert';
import 'package:healthier_app/main.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:math';
import 'package:healthier_app/src/utils/constants.dart' as constants;
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:health/health.dart';


class ClientHomePage extends StatefulWidget {
  ClientHomePage({Key? key}) : super(key: key);

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
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
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;

  String _status = '?';
  int _steps = 0;


  @override
  void initState() {
    super.initState();
    caloriesMap.addEntries(<String, double>{
      "current": caloriesCurrent,
      "goal": caloriesGoal
    }.entries);

    getUsername();
    initPlatformState();
  }

  String formatDate(DateTime d) {
    return d.toString().substring(0, 19);
  }

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps;
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 999999;
    });
  }

  Future<void> initPlatformState() async {
    if (await Permission.activityRecognition
        .request()
        .isGranted) {
      _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
      _pedestrianStatusStream
          .listen(onPedestrianStatusChanged)
          .onError(onPedestrianStatusError);

      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream.listen(onStepCount).onError(onStepCountError);
    } else {}
    if (!mounted) return;
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
    stepsMap.addEntries(<String, double>{
      "Steps": _steps.toDouble(),
      "GoalSteps": goalSteps
    }.entries);
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
        height: MediaQuery
            .of(context)
            .size
            .height,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/background_gradient.webp'),
              fit: BoxFit.cover),
        ),
        child: Stack(children: [
          GridView.count(
            crossAxisCount: 2,
            children: [
              Card(
                margin: EdgeInsets.only(top: 65, left: 35, right: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                elevation: 10,
                child: PieChart(
                  animationDuration: Duration(milliseconds: 500),
                  chartRadius: 80,
                  dataMap: stepsMap,
                  chartType: ChartType.ring,
                  ringStrokeWidth: 10,
                  centerText: 'Steps\n$_steps/${goalSteps.toInt()}',
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
                  'Calories\n${caloriesCurrent.toInt()}/${caloriesGoal
                      .toInt()} kcal',
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
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25)),
                  color: Colors.transparent),
              child: Center(
                child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RunningPage()));
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        fixedSize: Size(75, 75)),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.redAccent,
                      size: 45,
                    )),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
