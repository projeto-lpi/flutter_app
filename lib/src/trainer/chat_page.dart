// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new, non_constant_identifier_names

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:healthier_app/src/models/clients.dart';
import 'package:healthier_app/src/models/messages.dart';
import 'package:healthier_app/src/utils/jwt.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';
import '../chat_detail.dart';
import '../models/users.dart';
import '../utils/constants.dart' as constants;

class TrainerTrainingPage extends StatefulWidget {
  const TrainerTrainingPage({Key? key}) : super(key: key);

  @override
  State<TrainerTrainingPage> createState() => _TrainerTrainingPageState();
}

class _TrainerTrainingPageState extends State<TrainerTrainingPage> {
  late String user_name = "";
  late String email = "";
  late int user_id = 0;
  late int trainer_id = 0;
  String ip = constants.IP;

  late Uint8List imgBytes;
  List<Clients> clients = [];
  List<Users> clientsData = [];

  List<Message> senderMessages = [];
  List<Message> receiverMessages = [];
  List<Message> allMessages = [];

  int flag = 1;

  @override
  void initState() {
    super.initState();
    getClients();
    getData();
  }

  void getData() async {
    var jwt = await storage.read(key: "jwt");
    var results = parseJwtPayLoad(jwt!);
    user_name = results["name"];
    user_id = results["UserID"];

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      getClients();
      flag = 0;
    });
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Clients",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(top: 125.0),
          child: ListView.builder(
            itemCount: clients.length,
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 16),
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final client = clients[index];

              var user = clientsData
                  .firstWhere((element) => element.id == client.user_id);

              getTrainerPicture(user.picture);
              return clients.isEmpty == true
                  ? Center(
                      child: Text('No clients available'),
                    )
                  : GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ChatDetailPage(
                              client_name: user.name,
                              client_email: user.email,
                              client_id: user.id,
                              client_picture: user.picture,
                              worker_id: user_id);
                        }));
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                            left: 16, right: 16, top: 10, bottom: 10),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Row(
                                children: <Widget>[
                                  CircleAvatar(
                                    backgroundImage: user.picture == ""
                                        ? NetworkImage(
                                            'https://digimedia.web.ua.pt/wp-content/uploads/2017/05/default-user-image.png')
                                        : MemoryImage(imgBytes)
                                            as ImageProvider,
                                    maxRadius: 30,
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Expanded(
                                    child: Container(
                                      color: Colors.transparent,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            user.name,
                                            style: TextStyle(fontSize: 23),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }

  getClients() async {
    String url = "http://$ip:8081/api/v1/trainer/clients/$user_id";
    var response = await http.get(Uri.parse(url));
    var objJson = jsonDecode(response.body)['clients'] as List;
    clients = objJson.map((json) => Clients.fromJson(json)).toList();
    for (var element in clients) {
      getClientData(element.user_id, clientsData);
    }
  }

  getClientData(id, usersData) async {
    String url = "http://$ip:8081/api/v1/user/$id";
    var response = await http.get(Uri.parse(url));
    clientsData.add(Users.fromJson(jsonDecode(response.body)['user_data']));
  }

  getTrainerPicture(String picture) {
    imgBytes = base64Decode(picture);
  }
}
/**
 * DETAIL PAGE ****************************************************************
 */
