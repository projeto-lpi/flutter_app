// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, non_constant_identifier_names, avoid_print

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:healthier_app/src/models/users.dart';
import 'package:healthier_app/src/client/client_bottom_bar_page.dart';
import 'package:healthier_app/src/signup_page.dart';
import 'package:healthier_app/src/trainer/trainer_bottom_bar_page.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import './utils/constants.dart' as constants;
import 'nutri/nutri_bottom_bar_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  Users user = Users(0, "", "", "", "");
  String ip = constants.IP;
  String role = "";
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isHidden = true;
  int state = 0;

  @override
  void initState() {
    super.initState();
    isHidden = true;
  }

  Future attemptLogIn() async {
    String url = "http://$ip:8081/api/v1/auth/login";
    var request = {"email": user.email, "password": user.password};
    var response = await http.post(Uri.parse(url), body: jsonEncode(request));

    var jsonResponse;
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        state = 1;
        var token = jsonResponse['token'];
        role = jsonResponse['role'];
        await storage.write(key: 'jwt', value: token);
      }
      print('login ok');

      return 1;
    }
    state = 0;
    print('login not ok');
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundImage: AssetImage('assets/images/logo.jpg'),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(children: [
                      _EmailInput(),
                      _PasswordInput(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            user.email = _emailController.text;
                            user.password = _passwordController.text;
                            if (checkEmail(user.email) == true) {
                              await attemptLogIn();
                              if (state == 1) {
                                if (role == 'CLIENT') {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MyHomePage(),
                                    ),
                                  );
                                } else if (role == 'NUTRITIONIST') {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NutriMyHomePage(),
                                    ),
                                  );
                                } else if (role == 'TRAINER') {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TrainerMyHomePage(),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              fixedSize: const Size(200, 40),
                              primary: constants.buttonColor),
                          child: Text(
                            'Login'.toUpperCase(),
                          ),
                        ),
                      ),
                      _SignupButton(context),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column _SignupButton(BuildContext context) {
    return Column(
      children: [
        Text(
          'Don\'t have an account?\nSign up here!',
          style: TextStyle(fontSize: 11),
          textAlign: TextAlign.center,
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => SignupPage()));
          },
          style: ElevatedButton.styleFrom(
              fixedSize: const Size(200, 40),
              primary: Color.fromRGBO(233, 196, 106, 1)),
          child: Text(
            'Sign Up'.toUpperCase(),
          ),
        ),
      ],
    );
  }

  bool checkEmail(String string) {
    final emailRgx = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    return emailRgx.hasMatch(string);
  }

  Widget _PasswordInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
        },
        controller: _passwordController,
        obscureText: isHidden,
        decoration: InputDecoration(
          errorText: (_passwordController.text == null ||
                  _passwordController.text.isEmpty)
              ? 'Invalid password'
              : '',
          labelText: 'Password',
          prefixIcon: Icon(
            Icons.password,
            color: constants.buttonColor,
          ),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _EmailInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return (checkEmail(value) == false ? 'Invalid email' : null);
        },
        controller: _emailController,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.alternate_email,
            color: constants.buttonColor,
          ),
          errorText: (checkEmail(_emailController.text) == false
              ? 'Invalid email'
              : ''),
          labelText: 'Email',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
