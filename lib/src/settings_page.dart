import 'package:flutter/material.dart';
import 'package:healthier_app/src/utils/jwt.dart';
import 'package:page_transition/page_transition.dart';
import 'package:healthier_app/src/login_page.dart';

import '../main.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPage createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
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
        padding: EdgeInsets.only(left: 16, top: 15, right: 16),
        child: ListView(
          children: [
            Text(
              "Settings",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 40,
            ),
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
                            Text("É filho"),
                            Text("Global Noob"),
                            Text("Damss FDP"),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Close"),
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
            SizedBox(
              height: 330,
            ),
            Center(
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
            )
          ],
        ),
      ),
    );
  }
}
