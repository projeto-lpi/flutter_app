import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.pink),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_run_rounded, color: Colors.pink),
          label: 'Training',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fastfood_rounded, color: Colors.pink),
          label: 'Nutritioning',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: Colors.pink),
          label: 'Profile',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.pink,
      onTap: _onItemTapped,
    );
  }
}
