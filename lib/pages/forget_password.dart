import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  String url = "http://mngl.intileo.com/api/forget_password";
  bool _isVisible = false;
  bool otp_button = false;
  TextEditingController usernameControler = TextEditingController();

  @override
  void initState() {
    super.initState();
    usernameControler.addListener(() {
      setState(() {
        otp_button = usernameControler.text.isNotEmpty;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
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
                                onPressed: otp_button? (() async {
                                  setState(() {
                                    _isVisible = true;
                                  });
                                  final forgetResponse = await http.post(
                                      Uri.parse(url),
                                      headers: {
                                        'Content-Type':
                                        'application/json; charset=UTF-8',
                                      },
                                      body: jsonEncode(<String, String>{
                                        'user_id': usernameControler.text,

                                      }));
                                  if(forgetResponse.statusCode == 200){
                                    setState(() {
                                      _isVisible = false;
                                    });
                                    try{
                                      var data = jsonDecode(forgetResponse.body);
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data["msg"])));
                                    } on Exception catch(_){
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Otp Sent")));
                                    }
                                  }else{
                                    setState(() {
                                      _isVisible = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something Wrong")));
                                  }
                                }) : null,
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.orange),
                                child: const Text(
                                  'Send OTP on Email',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
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

