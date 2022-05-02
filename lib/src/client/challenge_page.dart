import 'package:flutter/material.dart';

class ChallengesPage extends StatefulWidget {
  ChallengesPage({Key? key}) : super(key: key);

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/background_gradient.webp'),
              fit: BoxFit.cover),
        ),
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
