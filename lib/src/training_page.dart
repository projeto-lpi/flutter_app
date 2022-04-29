// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new

import 'dart:convert';
import 'dart:typed_data';

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

  late Uint8List imgBytes;

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
    user_name = results["name"];
    user_id = results["UserID"];
    trainer_id = results["trainer_id"];
    setState(() {});
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
    String url = "http://18.170.87.131:8081/api/v1/trainer";
    var response = await http.get(Uri.parse(url));
    var objJson = jsonDecode(response.body)['data'] as List;
    trainers = objJson.map((json) => Trainer.fromJson(json)).toList();
  }

  Widget drawBody() {
    if (trainer_id == 0) {
      if (trainers.isNotEmpty) {
        return Container(
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height * 0.6,
          width: MediaQuery.of(context).size.width,
          child: PageView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final trainer = trainers[index];
              getTrainerPicture(trainer.picture);
              return Padding(
                padding: const EdgeInsets.all(15.0),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 150,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: CircleAvatar(
                              radius: 50,
                              backgroundImage: trainer.picture == ""
                                  ? NetworkImage(
                                          'https://digimedia.web.ua.pt/wp-content/uploads/2017/05/default-user-image.png')
                                      as ImageProvider
                                  : MemoryImage(imgBytes) as ImageProvider),
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        trainer.name,
                        style: TextStyle(fontSize: 25.0, color: Colors.red),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        trainer.email,
                        style: TextStyle(fontSize: 15.0, color: Colors.red),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
                          elevation: 5,
                          primary: Colors.white,
                        ),
                        label: Text('Add Trainer'),
                        icon: Icon(Icons.add),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                _showDialog(trainer, context),
                          );
                        },
                      )
                    ],
                  ),
                ),
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

  getTrainerPicture(String picture) {
    imgBytes = base64Decode(picture);
  }

  Widget _showDialog(Trainer item, context) {
    Widget yesButton = TextButton(
        style: TextButton.styleFrom(
            primary: Colors.white, backgroundColor: Colors.red),
        child: new Text(
          "Yes",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          addTrainer(item.id);
          Navigator.pop(context);
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
        "http://18.170.87.131:8081/api/v1/client/$user_id/addTrainer/$id";
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
