import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/login_page.dart';

final storage = FlutterSecureStorage();

/// The [SharedPreferences] key to access the alarm fire count.
const String countKey = 'count';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

/// A port used to communicate from a background isolate to the UI isolate.
final ReceivePort port = ReceivePort();

/// Global [SharedPreferences] object.
SharedPreferences? prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<int>('steps');
  FlutterNativeSplash();
  AndroidAlarmManager.initialize();
// Register the UI isolate's SendPort to allow for communication from the
  // background isolate.
  IsolateNameServer.registerPortWithName(
    port.sendPort,
    isolateName,
  );
  prefs = await SharedPreferences.getInstance();
  if (!prefs!.containsKey(countKey)) {
    await prefs!.setInt(countKey, 0);
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthier App',
      theme: ThemeData(
          fontFamily: "Cairo",
          visualDensity: VisualDensity.adaptivePlatformDensity,
          backgroundColor: Colors.grey),
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
