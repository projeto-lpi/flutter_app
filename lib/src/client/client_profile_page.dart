// ignore_for_file: non_constant_identifier_names, avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:healthier_app/src/settings_page.dart';
import 'package:healthier_app/src/utils/jwt.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../main.dart';
import '../models/steps.dart';
import '../utils/constants.dart' as constants;

class ClientProfilePage extends StatefulWidget {
  const ClientProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePage createState() => _ProfilePage();
}

class _ProfilePage extends State<ClientProfilePage> {
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

  DateTime formatDate(dayOfYear) {
    int millisInADay = const Duration(days: 1).inMilliseconds; // 86400000
    int millisDayOfYear = dayOfYear * millisInADay;
    int millisecondsSinceEpoch =
        DateTime(DateTime.now().year).millisecondsSinceEpoch;

    DateTime dayOfYearDate = DateTime.fromMillisecondsSinceEpoch(
        millisecondsSinceEpoch + millisDayOfYear);
    return dayOfYearDate;
  }

  @override
  Widget build(BuildContext context) {
    getHistorySteps();
    steps.sort((a, b) => a.date.compareTo(b.date));
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
                  icon:
                      const Icon(Icons.settings, color: constants.buttonColor),
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
                  icon:
                      const Icon(Icons.settings, color: constants.buttonColor),
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
                          : const AssetImage(
                              'assets/images/default-user-image.png'))
                      : FileImage(File(_image!.path)),
                  radius: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 85.0, left: 85),
                  child: InkWell(
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child:
                          const Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                    onTap: () {
                      getImage();
                    },
                  ),
                ),
              ]),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    right: 18.0, left: 18, bottom: 18, top: 50),
                child: SfCartesianChart(
                    title: ChartTitle(
                        borderColor: constants.buttonColor,
                        text: 'Steps',
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    primaryXAxis: CategoryAxis(),
                    primaryYAxis:
                        NumericAxis(minimum: 0, maximum: 2000, interval: 250),
                    series: <ChartSeries<Steps, String>>[
                      ColumnSeries<Steps, String>(
                          dataSource: steps.length < 5
                              ? steps
                              : steps.sublist(steps.indexOf(steps.last) - 5),
                          xValueMapper: (Steps data, _) =>
                              '${formatDate(data.date).day - 1}/${formatDate(data.date).month}',
                          yValueMapper: (Steps data, _) => data.stepCount,
                          name: 'Gold',
                          color: constants.buttonColor,
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(5),
                              topLeft: Radius.circular(5)))
                    ]),
              )
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

  Future<List<Steps>> getHistorySteps() async {
    String url = "http://$ip:8081/api/v1/steps/getStepsHistory/$user_id";
    var response = await http.get(Uri.parse(url));
    if (response.body.isNotEmpty) {
      var jsonResponse = jsonDecode(response.body)['steps'] as List;
      steps = jsonResponse.map((json) => Steps.fromJson(json)).toList();
    }

    return steps;
  }
}
