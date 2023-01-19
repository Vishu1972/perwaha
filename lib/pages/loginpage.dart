import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:perwha/model/LoginResponse.dart';
import 'package:perwha/pages/permitdetailspage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../utils/util.dart';
import 'forget_password.dart';
import 'homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginpageState();
}

class _LoginpageState extends State<LoginPage> {

  String url = "http://mngl.intileo.com/api/login";
  bool userId = false;
  bool password = false;
  bool _isVisible = false;
  late SharedPreferences sharedPreferences;
  TextEditingController usernameControler = TextEditingController();
  TextEditingController passwordControler = TextEditingController();


  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> PermitDetailsPage(getPermitIdFromNotification(message))));

      // Navigator.pushNamed(
      //   context,
      //   '/message',
      //   arguments: MessageArguments(message, true),
      // );
    });

    usernameControler.addListener(() {
      setState(() {
        userId = usernameControler.text.isNotEmpty;
      });
    });

    passwordControler.addListener(() {
      setState(() {
        password = passwordControler.text.isNotEmpty;
      });
    });
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              child: Image.asset(
                                'assets/images/rec.png',
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                            Positioned(
                              left: MediaQuery.of(context).size.width * .5 - 52,
                              top: 80,
                              child: Image.asset(
                                'assets/images/mngl_1.png',
                                height: 104,
                                width: 104,
                              ),
                            ),
                            const SizedBox(
                              height: 1,
                            ),
                            Positioned(
                              top: 184,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 33,
                                child: const Text(
                                  'PerWAH',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 32),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 1,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 326,
                              child: TextField(
                                controller: usernameControler,
                                decoration: const InputDecoration(
                                  filled: true,
                                  focusColor: Colors.white,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter User ID',
                                  labelText: 'User ID',
                                ),
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 326,
                              child: TextField(
                                controller: passwordControler,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  filled: true,
                                  focusColor: Colors.white,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter Password',
                                  labelText: 'Password',
                                ),
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 37.0,
                              width: 326,
                              child: ElevatedButton(
                                onPressed: userId && password ? (() async {
                                  final fcmToken = await FirebaseMessaging.instance.getToken();
                                  setState(() {
                                    _isVisible = true;
                                  });
                                  final loginResponse = await http.post(
                                      Uri.parse(url),
                                      headers: {
                                        'Content-Type':
                                            'application/json; charset=UTF-8',
                                      },
                                      body: jsonEncode(<String, String>{
                                        'username': usernameControler.text,
                                        'password': passwordControler.text,
                                        'token' : fcmToken!
                                      }));
                                  print(loginResponse.statusCode);
                                  if (loginResponse.statusCode == 200) {

                                    setState(() {
                                      _isVisible = false;
                                    });
                                    var data = LoginResponse.fromJson(
                                        jsonDecode(loginResponse.body));
                                    if (data.status!) {
                                      sharedPreferences =

                                          await SharedPreferences.getInstance();
                                      sharedPreferences.setString(
                                          "Authentication_token",
                                          "Bearer ${data.token!}");
                                      sharedPreferences.setString(
                                          "user_profile", data.designation!.toString());
                                      sharedPreferences.setBool(
                                          "is_Login", true);
                                      sharedPreferences.setString("user_name", data.user!.name!);
                                      sharedPreferences.setString("degination", data.user!.designationId!.toString());
                                      sharedPreferences.setString("mobile", data.user!.mobile!);
                                      sharedPreferences.setString("email", data.user!.email!);
                                      sharedPreferences.setString("state", data.user!.stateName!);
                                      sharedPreferences.setString("GA", data.user!.districtName!);
                                      sharedPreferences.setString("PA", data.user!.projectAreaName![0].description!);
                                      if(data.designationId==3){
                                        sharedPreferences.setString("CA", data.user!.chargeAreaName![0].description!);
                                      }
                                      else{
                                        sharedPreferences.setString("CA", 'ca');
                                      }

                                      sharedPreferences.setString("project_area_id", data.user!.projectAreaName![0].id!.toString());
                                      Navigator.pushAndRemoveUntil(context,MaterialPageRoute(
                                          builder: (context) => HomePage()), (route) => false);
                                    } else {
                                      setState(() {
                                        _isVisible = false;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content:
                                                  Text(data.msg!)));
                                    }
                                  } else {
                                    var data = LoginResponse.fromJson(
                                        jsonDecode(loginResponse.body));
                                    setState(() {
                                      _isVisible = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text("Invalid credentials")));
                                  }
                                }) : null ,
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.orange),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Transform(transform: Matrix4.translationValues(35, 0, 0),
                        child: TextButton(onPressed: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ForgetPassword()));
                        }, child: Text("Forget Password ?", style: TextStyle(fontSize: 16),) )),
                        Container(
                          height: 200,
                          padding: const EdgeInsets.only(left: 100),
                          child: Image.asset(
                            height: 200,
                            width: 300,
                            'assets/images/pg.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ]
                  ),
                ),
                Visibility(
                  visible: _isVisible,
                  child: Positioned(
                    top: MediaQuery.of(context).size.height * 0.5 - 50,
                    left: MediaQuery.of(context).size.width * 0.5 - 50,
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: const BoxDecoration(
                        color: Colors.orangeAccent,
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(
                            color: Colors.blue,
                            backgroundColor: Colors.white,
                            semanticsLabel: "Loading....",
                            semanticsValue: "2",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
