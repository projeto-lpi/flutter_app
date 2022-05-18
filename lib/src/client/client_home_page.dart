// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:healthier_app/main.dart';
import 'package:healthier_app/src/client/running_page.dart';
import 'package:healthier_app/src/models/challenges.dart';
import 'package:healthier_app/src/utils/constants.dart' as constants;
import 'package:healthier_app/src/utils/jwt.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pie_chart/pie_chart.dart';

late int todaySteps = 0;
late int user_id = 0;
String ip = constants.IP;

class ClientHomePage extends StatefulWidget {
  ClientHomePage({Key? key}) : super(key: key);

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  late String name = "";
  int num = 0;

  double goalSteps = 6000;
  double caloriesCurrent = 635;
  double caloriesGoal = 1400;
  Map<String, double> stepsMap = Map();
  Map<String, double> caloriesMap = Map();
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  Box<int> stepsBox = Hive.box('steps');
  List<Challenge> challenges = [];
  String _status = '?';
  int _steps = 0;
  double water = 0.0;
  LinearGradient bg_color = constants.bg_color;

  @override
  void initState() {
    super.initState();

    getUsername();
    getChallenges();

    initPlatformState();
    AndroidAlarmManager.initialize();
    _saveSteps();

    // Register for events from the background isolate. These messages will
    // always coincide with an alarm firing.
    port.listen((_) async => await _incrementCounter());
  }

  Future<void> _incrementCounter() async {
    developer.log('Increment counter!');

    String url = "http://$ip:8081/api/v1/steps/saveSteps/$user_id";
    var response = await http.post(Uri.parse(url),
        body: convert.jsonEncode({
          "step_count": todaySteps,
          "user_id": user_id,
          "date": Jiffy(DateTime.now()).dayOfYear
        }));

    if (response.statusCode == 200) {
      print('save daily steps ok');
    } else {
      print('save daily steps not ok');
    }

    String get = "http://$ip:8081/api/v1/challenge/$user_id/get/steps";
    var getResponse = await http.get(Uri.parse(get));

    if (getResponse.statusCode == 200) {
      print("get challenge ok");
      var challenge = convert.jsonDecode(getResponse.body);

      String update = "http://$ip:8081/api/v1/challenge/$user_id/update/steps";
      var updateResponse = await http.patch(Uri.parse(update),
          body: convert.jsonEncode(
              {"value": (challenge['challenges']['value'] + todaySteps)}));
      setState(() {});
      if (updateResponse.statusCode == 200) {
        print("update challenge ok");
      }
    }

    // Ensure we've loaded the updated count from the background isolate.
    await prefs?.reload();

    setState(() {
      print('boas');
    });
  }

  // The background
  static SendPort? uiSendPort;

  // The callback for our alarm
  static Future<void> callback() async {
    developer.log('Alarm fired!');

    // This will be null if we're running in the background.
    uiSendPort ??= IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send(null);
  }

  _saveSteps() async {
    await AndroidAlarmManager.periodic(
      const Duration(hours: 24),
      // Ensure we have a unique alarm ID.
      Random().nextInt(pow(2, 31) as int),

      callback,
      exact: true,
      wakeup: true,
      allowWhileIdle: true,
      startAt: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 23, 55),
    );
  }

  String formatDate(DateTime d) {
    return d.toString().substring(0, 19);
  }

  Future<int> onStepCount(StepCount event) async {
    print(event);
    int savedStepsCountKey = 999999;
    int? savedStepsCount = stepsBox.get(savedStepsCountKey, defaultValue: 0);

    int todayDayNo = Jiffy(DateTime.now()).dayOfYear;

    if (event.steps < savedStepsCount!) {
      savedStepsCount = 0;
      stepsBox.put(savedStepsCountKey, savedStepsCount);
    }

    int lastDaySavedKey = 888888;
    int? lastDaySaved = stepsBox.get(lastDaySavedKey, defaultValue: 0);

    if (lastDaySaved! < todayDayNo) {
      lastDaySaved = todayDayNo;
      savedStepsCount = event.steps;
      stepsBox
        ..put(lastDaySavedKey, lastDaySaved)
        ..put(savedStepsCountKey, savedStepsCount);
    }

    setState(() {
      todaySteps = event.steps - savedStepsCount!;
    });
    stepsBox.put(todayDayNo, todaySteps);
    return todaySteps;
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 999999;
    });
  }

  Future<void> initPlatformState() async {
    if (await Permission.activityRecognition.request().isGranted) {
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
      user_id = results["UserID"];
      print(name);
      print("hello");
    });
    return results;
  }

  Future<List<Challenge>> getChallenges() async {
    String url = "http://$ip:8081/api/v1/challenge/getChallenges/$user_id";
    var response = await http.get(Uri.parse(url));

    var objJson = jsonDecode(response.body)['challenges'] as List;
    challenges = objJson.map((json) => Challenge.fromJson(json)).toList();
    return challenges;
  }

  updateWater(int water) async {
    String url = "http://$ip:8081/api/v1/challenge/$user_id/get/water";
    var getResponse = await http.get(Uri.parse(url));

    if (getResponse.statusCode == 200) {
      print(getResponse.body.toString());

      var waterValue =
          convert.jsonDecode(getResponse.body)['challenges']['value'];

      var newWater = waterValue + water;
      String url2 = "http://$ip:8081/api/v1/challenge/$user_id/update/water";
      var updateResponse = await http.patch(Uri.parse(url2),
          body: convert.jsonEncode({"value": newWater}));
      setState(() {});
      if (updateResponse.statusCode == 200) {
        print('update water ok');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getChallenges(),
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          stepsMap.addEntries(<String, double>{
            "Steps": challenges
                .firstWhere((element) => element.description == 'steps')
                .value
                .toDouble(),
            "GoalSteps": challenges
                .firstWhere((element) => element.description == 'steps')
                .goal
                .toDouble()
          }.entries);
          caloriesMap.addEntries(<String, double>{
            "Cals": challenges
                .firstWhere((element) => element.description == 'calories')
                .value
                .toDouble(),
            "GoalCals": challenges
                .firstWhere((element) => element.description == 'calories')
                .goal
                .toDouble()
          }.entries);
          return snapshot.hasData
              ? Scaffold(
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
                                    fontFamily: "Cairo",
                                    fontWeight: FontWeight.bold)),
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
                      gradient: bg_color,
                    ),
                    child: Stack(children: [
                      GridView.count(
                        crossAxisCount: 2,
                        children: [
                          Card(
                            margin:
                                EdgeInsets.only(top: 65, left: 35, right: 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40)),
                            elevation: 10,
                            child: PieChart(
                              animationDuration: Duration(milliseconds: 500),
                              chartRadius: 80,
                              dataMap: stepsMap,
                              chartType: ChartType.ring,
                              ringStrokeWidth: 10,
                              centerText:
                                  'Steps\n${challenges.firstWhere((element) => element.description == 'steps').value}/${challenges.firstWhere((element) => element.description == 'steps').goal}',
                              centerTextStyle: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              chartValuesOptions: ChartValuesOptions(
                                  showChartValues: false,
                                  showChartValueBackground: false),
                              legendOptions: LegendOptions(
                                showLegends: false,
                              ),
                              colorList: [Colors.red, Colors.black26],
                              initialAngleInDegree: 180,
                              degreeOptions: DegreeOptions(initialAngle: 0),
                            ),
                          ),
                          Card(
                            margin:
                                EdgeInsets.only(top: 65, left: 20, right: 35),
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
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    _showDialog(context),
                              );
                            },
                            child: Card(
                              margin:
                                  EdgeInsets.only(top: 65, left: 35, right: 20),
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
                                      '${challenges.firstWhere((element) => element.description == 'water').value}/${challenges.firstWhere((element) => element.description == 'water').goal}mL',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Card(
                            margin:
                                EdgeInsets.only(top: 65, left: 20, right: 35),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40)),
                            elevation: 10,
                            child: PieChart(
                              chartRadius: 80,
                              dataMap: caloriesMap,
                              chartType: ChartType.ring,
                              ringStrokeWidth: 10,
                              centerText:
                                  'Calories\n${challenges.firstWhere((element) => element.description == 'calories').value}/${challenges.firstWhere((element) => element.description == 'calories').goal} kcal',
                              centerTextStyle: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              chartValuesOptions: ChartValuesOptions(
                                  showChartValues: false,
                                  showChartValueBackground: false),
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
                                        borderRadius:
                                            BorderRadius.circular(50)),
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
                )
              : Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
        });
  }

  Widget _showDialog(context) {
    Widget yesButton = TextButton(
        style: TextButton.styleFrom(
            primary: Colors.white, backgroundColor: Colors.red),
        child: new Text(
          "Drink!",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          updateWater(num);
          setState(() {});
          Navigator.of(context).pop();
          num = 0;
        });

    Widget noButton = TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        primary: Colors.red,
      ),
      child: Text(
        "Cancel",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        num = 0;
      },
    );

    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25))),
        content: Container(
          height: 255,
          width: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                            'https://i.pinimg.com/originals/79/c7/ff/79c7ff9d622c8fae535a06898f0d6700.gif'))),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                width: 100,
                alignment: Alignment.center,
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5), color: Colors.red),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment
                      .center, //Center Column contents vertically,
                  crossAxisAlignment: CrossAxisAlignment
                      .center, //Center Column contents horizontally,
                  children: [
                    InkWell(
                        onTap: () {
                          print("boas");
                          setState(() {
                            if (num > 0) {
                              num -= 100;
                            }
                          });
                        },
                        child: Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 16,
                        )),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 3),
                      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.white),
                      child: Text(
                        num.toString(),
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                    InkWell(
                        onTap: () {
                          setState(() {
                            num += 100;
                          });
                        },
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[yesButton, noButton])
        ],
      );
    });
  }
}
