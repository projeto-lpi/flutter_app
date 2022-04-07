import 'package:flutter/material.dart';
import 'package:healthier_app/src/models/users.dart';
import 'package:healthier_app/src/home_page.dart';
import 'package:healthier_app/src/utils/jwt.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String name = "";
  late String email = "";

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
      email = results["email"];
      print(name);
      print(email);
    });
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: InkWell(
        child: Column(children: [
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/background_gradient.webp'),
                  fit: BoxFit.cover),
            ),
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: [
                buildImage(),
                const SizedBox(height: 24),
                Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(color: Colors.black),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          )
        ]),
      ),
    );
  }

  Widget buildImage() {
    return const Align(
      alignment: Alignment.center,
      child: CircleAvatar(
        radius: 64.0,
        backgroundImage: AssetImage('assets/images/foto.jpg'),
      ),
    );
  }
}
