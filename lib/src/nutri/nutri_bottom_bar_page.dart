// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:healthier_app/src/nutri/chat_page.dart';
import 'package:healthier_app/src/profile_page.dart';
import 'package:healthier_app/src/utils/constants.dart';
import 'package:healthier_app/src/widgets/custom_animated_bottom_bar.dart';

import 'nutri_home_page.dart';

class NutriMyHomePage extends StatefulWidget {
  const NutriMyHomePage({Key? key}) : super(key: key);

  @override
  State<NutriMyHomePage> createState() => _NutriMyHomePageState();
}

class _NutriMyHomePageState extends State<NutriMyHomePage> {
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
      //NutriHomePage(),
      NutriNutriPage(),
      ProfilePage(),
    ];
    return IndexedStack(
      index: _currentIndex,
      children: pages,
    );
  }

  Widget _buildBottomBar() {
    return CustomAnimatedBottomBar(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      containerHeight: 70,
      backgroundColor: Colors.white,
      selectedIndex: _currentIndex,
      showElevation: true,
      itemCornerRadius: 24,
      curve: Curves.easeIn,
      onItemSelected: (index) => setState(() => _currentIndex = index),
      items: <BottomNavyBarItem>[
        BottomNavyBarItem(
          icon: Icon(Icons.fastfood_rounded),
          title: Text('Nutritionist '),
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
