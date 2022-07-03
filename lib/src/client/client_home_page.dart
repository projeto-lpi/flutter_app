// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, avoid_print, prefer_const_constructors_in_immutables, sized_box_for_whitespace

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

late int todaySteps = 0;
late int user_id = 0;
String ip = constants.IP;
late Stream<StepCount> _stepCountStream;

class ClientHomePage extends StatefulWidget {
  ClientHomePage({Key? key}) : super(key: key);

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  late String name = "";
  int num = 0;

  Box<int> stepsBox = Hive.box('steps');
  List<Challenge> challenges = [];

  @override
  void initState() {
    super.initState();

    getUsername();
    getChallenges();
    _saveSteps();
    initPlatformState();
  }

  Future<void> callback() async {
    String url = "http://$ip:8081/api/v1/steps/saveSteps/$user_id";
    var response = await http.post(Uri.parse(url),
        body: convert.jsonEncode({
          "step_count": todaySteps,
          "user_id": user_id,
          "date": Jiffy(DateTime.now()).dayOfYear
        }));

    if (response.statusCode == 200) {
      String get = "http://$ip:8081/api/v1/challenge/$user_id/get/steps";
      var getResponse = await http.get(Uri.parse(get));

      if (getResponse.statusCode == 200) {
        print("get challenge ok");
        if (getResponse.body.isNotEmpty) {
          var challenge = convert.jsonDecode(getResponse.body);

          String update =
              "http://$ip:8081/api/v1/challenge/$user_id/update/steps";
          var updateResponse = await http.patch(Uri.parse(update),
              body: convert.jsonEncode(
                  {"value": (challenge['challenges']['value'] + todaySteps)}));
          setState(() {});
          if (updateResponse.statusCode == 200) {
            print("update challenge ok");
          }
        }
      } else {
        print('save/update steps not ok');
      }
    }
    setState(() {});
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
          DateTime.now().day, 23, 00),
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
    setState(() {});
  }

  Future<void> initPlatformState() async {
    if (await Permission.activityRecognition.request().isGranted) {
      _stepCountStream = Pedometer.stepCountStream.asBroadcastStream();
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

    if (response.body.isNotEmpty) {
      var objJson = jsonDecode(response.body)['challenges'] as List;
      challenges = objJson.map((json) => Challenge.fromJson(json)).toList();
    }
    return challenges;
  }

  updateWater(int water) async {
    String url = "http://$ip:8081/api/v1/challenge/$user_id/get/water";
    var getResponse = await http.get(Uri.parse(url));

    if (getResponse.statusCode == 200) {
      print(getResponse.body.toString());

      if (getResponse.body.isNotEmpty) {
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
  }

  updateCals(int cals) async {
    String url = "http://$ip:8081/api/v1/challenge/$user_id/get/calories";
    var getResponse = await http.get(Uri.parse(url));

    if (getResponse.statusCode == 200) {
      print(getResponse.body.toString());

      if (getResponse.body.isNotEmpty) {
        var calsValue =
            convert.jsonDecode(getResponse.body)['challenges']['value'];

        var newCals = calsValue + cals;
        String url2 =
            "http://$ip:8081/api/v1/challenge/$user_id/update/calories";
        var updateResponse = await http.patch(Uri.parse(url2),
            body: convert.jsonEncode({"value": newCals}));
        setState(() {});
        if (updateResponse.statusCode == 200) {
          print('update cals ok');
        }
      }
    }
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
          child: Column(
            children: [
              _challengesGridBuild(),
              _runningButton(context),
            ],
          )),
    );
  }

  Expanded _challengesGridBuild() {
    return Expanded(
      flex: 8,
      child: FutureBuilder(
          future: getChallenges(),
          builder: (context, snapshot) {
            if (snapshot.hasError) print(snapshot.error);
            return snapshot.hasData
                ? GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
                    itemBuilder: (context, index) {
                      final challenge = challenges[index];

                      return challenge.description == 'water'
                          ? InkWell(
                              child: challengeWidget(challenge),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) => _showDialog(
                                      'https://i.pinimg.com/originals/79/c7/ff/79c7ff9d622c8fae535a06898f0d6700.gif',
                                      'Drink',
                                      updateWater,
                                      context),
                                );
                              },
                            )
                          : challenge.description == 'calories'
                              ? InkWell(
                                  child: challengeWidget(challenge),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          _showDialog(
                                              'https://c.tenor.com/H89rnWqDa04AAAAM/happy-birthday-food.gif',
                                              'Eat!',
                                              updateCals,
                                              context),
                                    );
                                  },
                                )
                              : challengeWidget(challenge);
                    },
                    itemCount: challenges.length,
                  )
                : Center(
                    child: Text('Activate challenges so they show up here!'));
          }),
    );
  }

  Expanded _runningButton(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25)),
              color: Colors.transparent),
          child: Center(
            child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => RunningPage()));
                },
                style: ElevatedButton.styleFrom(
                    primary: constants.buttonColor,
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    fixedSize: Size(75, 75)),
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 45,
                )),
          ),
        ),
      ),
    );
  }

  Widget challengeWidget(Challenge challenge) {
    return Card(
      margin: EdgeInsets.only(top: 65, left: 35, right: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      elevation: 10,
      color: constants.buttonColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Icon(
              Icons.emoji_events_rounded,
              color: constants.bgColor,
              size: 40,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: Text(
              challenge.description == 'steps'
                  ? '${challenge.description}\n${todaySteps}/${challenge.goal}'
                  : '${challenge.description}\n${challenge.value}/${challenge.goal}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  Widget _showDialog(gif, text, func, context) {
    Widget yesButton = TextButton(
        style: TextButton.styleFrom(
            primary: Colors.white, backgroundColor: constants.bgColor),
        child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          func(num);
          setState(() {});
          Navigator.of(context).pop();
          num = 0;
        });

    Widget noButton = TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        primary: constants.bgColor,
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
                        fit: BoxFit.cover, image: NetworkImage(gif))),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                width: 100,
                alignment: Alignment.center,
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: constants.bgColor),
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
                          size: 16,
                        )),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 3),
                      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        num.toString(),
                        style: TextStyle(fontSize: 16),
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
