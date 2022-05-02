// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:healthier_app/src/utils/jwt.dart';
import 'package:http/http.dart' as http;
import 'package:cool_alert/cool_alert.dart';
import 'package:healthier_app/src/login_page.dart';
import './utils/constants.dart' as constants;

import '../main.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPage createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  String password = "";
  String ip = constants.IP;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.red,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 14),
        alignment: Alignment.topLeft,
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                "Settings",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors.red,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      "Account",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 15,
                  thickness: 2,
                ),
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Já estás Candido"),
                            content: Column(
                              children: [
                                TextFormField(
                                    controller: _newPasswordController,
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
                                      labelText: 'Enter your new password',
                                    ),
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter some text';
                                      }
                                    }),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter some text';
                                    } else if (_newPasswordController.text !=
                                        _confirmPasswordController.text) {
                                      return 'Passwords don\'t match! Try again...';
                                    }
                                    password = _confirmPasswordController.text;
                                  },
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'Confirm your new password',
                                  ),
                                  obscureText: true,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                style:
                                    TextButton.styleFrom(primary: Colors.red),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Close"),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Colors.red),
                                onPressed: () {
                                  updatePassword();
                                  Navigator.of(context).pop();
                                },
                                child: Text("Update"),
                              ),
                            ],
                          );
                        });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Change Password",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height*.6,
              alignment: Alignment.bottomCenter,
              child: OutlinedButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                  EdgeInsets.only(
                    left: 60,
                    right: 60,
                  ),
                ),
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Sign Out"),
                        content: Text("Are you sure you want to Sign Out?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()),
                                      (_) => false);
                            },
                            child: Text("Continue"),
                          )
                        ],
                      );
                    });
              },
              child: Text(
                "SIGN OUT",
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 2.2,
                  color: Colors.black,
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  updatePassword() async {
    var jwt = await storage.read(key: "jwt");
    var results = parseJwtPayLoad(jwt!);
    var id = results["UserID"];

    String url = "http://$ip:8081/api/v1/user/$id";
    var response = await http.patch(Uri.parse(url),
        body: jsonEncode({"password": password}));
    if (response.statusCode == 200) {
      await storage.write(key: 'password', value: password);
      return CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        text: "Your password as been successfully updated!",
      );
    } else {
      return CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: "Sorry! Something went wrong...",
      );
    }
  }
}
