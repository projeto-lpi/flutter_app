// ignore_for_file: avoid_print, prefer_const_constructors, prefer_const_constructors_in_immutables, body_might_complete_normally_nullable

import 'dart:convert';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:healthier_app/src/client/client_home_page.dart';
import 'package:healthier_app/src/models/challenges.dart';
import 'package:healthier_app/src/utils/constants.dart';
import 'package:http/http.dart' as http;

class ChallengesPage extends StatefulWidget {
  ChallengesPage({Key? key}) : super(key: key);

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  String ip = IP;
  List<Challenge> availableChallenges = [];
  List<Challenge> activeChallenges = [];
  List<Challenge> allChallenges = [];
  List<Challenge> completedChallenges = [];

  final TextEditingController _goalController = TextEditingController();

  @override
  void initState() {
    super.initState();

    getActiveChallenges();
    getAllChallenges();
    getCompleted();
  }

  getCompleted() async {
    String url = "http://$ip:8081/api/v1/challenge/completed/$user_id";
    var response = await http.get(Uri.parse(url));

    if (response.body.isNotEmpty) {
      var objJson = jsonDecode(response.body)['challenges'] as List;
      completedChallenges =
          objJson.map((json) => Challenge.fromJson(json)).toList();
    }
  }

  getAllChallenges() async {
    String url = "http://$ip:8081/api/v1/availableChallenges/get";
    var response = await http.get(Uri.parse(url));
    if (response.body.isNotEmpty) {
      var objJson = jsonDecode(response.body)['challenges'] as List;
      allChallenges = objJson.map((json) => Challenge.fromJson(json)).toList();
    }
  }

  getActiveChallenges() async {
    String url = "http://$ip:8081/api/v1/challenge/getChallenges/$user_id";
    var response = await http.get(Uri.parse(url));
    if (response.body.isNotEmpty) {
      var objJson = jsonDecode(response.body)['challenges'] as List;
      activeChallenges =
          objJson.map((json) => Challenge.fromJson(json)).toList();
      activeChallenges.removeWhere((element) => element.value >= element.goal);
    }
  }

  addChallenge(description, goal, value) async {
    print('description: $description goal: $goal value: $value');
    String url = "http://$ip:8081/api/v1/challenge/addChallenge";
    var response = await http.post(Uri.parse(url),
        body: jsonEncode({
          "description": description,
          "goal": goal,
          "value": value,
          "user_id": user_id
        }));
    if (response.statusCode == 200) {
      print("add challenge ok");
      return CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        text: "Challenge Started!",
      );
    } else if (response.statusCode == 302) {
      return CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: "You've already started this challenge...",
      );
    } else {
      print("add challenge not ok");
      return CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: "Sorry! Something went wrong...",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    getActiveChallenges();
    getAllChallenges();
    getCompleted();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Challenges',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: bgColor,
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'All Challenges',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      )),
                ),
                Divider(
                  height: 5,
                  color: Colors.white,
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    child: allChallenges.isNotEmpty
                        ? GridView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.all(10),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1, mainAxisSpacing: 10),
                            itemBuilder: (context, index) {
                              final challenge = allChallenges[index];

                              return InkWell(
                                child: CircleAvatar(
                                  backgroundColor: buttonColor,
                                  child: Text(
                                    challenge.description,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: textColor),
                                  ),
                                  radius: 20,
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        _showDialog(challenge, context),
                                  );
                                },
                              );
                            },
                            itemCount: allChallenges.length,
                          )
                        : Center(
                            child: Text(
                                'You\'ve already started all available challenges!'),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Active Challenges',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      )),
                ),
                Divider(
                  height: 5,
                  color: Colors.white,
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    child: activeChallenges.isNotEmpty
                        ? GridView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.all(10),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1, mainAxisSpacing: 10),
                            itemBuilder: (context, index) {
                              final challenge = activeChallenges[index];
                              return InkWell(
                                child: CircleAvatar(
                                  backgroundColor: bottomBarColor,
                                  child: Text(
                                    '${challenge.description}\n${((challenge.value / challenge.goal) * 100).toStringAsFixed(2)}%',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: textColor),
                                  ),
                                  radius: 20,
                                ),
                                onTap: () {},
                              );
                            },
                            itemCount: activeChallenges.length,
                          )
                        : Center(
                            child: Text(
                                'You\'ve already completed all active challenges or didn\'t start one yet!',
                                textAlign: TextAlign.center),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Completed Challenges',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      )),
                ),
                Divider(
                  height: 5,
                  color: Colors.white,
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    child: completedChallenges.isNotEmpty
                        ? GridView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.all(10),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1, mainAxisSpacing: 10),
                            itemBuilder: (context, index) {
                              final challenge = completedChallenges[index];

                              return InkWell(
                                child: CircleAvatar(
                                  backgroundColor: iconColor,
                                  child: Text(
                                    '${challenge.description}\nCompleted',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  radius: 20,
                                ),
                                onTap: () {},
                              );
                            },
                            itemCount: completedChallenges.length,
                          )
                        : Center(
                            child: Text(
                                'You haven\'t completed any challenges yet!'),
                          ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Widget _showDialog(Challenge item, context) {
    Widget yesButton = TextButton(
        style: TextButton.styleFrom(
            primary: Colors.white, backgroundColor: bgColor),
        child: const Text(
          "Yes",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          setState(() {
            item.goal = int.parse(_goalController.text.toString());
            addChallenge(item.description, item.goal, item.value);
          });
          Navigator.pop(context);
          _goalController.clear();
        });

    Widget noButton = TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        primary: bgColor,
      ),
      child: Text(
        "No",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    return AlertDialog(
      title: Text(
        "Start ${item.description} Challenge",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black),
      ),
      content: TextFormField(
          controller: _goalController,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Enter your goal',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
          }),
      actions: <Widget>[
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[yesButton, noButton])
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _goalController.dispose();
  }
}
