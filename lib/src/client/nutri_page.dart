import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:healthier_app/src/utils/jwt.dart';
import '../../main.dart';
import '../models/messages.dart';
import '../models/nutricionists.dart';
import '../utils/constants.dart' as constants;

class ClientNutriPage extends StatefulWidget {
  const ClientNutriPage({Key? key}) : super(key: key);

  @override
  State<ClientNutriPage> createState() => _ClientNutriPageState();
}

class _ClientNutriPageState extends State<ClientNutriPage> {
  late String user_name = "";
  late String email = "";
  late int user_id = 0;
  late int nutri_id = 0;
  String ip = constants.IP;

  late Uint8List imgBytes;

  List<Nutritionists> nutris = [];

  List<Message> senderMessages = [];
  List<Message> receiverMessages = [];
  List<Message> allMessages = [];

  TextEditingController _messageController = TextEditingController();

  int flag=1;

  @override
  void initState() {
    super.initState();
    getNutris();
    getData();
  }

  void getData() async {
    var jwt = await storage.read(key: "jwt");
    var results = parseJwtPayLoad(jwt!);
    user_name = results["name"];
    user_id = results["UserID"];
    nutri_id = results["nutri_id"];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ValueKey(nutri_id),
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
    );
  }

  void sendMessage() async {
    String url = "http://$ip:8081/api/v1/message/create";

    var response = await http.post(Uri.parse(url),
        body: jsonEncode({
          "from_id": user_id,
          "to_id": nutri_id,
          "content": _messageController.text
        }));
    if (response.statusCode == 200) {
      print("send message ok");
    }
  }

  getNutris() async {
    String url = "http://$ip:8081/api/v1/nutritionist";
    var response = await http.get(Uri.parse(url));
    var objJson = jsonDecode(response.body)['data'] as List;
    nutris = objJson.map((json) => Nutritionists.fromJson(json)).toList();
  }

  getMessages() async {
    String url = "http://$ip:8081/api/v1/message/$user_id/$nutri_id";
    var response = await http.get(Uri.parse(url));

    var objJson = jsonDecode(response.body)['senderMessages'] as List;
    senderMessages =
        objJson.map((senderjson) => Message.fromJson(senderjson)).toList();

    var receiverJson = jsonDecode(response.body)['receiverMessages'] as List;
    receiverMessages = receiverJson
        .map((receiverjson) => Message.fromJson(receiverjson))
        .toList();



  }

  Widget drawBody() {

    if (nutri_id == 0) {
      if (nutris.isNotEmpty) {
        return Container(
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height * 0.6,
          width: MediaQuery.of(context).size.width,
          child: PageView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final nutri = nutris[index];
              getNutriPicture(nutri.picture);
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
                              backgroundImage: nutri.picture == ""
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
                        nutri.name,
                        style: TextStyle(fontSize: 25.0, color: Colors.red),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        nutri.email,
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
                                _showDialog(nutri, context),
                          );
                        },
                      )
                    ],
                  ),
                ),
              );
            },
            itemCount: nutris.length,
          ),
        );
      } else {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    } else {
      allMessages = senderMessages + receiverMessages;
      allMessages.sort((a, b) => a.id.compareTo(b.id));
      Nutritionists nutri =
      nutris.firstWhere((element) => element.id == nutri_id);

      if(flag==1){
        getMessages();
        flag=0;
        getNutriPicture(nutri.picture);
      }
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.red,
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
                      backgroundImage: nutri.picture == ""
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
                          nutri.name,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Text(
                          nutri.email,
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
            ListView.builder(
              itemCount: allMessages.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 10, bottom: 10),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  padding:
                  EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
                  child: Align(
                    alignment: allMessages[index].from_id == user_id
                        ? Alignment.topLeft
                        : Alignment.topRight,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: (allMessages[index].from_id == user_id
                              ? Colors.grey.shade200
                              : Colors.red[400])),
                      child: Text(allMessages[index].content),
                    ),
                  ),
                );
              },
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
                            color: Colors.red[400],
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
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      FloatingActionButton(
                        onPressed: () {
                          sendMessage();
                          flag=1;
                          _messageController.clear();
                        },
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                        backgroundColor: Colors.red[400],
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
