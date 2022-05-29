// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:healthier_app/src/profile_page.dart';
import 'package:healthier_app/src/trainer/chat_page.dart';
import 'package:healthier_app/src/trainer/trainer_home_page.dart';
import 'package:healthier_app/src/widgets/custom_animated_bottom_bar.dart';

class TrainerMyHomePage extends StatefulWidget {
  const TrainerMyHomePage({Key? key}) : super(key: key);

  @override
  State<TrainerMyHomePage> createState() => _TrainerMyHomePageState();
}

class _TrainerMyHomePageState extends State<TrainerMyHomePage> {
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
      //TrainerHomePage(),
      TrainerTrainingPage(),
      ProfilePage(),
    ];
    return IndexedStack(
      index: _currentIndex,
      children: pages,
    );
  }

  Widget _buildBottomBar() {
    return CustomAnimatedBottomBar(
      containerHeight: 70,
      backgroundColor: Colors.white,
      selectedIndex: _currentIndex,
      showElevation: true,
      itemCornerRadius: 24,
      curve: Curves.easeIn,
      onItemSelected: (index) => setState(() => _currentIndex = index),
      items: <BottomNavyBarItem>[
        BottomNavyBarItem(
          icon: Icon(Icons.directions_run_rounded),
          title: Text('Training'),
          activeColor: Colors.red,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
          icon: Icon(Icons.person),
          title: Text('Profile'),
          activeColor: Colors.red,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
