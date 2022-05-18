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
  File? _image = null;
  bool button = false;
  String picture = "";
  late Uint8List imageBytes = base64Decode(picture);
  List<Steps> steps = [];
  int flag = 1;
  LinearGradient bg_color = constants.bg_color;

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
    int millisInADay = Duration(days: 1).inMilliseconds; // 86400000
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
        alignment: Alignment.topCenter,
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: bg_color,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Stack(children: [
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
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              Divider(
                height: 5,
                color: Colors.white,
              ),
              Padding(
                padding:
                    const EdgeInsets.only(right: 18.0, left: 18, bottom: 18),
                child: SfCartesianChart(
                    title: ChartTitle(
                        text: 'Steps',
                        textStyle: TextStyle(
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
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
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
