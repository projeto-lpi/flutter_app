// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:healthier_app/src/utils/jwt.dart';
import 'package:pie_chart/pie_chart.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:convert';
import '../main.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:pedometer/pedometer.dart';
import 'package:health/health.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

enum AppState {
  DATA_NOT_FETCHED,
  FETCHING_DATA,
  DATA_READY,
  NO_DATA,
  AUTH_NOT_GRANTED,
  DATA_ADDED,
  DATA_NOT_ADDED,
  STEPS_READY,
}

class _HomePageState extends State<HomePage> {
  late String name = "";
  double steps = 1204;
  double goalSteps = 6000;
  double caloriesCurrent = 635;
  double caloriesGoal = 1400;
  Map<String, double> stepsMap = Map();
  Map<String, double> caloriesMap = Map();
  List<HealthDataPoint> _healthDataList = [];
  AppState _state = AppState.DATA_NOT_FETCHED;
  int _nofSteps = 10;
  double _mgdl = 10.0;

  // create a HealthFactory for use in the app
  HealthFactory health = HealthFactory();

  /// Fetch data points from the health plugin and show them in the app.
  Future fetchData() async {
    setState(() => _state = AppState.FETCHING_DATA);

    // define the types to get
    final types = [
      HealthDataType.STEPS,
      HealthDataType.WEIGHT,
      HealthDataType.HEIGHT,
      HealthDataType.BLOOD_GLUCOSE,
      // Uncomment this line on iOS - only available on iOS
      // HealthDataType.DISTANCE_WALKING_RUNNING,
    ];

    // with coresponsing permissions
    final permissions = [
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
    ];

    // get data within the last 24 hours
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(days: 1));

    // requesting access to the data types before reading them
    // note that strictly speaking, the [permissions] are not
    // needed, since we only want READ access.
    bool requested =
        await health.requestAuthorization(types, permissions: permissions);

    if (requested) {
      try {
        // fetch health data
        List<HealthDataPoint> healthData =
            await health.getHealthDataFromTypes(yesterday, now, types);

        // save all the new data points (only the first 100)
        _healthDataList.addAll((healthData.length < 100)
            ? healthData
            : healthData.sublist(0, 100));
      } catch (error) {
        print("Exception in getHealthDataFromTypes: $error");
      }

      // filter out duplicates
      _healthDataList = HealthFactory.removeDuplicates(_healthDataList);

      // print the results
      _healthDataList.forEach((x) => print(x));

      // update the UI to display the results
      setState(() {
        _state =
            _healthDataList.isEmpty ? AppState.NO_DATA : AppState.DATA_READY;
      });
    } else {
      print("Authorization not granted");
      setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }

  /// Add some random health data.
  Future addData() async {
    final now = DateTime.now();
    final earlier = now.subtract(Duration(minutes: 5));

    _nofSteps = Random().nextInt(10);
    final types = [HealthDataType.STEPS, HealthDataType.BLOOD_GLUCOSE];
    final rights = [HealthDataAccess.WRITE, HealthDataAccess.WRITE];
    final permissions = [
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE
    ];
    bool? hasPermissions =
        await HealthFactory.hasPermissions(types, permissions: rights);
    if (hasPermissions == false) {
      await health.requestAuthorization(types, permissions: permissions);
    }

    _mgdl = Random().nextInt(10) * 1.0;
    bool success = await health.writeHealthData(
        _nofSteps.toDouble(), HealthDataType.STEPS, earlier, now);

    if (success) {
      success = await health.writeHealthData(
          _mgdl, HealthDataType.BLOOD_GLUCOSE, now, now);
    }

    setState(() {
      _state = success ? AppState.DATA_ADDED : AppState.DATA_NOT_ADDED;
    });
  }

  /// Fetch steps from the health plugin and show them in the app.
  Future fetchStepData() async {
    int? steps;

    // get steps for today (i.e., since midnight)
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    bool requested = await health.requestAuthorization([HealthDataType.STEPS]);

    if (requested) {
      try {
        steps = await health.getTotalStepsInInterval(midnight, now);
      } catch (error) {
        print("Caught exception in getTotalStepsInInterval: $error");
      }

      print('Total number of steps: $steps');

      setState(() {
        _nofSteps = (steps == null) ? 0 : steps;
        _state = (steps == null) ? AppState.NO_DATA : AppState.STEPS_READY;
      });
    } else {
      print("Authorization not granted");
      setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }

  Widget _contentFetchingData() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(
              strokeWidth: 10,
            )),
        Text('Fetching data...')
      ],
    );
  }

  Widget _contentDataReady() {
    return ListView.builder(
        itemCount: _healthDataList.length,
        itemBuilder: (_, index) {
          HealthDataPoint p = _healthDataList[index];
          return ListTile(
            title: Text("${p.typeString}: ${p.value}"),
            trailing: Text('${p.unitString}'),
            subtitle: Text('${p.dateFrom} - ${p.dateTo}'),
          );
        });
  }

  Widget _contentNoData() {
    return Text('No Data to show');
  }

  Widget _contentNotFetched() {
    return Column(
      children: [
        Text('Press the download button to fetch data.'),
        Text('Press the plus button to insert some random data.'),
        Text('Press the walking button to get total step count.'),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget _authorizationNotGranted() {
    return Text('Authorization not given. '
        'For Android please check your OAUTH2 client ID is correct in Google Developer Console. '
        'For iOS check your permissions in Apple Health.');
  }

  Widget _dataAdded() {
    return Text('$_nofSteps steps and $_mgdl mgdl are inserted successfully!');
  }

  Widget _stepsFetched() {
    return Text('Total number of steps: $_nofSteps');
  }

  Widget _dataNotAdded() {
    return Text('Failed to add data');
  }

  Widget _content() {
    if (_state == AppState.DATA_READY)
      return _contentDataReady();
    else if (_state == AppState.NO_DATA)
      return _contentNoData();
    else if (_state == AppState.FETCHING_DATA)
      return _contentFetchingData();
    else if (_state == AppState.AUTH_NOT_GRANTED)
      return _authorizationNotGranted();
    else if (_state == AppState.DATA_ADDED)
      return _dataAdded();
    else if (_state == AppState.STEPS_READY)
      return _stepsFetched();
    else if (_state == AppState.DATA_NOT_ADDED) return _dataNotAdded();

    return _contentNotFetched();
  }

  @override
  void initState() {
    stepsMap.addEntries(
        <String, double>{"Steps": steps, "GoalSteps": goalSteps}.entries);
    caloriesMap.addEntries(<String, double>{
      "current": caloriesCurrent,
      "goal": caloriesGoal
    }.entries);
    fetchStepData();
    getUsername();
    super.initState();
  }

  getUsername() async {
    var jwt = await storage.read(key: "jwt");
    var results = parseJwtPayLoad(jwt!);
    setState(() {
      name = results["name"];
      print(name);
      print("hello");
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
            title: DefaultTextStyle(
              style: const TextStyle(
                fontSize: 30.0,
              ),
              child: AnimatedTextKit(
                totalRepeatCount: 3,
                repeatForever: false,
                animatedTexts: [
                  TypewriterAnimatedText('Hello $name',
                      textStyle: TextStyle(
                          fontFamily: "Cairo", fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0),
        body: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/background_gradient.webp'),
                fit: BoxFit.cover),
          ),
          child: GridView.count(
            crossAxisCount: 2,
            children: [
              Card(
                margin: EdgeInsets.only(top: 65, left: 35, right: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                elevation: 10,
                child: PieChart(
                  chartRadius: 80,
                  dataMap: stepsMap,
                  chartType: ChartType.ring,
                  ringStrokeWidth: 10,
                  centerText: 'Steps\n${_nofSteps}/${goalSteps.toInt()}',
                  centerTextStyle: TextStyle(
                      fontSize: 11,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                  chartValuesOptions: ChartValuesOptions(
                      showChartValues: false, showChartValueBackground: false),
                  legendOptions: LegendOptions(
                    showLegends: false,
                  ),
                  colorList: [Colors.red, Colors.black26],
                  initialAngleInDegree: 180,
                  degreeOptions: DegreeOptions(initialAngle: 0),
                ),
              ),
              Card(
                margin: EdgeInsets.only(top: 65, left: 20, right: 35),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                elevation: 10,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Icon(
                        Icons.monitor_heart_rounded,
                        color: Colors.red[900],
                        size: 40,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        '87 bpm',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      ),
                    )
                  ],
                ),
              ),
              Card(
                margin: EdgeInsets.only(top: 65, left: 35, right: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                elevation: 10,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Icon(
                        Icons.water_drop_rounded,
                        color: Colors.blue[900],
                        size: 40,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        '0.5 / 2L',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      ),
                    )
                  ],
                ),
              ),
              Card(
                margin: EdgeInsets.only(top: 65, left: 20, right: 35),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                elevation: 10,
                child: PieChart(
                  chartRadius: 80,
                  dataMap: caloriesMap,
                  chartType: ChartType.ring,
                  ringStrokeWidth: 10,
                  centerText:
                      'Calories\n${caloriesCurrent.toInt()}/${caloriesGoal.toInt()} kcal',
                  centerTextStyle: TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                  chartValuesOptions: ChartValuesOptions(
                      showChartValues: false, showChartValueBackground: false),
                  legendOptions: LegendOptions(
                    showLegends: false,
                  ),
                  colorList: [Colors.red, Colors.black26],
                  initialAngleInDegree: 180,
                  degreeOptions: DegreeOptions(initialAngle: 0),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
