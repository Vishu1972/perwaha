import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perwha/pages/homepage.dart';
import 'package:perwha/pages/loginpage.dart';
import 'package:perwha/pages/permitdetailspage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Widgets/message.dart';
import '../main.dart';
import '../utils/util.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SharedPreferences sharedPreferences;
  bool isLogin = false;

  _showSavedValue() async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool('boolValue', true);
    setState(() {
      isLogin = sharedPreferences.getBool("is_Login")!;
    });
  }


  @override
  void initState() {
    _showSavedValue();
    Timer(Duration(seconds: 2), (() {
      if (isLogin) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginPage()));
      }
    }));
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> PermitDetailsPage(getPermitIdFromNotification(message))));

      // Navigator.pushNamed(
      //   context,
      //   '/message',
      //   arguments: MessageArguments(message, true),
      // );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.orange, // Note RED here
      ),
    );
    return SafeArea(
      child: Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image.asset(
                'assets/images/mngl_1.png',
                height: 104,
                width: 104,
              ),
              Text(
                'PerWAH',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
