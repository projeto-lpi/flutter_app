import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:healthier_app/src/utils/jwt.dart';
import '../../main.dart';
import '../models/clients.dart';
import '../models/messages.dart';
import '../models/nutricionists.dart';
import '../models/users.dart';
import '../chat_detail.dart';
import '../utils/constants.dart' as constants;

class NutriNutriPage extends StatefulWidget {
  const NutriNutriPage({Key? key}) : super(key: key);

  @override
  State<NutriNutriPage> createState() => _NutriNutriPageState();
}

class _NutriNutriPageState extends State<NutriNutriPage> {
  late String user_name = "";
  late String email = "";
  late int user_id = 0;
  late int nutri_id = 0;
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
    getData();
  }

  getClients() async {
    String url = "http://$ip:8081/api/v1/nutritionist/clients/$user_id";
    var response = await http.get(Uri.parse(url));
    var objJson = jsonDecode(response.body)['clients'] as List;
    clients = objJson.map((json) => Clients.fromJson(json)).toList();
    clients.forEach((element) {
      getClientData(element.user_id, clientsData);
    });
  }

  getClientData(id, usersData) async {
    String url = "http://$ip:8081/api/v1/user/$id";
    var response = await http.get(Uri.parse(url));
    clientsData.add(Users.fromJson(jsonDecode(response.body)['user_data']));
  }

  void getData() async {
    var jwt = await storage.read(key: "jwt");
    var results = parseJwtPayLoad(jwt!);
    user_name = results["name"];
    user_id = results["UserID"];
    setState(() {});
  }

  getTrainerPicture(String picture) {
    imgBytes = base64Decode(picture);
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
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Clients",
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            ListView.builder(
              itemCount: clients.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 16),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final client = clients[index];

                var user = clientsData
                    .firstWhere((element) => element.id == client.user_id);

                getTrainerPicture(user.picture);
                return GestureDetector(
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
                                    : MemoryImage(imgBytes) as ImageProvider,
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
            )
          ],
        ),
      ),
    );
  }

  getNutris() async {
    String url = "http://$ip:8081/api/v1/nutritionist";
    var response = await http.get(Uri.parse(url));
    var objJson = jsonDecode(response.body)['data'] as List;
    clients = objJson.map((json) => Clients.fromJson(json)).toList();
  }

  getNutriPicture(String picture) {
    imgBytes = base64Decode(picture);
  }

  Widget _showDialog(Nutritionists item, context) {
    Widget yesButton = TextButton(
        style: TextButton.styleFrom(
            primary: Colors.white, backgroundColor: Colors.red),
        child: new Text(
          "Yes",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          addNutri(item.id);
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

  void addNutri(id) async {
    print("user_id do nutri = $id");
    print("user_id do client = $user_id");
    String url2 = "http://$ip:8081/api/v1/client/$user_id/addNutri/$id";
    var response2 = await http.patch(Uri.parse(url2));
    if (response2.statusCode == 200) {
      print("add nutri ok");
    }
  }

  Widget appBarText() {
    getData();
    if (nutri_id != 0) {
      return Text('chat com nutri');
    }
    return Text(
      'Select a Nutritionist',
      style: TextStyle(fontWeight: FontWeight.w600),
    );
  }
}
