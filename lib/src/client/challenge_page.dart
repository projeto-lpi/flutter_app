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

  TextEditingController _goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAvailableChallenges();
  }

  getAvailableChallenges() async {
    String url = "http://$ip:8081/api/v1/availableChallenges/get";
    var response = await http.get(Uri.parse(url));

    var objJson = jsonDecode(response.body)['challenges'] as List;
    availableChallenges =
        objJson.map((json) => Challenge.fromJson(json)).toList();
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
            gradient: bg_color,
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    child: availableChallenges.length > 0
                        ? GridView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.all(10),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1, mainAxisSpacing: 10),
                            itemBuilder: (context, index) {
                              final challenge = availableChallenges[index];
                              return InkWell(
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Text(challenge.description),
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
                            itemCount: availableChallenges.length,
                          )
                        : Container(),
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
            primary: Colors.white, backgroundColor: Colors.red),
        child: new Text(
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
        primary: Colors.red,
      ),
      child: Text(
        "No",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    return AlertDialog(
      title: Text(
        "Start Challenge",
        textAlign: TextAlign.center,
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
}
