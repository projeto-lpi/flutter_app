import 'dart:async';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class RunningPage extends StatefulWidget {
  const RunningPage({Key? key}) : super(key: key);

  @override
  State<RunningPage> createState() => _RunningPageState();
}

class _RunningPageState extends State<RunningPage> {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
  );

  late Position _currentPosition;
  late Position _previousPosition;
  late StreamSubscription<Position> _positionStream;
  double _totalDistance = 0;

  int flag = 0;
  List<Position> locations = [];

  @override
  void initState() {
    super.initState();
  }

  Future _calculateDistance() async {
    LocationPermission permission;
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
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            /// Display stop watch time
            StreamBuilder<int>(
              stream: _stopWatchTimer.rawTime,
              initialData: _stopWatchTimer.rawTime.valueWrapper?.value,
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
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
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
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ElevatedButton(
                          onPressed: () async {
                            _stopWatchTimer.onExecute
                                .add(StopWatchExecute.stop);
                            setState(() {
                              _positionStream.pause();
                              if(_positionStream.isPaused){
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
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ElevatedButton(
                          onPressed: () async {
                            _stopWatchTimer.onExecute
                                .add(StopWatchExecute.reset);
                            setState(() {
                              _positionStream.cancel();
                              print('distance track canceled/reseted');
                              _totalDistance=0;
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
                    ])
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
    _positionStream.cancel();
  }
}
