// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import './utils/constants.dart' as constants;
import 'dart:convert';
import '../main.dart';
import 'dart:async';
import 'package:healthier_app/src/client/client_home_page.dart';

class SignupPage extends StatefulWidget {
  SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String role = "client".toUpperCase();
  bool genderSwitch = false;
  String gender = "";
  String ip = constants.IP;

  int flag = 0;

  bool _validate_email = false,
      _validate_password = false,
      _validate_name = false;
  int state = 0;

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
              child: Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: Column(
                  children: [
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
                        height: 500,
                        child: Column(children: [
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: DropdownButton(
                                value: role,
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontFamily: "Cairo"),
                                borderRadius: BorderRadius.circular(5),
                                items: <DropdownMenuItem<String>>[
                                  DropdownMenuItem(
                                    child: Text("client".toUpperCase()),
                                    value: "client".toUpperCase(),
                                  ),
                                  DropdownMenuItem(
                                    child: Text("trainer".toUpperCase()),
                                    value: "trainer".toUpperCase(),
                                  ),
                                  DropdownMenuItem(
                                    child: Text("nutritionist".toUpperCase()),
                                    value: "nutritionist".toUpperCase(),
                                  ),
                                ],
                                onChanged: (String? selectedValue) {
                                  setState(() {
                                    role = selectedValue!;
                                  });
                                }),
                          ),
                          drawBody(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                var name = _nameController.text;
                                var email = _emailController.text;
                                var password = _passwordController.text;
                                var age = _ageController.text;
                                var weight = _weightController.text;
                                var height = _heightController.text;

                                if (_validate_email != true) {
                                  if (flag == 1) {
                                    await attemptSignUpClient(
                                        name,
                                        email,
                                        password,
                                        age,
                                        weight,
                                        height,
                                        (genderSwitch
                                            ? gender = "female"
                                            : gender = "male"),
                                        role,
                                        context);
                                  } else if (flag == 0) {
                                    attemptSignUpOthers(
                                        name, email, password, role, context);
                                  }

                                  if (state == 1) {
                                    SnackBar(
                                      content:
                                          Text('Account created successfully'),
                                      duration: Duration(seconds: 1),
                                    );
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LoginPage()));
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
                                'Submit'.toUpperCase(),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ));
  }

  drawBody() {
    if (role == 'CLIENT') {
      flag = 1;
      return Padding(
        padding: EdgeInsets.all(0),
        child: Column(
          children: [
            drawFormField('Name', _nameController, Icons.person),
            drawFormField('Email', _emailController, Icons.email),
            drawFormField('Password', _passwordController, Icons.password),
            drawFormField('Age', _ageController, Icons.calendar_month),
            drawFormField('Weight', _weightController, Icons.balance),
            drawFormField('Height', _heightController, Icons.height),
            Row(children: [
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 40),
                child: Icon(
                  Icons.female_rounded,
                  color: Colors.red,
                ),
              ),
              Transform.translate(
                offset: Offset(2.5, 0),
                child: Switch(
                  activeColor: Colors.red,
                  value: genderSwitch,
                  onChanged: (bool newValue) {
                    setState(() {
                      genderSwitch = newValue;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Icon(
                  Icons.male_rounded,
                  color: Colors.red,
                ),
              ),
            ]),
          ],
        ),
      );
    } else if (role == 'NUTRITIONIST' || role == 'TRAINER') {
      flag = 0;
      return Padding(
        padding: EdgeInsets.all(0),
        child: Column(
          children: [
            drawFormField('Name', _nameController, Icons.person),
            drawFormField('Email', _emailController, Icons.email),
            drawFormField('Password', _passwordController, Icons.password),
          ],
        ),
      );
    }
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

  Future<int> attemptSignUpOthers(String name, String email, String password,
      String role, BuildContext context) async {
    var response = await http.post(
        Uri.parse('http://$ip:8081/api/v1/auth/register'), //baguetes
        body: convert.jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "role": role
        }));
    var jsonResponse;
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        state = 1;
        var token = jsonResponse['token'];

        await storage.write(key: 'jwt', value: token);
      }
      print('register ok');

      return 1;
    }
    state = 0;
    print('register not ok');
    return 0;
  }

  Future<int> attemptSignUpClient(
      String name,
      String email,
      String password,
      String age,
      String weight,
      String height,
      String gender,
      String role,
      BuildContext context) async {
    var response = await http.post(
        //Uri.parse('http://192.168.75.1:8081/api/v1/auth/register'), //global
        //Uri.parse('http://192.168.56.1:8081/api/v1/auth/register'), //damss
        Uri.parse('http://$ip:8081/api/v1/auth/register'), //baguetes
        body: convert.jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "gender": gender,
          "age": age,
          "weight": weight,
          "height": height,
          "role": role
        }));
    var jsonResponse;
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        state = 1;
        var token = jsonResponse['token'];

        await storage.write(key: 'jwt', value: token);
      }
      print('register ok');

      return 1;
    }
    state = 0;
    print('register not ok');
    return 0;
  }

  bool checkEmail(String string) {
    final emailRgx = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    return emailRgx.hasMatch(string);
  }
}
