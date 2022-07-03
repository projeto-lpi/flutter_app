// ignore_for_file: non_constant_identifier_names, prefer_const_constructors, avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:healthier_app/src/settings_page.dart';
import 'package:healthier_app/src/utils/jwt.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import './utils/constants.dart' as constants;
import '../main.dart';
import 'models/steps.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePage createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  late String name = "";
  late int user_id = 0;
  String ip = constants.IP;
  final picker = ImagePicker();
  File? _image;
  bool button = false;
  String picture = "";
  late Uint8List imageBytes = base64Decode(picture);
  List<Steps> steps = [];
  int flag = 1;

  @override
  void initState() {
    super.initState();
    getUsername();
    loadPicture();
    buildPicture();
  }

  getUsername() async {
    var jwt = await storage.read(key: "jwt");
    var results = parseJwtPayLoad(jwt!);
    setState(() {
      name = results["name"];
      user_id = results["UserID"];
    });
    return results;
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
        actions: button == true
            ? <Widget>[
                IconButton(
                  icon: const Icon(Icons.check_outlined),
                  color: constants.buttonColor,
                  tooltip: 'Save changes',
                  onPressed: () async {
                    List<int> imgBytes = await _image!.readAsBytes();
                    String base64img = base64Encode(imgBytes);
                    await editPicture(base64img);
                    setState(() {
                      button = false;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings, color: constants.buttonColor),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsPage()));
                  },
                ),
              ]
            : <Widget>[
                IconButton(
                  icon: Icon(Icons.settings, color: constants.buttonColor),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsPage()));
                  },
                ),
              ],
      ),
      body: Container(
        alignment: Alignment.topCenter,
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: constants.bgColor,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Stack(children: [
                CircleAvatar(
                  backgroundImage: _image == null
                      ? (picture != ""
                          ? MemoryImage(imageBytes) as ImageProvider
                          : AssetImage('assets/images/default-user-image.png'))
                      : FileImage(File(_image!.path)),
                  radius: 50,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 75.0, left: 75),
                  child: InkWell(
                    child: Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                    onTap: () {
                      getImage();
                    },
                  ),
                ),
              ]),
              Text(
                name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, preferredCameraDevice: CameraDevice.front);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        button = true;
        print(_image!.path);
      } else {
        print('No image selected.');
      }
    });
  }

  loadPicture() async {
    var jwt = await storage.read(key: 'jwt');
    var results = parseJwtPayLoad(jwt!);
    picture = results["picture"];

    setState(() {});
  }

  buildPicture() {
    if (picture != "") {
      String profileUrl = picture;
      profileUrl = profileUrl.substring(profileUrl.length);
      imageBytes = base64.decode(profileUrl);
    }
  }

  editPicture(String picture) async {
    var jwt = await storage.read(key: "jwt");
    var results = parseJwtPayLoad(jwt!);
    int id = results["UserID"];

    String url = "http://$ip:8081/api/v1/user/$id";
    var response = await http.patch(Uri.parse(url),
        body: jsonEncode({"picture": picture}));

    if (response.statusCode == 200) {
      return CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        text: "Your picture as been successfully updated!",
      );
    }
  }
}
