// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:healthier_app/src/utils/jwt.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:convert';
import '../main.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String name = "";

  @override
  void initState() {
    getUsername();
    super.initState();
  }

  getUsername() async {
    var jwt = await storage.read(key: "jwt");
    var results = parseJwtPayLoad(jwt!);
    setState(() {
      name = results["name"];
      print(name);
    });
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          title: DefaultTextStyle(
            style: const TextStyle(
              fontSize: 30.0,
              fontFamily: 'Agne',
            ),
            child: AnimatedTextKit(
              totalRepeatCount: 3,
              repeatForever: false,
              animatedTexts: [
                TypewriterAnimatedText(
                  'Hello $name',
                ),
              ],
              onTap: () {},
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0),
      bottomSheet:
          ButtonBar(alignment: MainAxisAlignment.spaceAround, children: [
        IconButton(
          icon: const Icon(Icons.home),
          color: Colors.red,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.directions_run),
          color: Colors.red,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.no_food),
          color: Colors.red,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.person_sharp),
          color: Colors.red,
          onPressed: () {},
        ),
      ]),
      body: Column(children: [
        Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/background_gradient.webp'),
                fit: BoxFit.cover),
          ),
          child: Column(
            children: [
              if (name != "")
                Padding(
                  padding: const EdgeInsets.only(top: 200),
                  child: Text(name),
                )
            ],
          ),
        ),
      ]),
    );
  }
}
