import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:healthier_app/src/models/messages.dart';
import 'package:healthier_app/src/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'utils/constants.dart' as constants;

class ChatDetailPage extends StatefulWidget {
  int client_id;
  String client_name;
  String client_email;
  String client_picture;
  int worker_id;

  ChatDetailPage(
      {Key? key,
      required this.client_id,
      required this.client_name,
      required this.client_email,
      required this.client_picture,
      required this.worker_id})
      : super(key: key);

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  late String trainer_name = "";
  List<Message> senderMessages = [];
  List<Message> receiverMessages = [];
  List<Message> allMessages = [];
  String ip = constants.IP;
  LinearGradient bg_color = constants.bg_color;
  TextEditingController _messageController = TextEditingController();

  int flag = 1;

  late Uint8List imgBytes;

  Widget appBarText() {
    return Text(
      'Chat',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
    );
  }

  getTrainerPicture(String picture) {
    imgBytes = base64Decode(picture);
  }

  @override
  void initState() {
    super.initState();
    getMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          gradient: bg_color,
        ),
        child: drawBody(),
      ),
    );
  }

  void sendMessage() async {
    String url = "http://$ip:8081/api/v1/message/create";

    var response = await http.post(Uri.parse(url),
        body: jsonEncode({
          "from_id": widget.worker_id,
          "to_id": widget.client_id,
          "content": _messageController.text
        }));
    if (response.statusCode == 200) {
      print("send message ok");
    }
  }

  getMessages() async {
    print(widget.worker_id);
    print(widget.client_id);
    String url =
        "http://$ip:8081/api/v1/message/${widget.worker_id}/${widget.client_id}";
    var response = await http.get(Uri.parse(url));

      var objJson = jsonDecode(response.body)['senderMessages'] as List;
      senderMessages =
          objJson.map((senderjson) => Message.fromJson(senderjson)).toList();

      var receiverJson = jsonDecode(response.body)['receiverMessages'] as List;
      receiverMessages = receiverJson
          .map((receiverjson) => Message.fromJson(receiverjson))
          .toList();

    allMessages = senderMessages + receiverMessages;
    allMessages.sort((a, b) => a.id.compareTo(b.id));
  return allMessages;
    }

  Widget drawBody() {


    if (flag == 1) {
      getMessages();
      flag = 0;
    }

    getTrainerPicture(widget.client_picture);
    return FutureBuilder(
        future: getMessages(),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          return snapshot.hasData
              ? Scaffold(
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
                                backgroundImage: widget.client_picture == ""
                                    ? NetworkImage(
                                            'https://digimedia.web.ua.pt/wp-content/uploads/2017/05/default-user-image.png')
                                        as ImageProvider
                                    : MemoryImage(imgBytes) as ImageProvider),
                            SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: ListView(
                                children: <Widget>[
                                  Text(
                                    widget.client_name,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    widget.client_email,
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13),
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
                          key: ValueKey(allMessages.length),
                          itemCount: allMessages.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          itemBuilder: (context, index) {
                            return Container(
                              padding: EdgeInsets.only(
                                  left: 16, right: 16, top: 5, bottom: 5),
                              child: Align(
                                alignment: allMessages[index].from_id ==
                                        widget.worker_id
                                    ? Alignment.topRight
                                    : Alignment.topLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: (allMessages[index].from_id ==
                                              widget.client_id
                                          ? Colors.grey.shade200
                                          : Colors.red[400])),
                                  child: Text(allMessages[index].content),
                                ),
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
                            padding:
                                EdgeInsets.only(left: 10, bottom: 10, top: 10),
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
                                        hintStyle:
                                            TextStyle(color: Colors.black54),
                                        border: InputBorder.none),
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                FloatingActionButton(
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
                )
              : Scaffold(
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
                          backgroundImage: widget.client_picture == ""
                              ? NetworkImage(
                              'https://digimedia.web.ua.pt/wp-content/uploads/2017/05/default-user-image.png')
                          as ImageProvider
                              : MemoryImage(imgBytes) as ImageProvider),
                      SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: ListView(
                          children: <Widget>[
                            Text(
                              widget.client_name,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              widget.client_email,
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13),
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
                    key: ValueKey(allMessages.length),
                    itemCount: allMessages.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.only(
                            left: 16, right: 16, top: 5, bottom: 5),
                        child: Align(
                          alignment: allMessages[index].from_id ==
                              widget.worker_id
                              ? Alignment.topRight
                              : Alignment.topLeft,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: (allMessages[index].from_id ==
                                    widget.client_id
                                    ? Colors.red[400]
                                    : Colors.grey.shade200)),
                            child: Text(allMessages[index].content),
                          ),
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
                      padding:
                      EdgeInsets.only(left: 10, bottom: 10, top: 10),
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
                                  hintStyle:
                                  TextStyle(color: Colors.black54),
                                  border: InputBorder.none),
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          FloatingActionButton(
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
        });
  }
}
