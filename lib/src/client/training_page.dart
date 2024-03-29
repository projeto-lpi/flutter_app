// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new, non_constant_identifier_names, avoid_print

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:healthier_app/src/models/messages.dart';
import 'package:healthier_app/src/models/trainers.dart';
import 'package:healthier_app/src/utils/jwt.dart';
import 'package:http/http.dart' as http;
import '../../main.dart';
import '../utils/constants.dart' as constants;
import 'package:bubble/bubble.dart';

class ClientTrainingPage extends StatefulWidget {
  const ClientTrainingPage({Key? key}) : super(key: key);

  @override
  State<ClientTrainingPage> createState() => _ClientTrainingPageState();
}

class _ClientTrainingPageState extends State<ClientTrainingPage> {
  late String user_name = "";
  late String email = "";
  late int user_id = 0;
  late int trainer_id = 0;
  String ip = constants.IP;

  late Uint8List imgBytes;

  List<Trainer> trainers = [];

  List<Message> senderMessages = [];
  List<Message> receiverMessages = [];
  List<Message> allMessages = [];
  final TextEditingController _messageController = TextEditingController();

  int flag = 1;

  @override
  void initState() {
    super.initState();
    getTrainers();
    getData();
    getMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: constants.buttonColor,
        title: appBarText(),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: constants.bgColor,
        ),
        child: drawBody(),
      ),
    );
  }

  getTrainers() async {
    String url = "http://$ip:8081/api/v1/trainer";
    var response = await http.get(Uri.parse(url));
    var objJson = jsonDecode(response.body)['data'] as List;
    trainers = objJson.map((json) => Trainer.fromJson(json)).toList();
  }

  getMessages() async {
    String url = "http://$ip:8081/api/v1/message/$user_id/$trainer_id";
    var response = await http.get(Uri.parse(url));

    var objJson = jsonDecode(response.body)['senderMessages'] as List;

    var receiverJson = jsonDecode(response.body)['receiverMessages'] as List;

    setState(() {
      senderMessages =
          objJson.map((senderjson) => Message.fromJson(senderjson)).toList();
      receiverMessages = receiverJson
          .map((receiverjson) => Message.fromJson(receiverjson))
          .toList();
    });
  }

  Widget drawBody() {
    if (trainer_id == 0) {
      if (trainers.isEmpty) {
        getTrainers();
      }
      if (trainers.isNotEmpty) {
        return drawTrainers();
      } else {
        return Center(
          child: CircularProgressIndicator(
            color: constants.buttonColor,
          ),
        );
      }
    } else {
      allMessages = senderMessages + receiverMessages;
      allMessages.sort((a, b) => a.id.compareTo(b.id));

      var trainer = trainers.firstWhere((element) => element.id == trainer_id);

      if (flag == 1) {
        getMessages();
        flag = 0;
        getTrainerPicture(trainer.picture);
      }

      return drawChat(trainer);
    }
  }

  Scaffold drawChat(Trainer trainer) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: constants.buttonColor,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 12,
                ),
                CircleAvatar(
                    maxRadius: 20,
                    backgroundImage: trainer.picture == ""
                        ? NetworkImage(
                                'https://digimedia.web.ua.pt/wp-content/uploads/2017/05/default-user-image.png')
                            as ImageProvider
                        : MemoryImage(imgBytes) as ImageProvider),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        trainer.name,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        trainer.email,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.settings,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: ListView.builder(
              itemCount: allMessages.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 10, bottom: 10),
              itemBuilder: (context, index) {
                return allMessages.isEmpty == true
                    ? Center(
                        child: Text('No messages available'),
                      )
                    : Container(
                        padding: EdgeInsets.only(
                            left: 16, right: 16, top: 5, bottom: 5),
                        child: Bubble(
                          margin: BubbleEdges.only(top: 10),
                          alignment: allMessages[index].from_id == user_id
                              ? Alignment.topRight
                              : Alignment.topLeft,
                          nip: allMessages[index].from_id == user_id
                              ? BubbleNip.rightCenter
                              : BubbleNip.leftCenter,
                          color: (allMessages[index].from_id == user_id
                              ? constants.buttonColor
                              : Colors.grey.shade900),
                          child: Text(allMessages[index].content,
                              textAlign: TextAlign.center),
                        ),
                      );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: Container(
                padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: constants.buttonColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                            hintText: "Write message...",
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    FloatingActionButton(
                      heroTag: "sendmsg",
                      onPressed: () {
                        sendMessage();
                        flag = 1;
                        _messageController.clear();
                      },
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                      backgroundColor: constants.buttonColor,
                      elevation: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding drawTrainers() {
    return Padding(
      padding: const EdgeInsets.only(top: 100.0),
      child: Container(
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
                color: constants.buttonColor,
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
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
                      style: TextStyle(
                        fontSize: 25.0,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      trainer.email,
                      style: TextStyle(fontSize: 15.0),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(200, 40),
                        primary: constants.bgColor,
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
      ),
    );
  }

  getTrainerPicture(String picture) {
    imgBytes = base64Decode(picture);
  }

  Widget _showDialog(Trainer item, context) {
    Widget yesButton = TextButton(
        style: TextButton.styleFrom(
            primary: Colors.white, backgroundColor: constants.bgColor),
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
        primary: constants.bgColor,
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
        style: TextStyle(color: Colors.black),
        textAlign: TextAlign.center,
      ),
      content: Text("Are you sure that you want to add this trainer?",
          style: TextStyle(color: Colors.black), textAlign: TextAlign.center),
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
    String url2 = "http://$ip:8081/api/v1/client/$user_id/addTrainer/$id";
    var response2 = await http.patch(Uri.parse(url2));
    if (response2.statusCode == 200) {
      trainer_id = id;
      print("add trainer ok");
      setState(() {
        trainer_id = id;
      });
    }
  }

  void sendMessage() async {
    String url = "http://$ip:8081/api/v1/message/create";

    var response = await http.post(Uri.parse(url),
        body: jsonEncode({
          "from_id": user_id,
          "to_id": trainer_id,
          "content": _messageController.text
        }));
    if (response.statusCode == 200) {
      setState(() {
        getMessages();
      });
      print("send message ok");
    }
  }

  Widget appBarText() {
    getData();
    if (trainer_id != 0) {
      return Text(
        'Chat',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      );
    }
    return Text(
      'Select a Trainer',
      style: TextStyle(fontWeight: FontWeight.w600),
    );
  }
}
