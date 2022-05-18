import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:healthier_app/src/client/client_home_page.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

const double cameraZoom = 20;
const double cameraTilt = 25;
const double cameraBearing = 15;

class RunningPage extends StatefulWidget {
  const RunningPage({Key? key}) : super(key: key);

  @override
  State<RunningPage> createState() => _RunningPageState();
}

class _RunningPageState extends State<RunningPage> {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
  );
  LatLngBounds portugalBounds = LatLngBounds(
    northeast: LatLng(42.07892, -6.75719),
    southwest: LatLng(32.63333, -28.7),
  );
  Completer<GoogleMapController> _controller = Completer();

  late Position _currentPosition;

  late Position _previousPosition;
  late StreamSubscription<Position> _positionStream;
  double _totalDistance = 0;

  int flag = 0;
  List<Position> locations = [];

  @override
  void initState() {
    super.initState();
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position value) => _currentPosition = value);
  }

  Future _calculateDistance() async {
    LocationPermission permission;
    final GoogleMapController controller = await _controller.future;

    permission = await Geolocator.requestPermission();
    _positionStream = Geolocator.getPositionStream(
            locationSettings: LocationSettings(accuracy: LocationAccuracy.high))
        .listen((Position position) async {
      if ((await Geolocator.isLocationServiceEnabled())) {
        Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
            .then((Position position) {
          print(position == null
              ? 'Unknown'
              : position.latitude.toString() +
                  ', ' +
                  position.longitude.toString());

          setState(() {
            _currentPosition = position;
            locations.add(_currentPosition);
            if (_currentPosition != null) {
              CameraPosition cameraPosition = CameraPosition(
                  target: LatLng(
                      _currentPosition.latitude, _currentPosition.longitude),
                  zoom: cameraZoom,
                  tilt: cameraTilt,
                  bearing: cameraBearing);
              controller.animateCamera(
                  CameraUpdate.newCameraPosition(cameraPosition));
            }
            if (locations.length > 1) {
              _previousPosition = locations.elementAt(locations.length - 2);

              var _distanceBetweenLastTwoLocations = Geolocator.distanceBetween(
                _previousPosition.latitude,
                _previousPosition.longitude,
                _currentPosition.latitude,
                _currentPosition.longitude,
              );
              _totalDistance += _distanceBetweenLastTwoLocations;
              print('Total Distance: $_totalDistance');
            }
          });
        }).catchError((err) {
          print(err);
        });
      } else {
        await Geolocator.openLocationSettings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          backgroundColor: Colors.black87,
          leading: BackButton(
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
            },
          )),
      body: Stack(children: [
        Container(
          height: MediaQuery.of(context).size.height * .6,
          width: double.infinity,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
                target: LatLng(43.2, -8.3),
                zoom: cameraZoom,
                tilt: cameraTilt,
                bearing: cameraBearing),
            myLocationEnabled: true,
            compassEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            buildingsEnabled: false,
            trafficEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            mapType: MapType.normal,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * .4,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(50), topLeft: Radius.circular(50)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                /// Display stop watch time
                StreamBuilder<int>(
                  stream: _stopWatchTimer.rawTime,
                  initialData: _stopWatchTimer.rawTime.value,
                  builder: (context, snap) {
                    final value = snap.data!;
                    final displayTime = StopWatchTimer.getDisplayTime(
                      value,
                      hours: false,
                    );
                    return Column(
                      children: <Widget>[
                        Text(
                          'Distance: ${(_totalDistance / 1000).toStringAsFixed(2)}km',
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                displayTime.substring(0, 6),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15.0),
                                child: Text(
                                  displayTime.substring(6, 8),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    _stopWatchTimer.onExecute
                                        .add(StopWatchExecute.start);
                                    setState(() {
                                      _calculateDistance();
                                    });
                                  },
                                  child: const Icon(Icons.play_arrow_rounded,
                                      color: Colors.white),
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.red,
                                      shape: CircleBorder(),
                                      fixedSize: Size.fromHeight(50)),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    _stopWatchTimer.onExecute
                                        .add(StopWatchExecute.stop);
                                    setState(() {
                                      _positionStream.pause();
                                      if (_positionStream.isPaused) {
                                        print('distance track paused');
                                      }
                                    });
                                  },
                                  child: const Icon(Icons.stop_rounded,
                                      color: Colors.white),
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.red,
                                      shape: CircleBorder(),
                                      fixedSize: Size.fromHeight(50)),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    _stopWatchTimer.onExecute
                                        .add(StopWatchExecute.reset);
                                    setState(() {
                                      _positionStream.cancel();
                                      print('distance track canceled/reseted');
                                      _totalDistance = 0;
                                      locations.clear();
                                    });
                                  },
                                  child: const Icon(Icons.replay_rounded,
                                      color: Colors.white),
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.red,
                                      shape: CircleBorder(),
                                      fixedSize: Size.fromHeight(50)),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            _showDialog(
                                                'https://1.bp.blogspot.com/-nySaGEHWibE/W4rlACo-DMI/AAAAAAAC-vg/hOx4H5QBdxMhtp3eIkQLre1Q6RaFpe2KQCLcBGAs/s1600/ta71.gif',
                                                'Done!',
                                                displayTime,
                                                _totalDistance.toInt(),
                                                context));
                                    updateDistance(_totalDistance.toInt());
                                    _stopWatchTimer.onExecute
                                        .add(StopWatchExecute.reset);

                                    setState(() {
                                      _positionStream.cancel();
                                      locations.clear();
                                    });
                                  },
                                  child: const Icon(Icons.check_rounded,
                                      color: Colors.white),
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.red,
                                      shape: CircleBorder(),
                                      fixedSize: Size.fromHeight(50)),
                                ),
                              ),
                            ])
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  updateDistance(int distance) async {
    String url = "http://$ip:8081/api/v1/challenge/$user_id/get/distance";
    var getResponse = await http.get(Uri.parse(url));

    if (getResponse.statusCode == 200) {
      print(getResponse.body.toString());

      var distanceValue =
          convert.jsonDecode(getResponse.body)['challenges']['value'];

      var newDistance = distanceValue + distance;
      String url2 = "http://$ip:8081/api/v1/challenge/$user_id/update/distance";
      var updateResponse = await http.patch(Uri.parse(url2),
          body: convert.jsonEncode({"value": newDistance}));
      setState(() {});
      if (updateResponse.statusCode == 200) {
        print('update distance ok');
      }
    }
  }

  Widget _showDialog(gif, text, time, int distance, context) {
    print(distance);
    Widget doneButton = TextButton(
        style: TextButton.styleFrom(
            primary: Colors.white, backgroundColor: Colors.red),
        child: new Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          _totalDistance = 0;
          Navigator.of(context).pop();
        });

    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25))),
        content: Container(
          height: 255,
          width: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    image: DecorationImage(
                        fit: BoxFit.fitHeight, image: NetworkImage(gif))),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                'Congrats!\nYou ran $distance m in $time ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[doneButton])
        ],
      );
    });
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
    _positionStream.cancel();
  }
}
