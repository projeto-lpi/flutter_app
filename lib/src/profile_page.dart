import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:healthier_app/src/models/users.dart';
import 'package:healthier_app/src/home_page.dart';
import 'package:healthier_app/src/settings_page.dart';
import 'package:healthier_app/src/utils/jwt.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePage createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  late String name = "";

  final picker = ImagePicker();
  File? _image = null;
  bool button = false;
  String picture = "";
  late Uint8List imageBytes = base64Decode(picture);

  @override
  void initState() {
    getUsername();
    this.loadPicture();
    this.buildPicture();
    super.initState();
  }

  getUsername() async {
    var jwt = await storage.read(key: "jwt");
    var results = parseJwtPayLoad(jwt!);
    setState(() {
      name = results["name"];
    });
    return results;
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
          actions: button == true
              ? <Widget>[
                  IconButton(
                    icon: const Icon(Icons.check_outlined),
                    color: Colors.white,
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
                    icon: Icon(Icons.settings, color: Colors.white),
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
                    icon: Icon(Icons.settings, color: Colors.white),
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
          padding: EdgeInsets.only(
            left: 16,
            top: 15,
            right: 16,
          ),
          alignment: Alignment.center,
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/background_gradient.webp'),
                fit: BoxFit.cover),
          ),
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage: _image == null
                          ? (picture != ""
                              ? MemoryImage(imageBytes) as ImageProvider
                              : AssetImage('assets/images/foto.jpg'))
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
                          child:
                              Icon(Icons.edit, color: Colors.white, size: 20),
                        ),
                        onTap: () {
                          getImage();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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
    picture = (await storage.read(key: 'picture'))!;

    setState(() {});
  }

  buildPicture() {
    if (picture != "" || picture == null) {
      String profileUrl = picture;
      profileUrl = profileUrl.substring(profileUrl.length);
      imageBytes = base64.decode(profileUrl);
    }
  }

  editPicture(String picture) async {
    var jwt = await storage.read(key: "jwt");
    var results = parseJwtPayLoad(jwt!);
    int id = results["UserID"];

    String url = "http://192.168.75.1:8081/api/v1/user/$id";
    var response = await http.patch(Uri.parse(url),
        body: jsonEncode({"picture": picture}));

    if (response.statusCode == 200) {
      await storage.write(key: 'picture', value: picture);
    }
  }
}
