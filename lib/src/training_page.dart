// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:healthier_app/src/models/trainers.dart';
import 'package:healthier_app/src/utils/jwt.dart';
import 'package:http/http.dart' as http;
import '../main.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({Key? key}) : super(key: key);

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  late String user_name = "";
  late String email = "";
  late int user_id = 0;
  late int trainer_id = 0;

  List<Trainer> trainers = [];

  @override
  void initState() {
    super.initState();
    getTrainers();
    getData();
  }

  void getData() async {
    var jwt = await storage.read(key: "jwt");
    var results = parseJwtPayLoad(jwt!);
    setState(() {
      user_name = results["name"];
      user_id = results["UserID"];
      trainer_id = results["trainer_id"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: appBarText(),
          centerTitle: true,
        ),
        body: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/background_gradient.webp'),
                fit: BoxFit.cover),
          ),
          child: drawBody(),
        ),
      ),
    );
  }

  getTrainers() async {
    String url = "http://192.168.75.1:8081/api/v1/trainer";
    var response = await http.get(Uri.parse(url));
    var objJson = jsonDecode(response.body)['data'] as List;
    trainers = objJson.map((json) => Trainer.fromJson(json)).toList();
  }

  Widget drawBody() {
    if (trainer_id == 0) {
      if (trainers.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: PageView.builder(
            itemBuilder: (context, index) {
              final trainer = trainers[index];
              return InkWell(
                child: ListTile(
                  title: Text(trainer.name),
                  subtitle: Text(trainer.email),
                  leading: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/foto.jpg'),
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        _showDialog(trainer, context),
                  );
                },
              );
            },
            itemCount: trainers.length,
          ),
        );
      } else {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    } else {
      return Center(
        child: Text('chat com o pt'),
      );
    }
  }

  Widget _showDialog(Trainer item, context) {
    Widget yesButton = ElevatedButton(
        style: TextButton.styleFrom(
          primary: Colors.red,
        ),
        child: new Text(
          "Yes",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          addTrainer(item.id);
          Navigator.pop(context);
        });

    Widget noButton = ElevatedButton(
      style: TextButton.styleFrom(
        primary: Colors.black,
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
        "Add Trainer",
        textAlign: TextAlign.center,
      ),
      content: Text("Are you sure that you want to add this trainer?",
          textAlign: TextAlign.center),
      actions: <Widget>[
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[yesButton, noButton])
      ],
    );
  }

  void addTrainer(id) async {
    print("user_id do trainer = $id");
    print("user_id do client = $user_id");
    String url2 =
        "http://192.168.75.1:8081/api/v1/client/$user_id/addTrainer/$id";
    var response2 = await http.patch(Uri.parse(url2));
    if (response2.statusCode == 200) {
      print("add trainer ok");
    }
  }

  Widget appBarText() {
    getData();
    if (trainer_id != 0) {
      return Text('chat com pt');
    }
    return Text(
      'Select a Trainer',
      style: TextStyle(fontWeight: FontWeight.w600),
    );
  }
}
