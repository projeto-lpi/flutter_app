// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:healthier_app/src/client/nutri_page.dart';
import 'package:healthier_app/src/client/training_page.dart';
import 'package:healthier_app/src/utils/constants.dart';
import 'package:healthier_app/src/widgets/custom_animated_bottom_bar.dart';

import 'challenge_page.dart';
import 'client_home_page.dart';
import 'client_profile_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final _inactiveColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget getBody() {
    List<Widget> pages = [
      ClientHomePage(),
      ClientTrainingPage(),
      ClientNutriPage(),
      ChallengesPage(),
      ClientProfilePage(),
    ];
    return IndexedStack(
      index: _currentIndex,
      children: pages,
    );
  }

  Widget _buildBottomBar() {
    return CustomAnimatedBottomBar(
      containerHeight: 70,
      selectedIndex: _currentIndex,
      backgroundColor: textColor,
      showElevation: true,
      itemCornerRadius: 24,
      curve: Curves.easeIn,
      onItemSelected: (index) => setState(() => _currentIndex = index),
      items: <BottomNavyBarItem>[
        BottomNavyBarItem(
          icon: Icon(Icons.home_rounded),
          title: Text('Home'),
          activeColor: buttonColor,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
          icon: Icon(Icons.directions_run_rounded),
          title: Text('Training'),
          activeColor: buttonColor,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
          icon: Icon(Icons.fastfood_rounded),
          title: Text('Nutritionist '),
          activeColor: buttonColor,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
          icon: Icon(Icons.emoji_events_rounded),
          title: Text('Challenges'),
          activeColor: buttonColor,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
          icon: Icon(Icons.person),
          title: Text('Profile'),
          activeColor: buttonColor,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
