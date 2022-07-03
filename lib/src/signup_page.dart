// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, prefer_final_fields, prefer_typing_uninitialized_variables, avoid_print

import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './utils/constants.dart' as constants;
import '../main.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

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

  bool _validate_email = false;
  int state = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: constants.buttonColor,
            ),
          ),
        ),
        body: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: constants.bgColor,
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 150.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  width: 300,
                  child: Column(children: [
                    _DropdownMenu(),
                    drawBody(),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25.0),
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
                                  ? gender = "male"
                                  : gender = "female"),
                              role,
                              context);
                        } else if (flag == 0) {
                          attemptSignUpOthers(
                              name, email, password, role, context);
                        }

                        if (state == 1) {
                          SnackBar(
                            content: Text('Account created successfully'),
                            duration: Duration(milliseconds: 500),
                          );
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(200, 40),
                      primary: constants.buttonColor,
                    ),
                    child: Text(
                      'Submit'.toUpperCase(),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Padding _DropdownMenu() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: DropdownButton(
          alignment: Alignment.center,
          value: role,
          style: TextStyle(fontSize: 15),
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
    );
  }

  drawBody() {
    if (role == 'CLIENT') {
      flag = 1;
      return Container(
        height: 400,
        child: ListView(
          padding: EdgeInsets.only(top: 0),
          children: [
            _NameInput(),
            _EmailInput(),
            _PasswordInput(),
            _AgeInput(),
            _WeightInput(),
            _HeightInput(),
            Row(children: [
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 40),
                child: Icon(
                  Icons.female_rounded,
                  color: constants.buttonColor,
                ),
              ),
              Transform.translate(
                offset: Offset(2.5, 0),
                child: Switch(
                  activeColor: constants.iconColor,
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
                  color: constants.buttonColor,
                ),
              ),
            ]),
          ],
        ),
      );
    } else if (role == 'NUTRITIONIST' || role == 'TRAINER') {
      flag = 0;
      return Container(
        height: 300,
        child: Column(
          children: [
            _NameInput(),
            _EmailInput(),
            _PasswordInput(),
          ],
        ),
      );
    }
  }

  Widget _NameInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        keyboardType: TextInputType.name,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
        },
        controller: _nameController,
        decoration: InputDecoration(
          errorText:
              (_nameController.text == null || _nameController.text.isEmpty)
                  ? 'Invalid name'
                  : '',
          labelText: 'Name',
          prefixIcon: Icon(
            Icons.person,
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
        obscureText: true,
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

  Widget _AgeInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
        },
        controller: _ageController,
        decoration: InputDecoration(
          errorText:
              (_ageController.text == null || _ageController.text.isEmpty)
                  ? 'Invalid age'
                  : '',
          labelText: 'Age',
          prefixIcon: Icon(
            Icons.calendar_month,
            color: constants.buttonColor,
          ),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _WeightInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
        },
        controller: _weightController,
        decoration: InputDecoration(
          errorText:
              (_weightController.text == null || _weightController.text.isEmpty)
                  ? 'Invalid weight'
                  : '',
          labelText: 'Weight',
          prefixIcon: Icon(
            Icons.balance,
            color: constants.buttonColor,
          ),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _HeightInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
        },
        controller: _heightController,
        decoration: InputDecoration(
          errorText:
              (_heightController.text == null || _heightController.text.isEmpty)
                  ? 'Invalid height'
                  : '',
          labelText: 'Height',
          prefixIcon: Icon(
            Icons.height,
            color: constants.buttonColor,
          ),
          border: OutlineInputBorder(),
        ),
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
    var response =
        await http.post(Uri.parse('http://$ip:8081/api/v1/auth/register'),
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

      CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        text: "Your account as been created successfully!",
      );
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
