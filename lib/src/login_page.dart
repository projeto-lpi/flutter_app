// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:healthier_app/src/models/users.dart';
import 'package:healthier_app/src/my_home_page.dart';
import 'package:healthier_app/src/signup_page.dart';
import 'package:healthier_app/src/home_page.dart';
import 'package:http/http.dart' as http;
import '../main.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  Users user = Users(0, "", "", "", "");

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int state = 0;

  @override
  void initState() {
    super.initState();
  }

  String url = "http://18.170.87.131:8081/api/v1/auth/login";

  Future attemptLogIn() async {
    var request = {"email": user.email, "password": user.password};
    var response = await http.post(Uri.parse(url), body: jsonEncode(request));

    var jsonResponse;
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        state = 1;
        var token = jsonResponse['token'];

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
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_gradient.webp'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/images/logo.jpg'),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Form(
                        key: _formKey,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                            color: Colors.white,
                          ),
                          width: 300,
                          height: 350,
                          child: Column(children: [
                            SizedBox(
                              height: 40,
                            ),
                            drawFormField(
                                'Email', _emailController, Icons.email),
                            drawFormField('Password', _passwordController,
                                Icons.password),
                            SizedBox(height: 40),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  user.email = _emailController.text;
                                  user.password = _passwordController.text;
                                  if (checkEmail(user.email) == true) {
                                    await attemptLogIn();
                                    if (state == 1) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MyHomePage(),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: Text(
                                  'Login'.toUpperCase(),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignupPage()));
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                'Sign Up'.toUpperCase(),
                              ),
                            ),
                            Column(
                              children: [
                                InkWell(
                                  onTap: () {},
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            )
                          ]),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool checkEmail(String string) {
    final emailRgx = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    return emailRgx.hasMatch(string);
  }

  Widget drawFormField(
      String text, TextEditingController controller, IconData _icon) {
    return Container(
      width: MediaQuery.of(context).size.width * .63,
      height: /* _validate_password ? 55 :*/ 35,
      margin: EdgeInsets.only(top: 15),
      padding: EdgeInsets.only(
        left: 20,
        right: 50,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(50)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Icon(
            _icon,
            color: Colors.red,
          ),
          SizedBox(
            width: 10,
          ),
          Flexible(
            child: TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                if (text == 'Email') {
                  if (checkEmail(value) == false) {
                    return 'Invalid email';
                  }
                }
                return null;
              },
              controller: controller,
              obscureText: text == 'Password' ? true : false,
              decoration: InputDecoration(
                /*  hintText:
                                          _validate_password ? null : 'Password',
                                      errorText: _validate_password
                                          ? validatePassword(_passwordController.text)
                                          : null,*/
                hintText: text,
                border: UnderlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget drawButton(String text) {
    return Container(
      width: MediaQuery.of(context).size.width * .3,
      height: MediaQuery.of(context).size.height * .05,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(25)),
        color: Colors.red,
      ),
      child: Center(
          child: Text(
        text.toUpperCase(),
        style: TextStyle(color: Colors.white),
      )),
    );
  }
}
