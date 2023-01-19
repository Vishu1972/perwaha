import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perwha/Widgets/custon_search_bar.dart';
import 'package:perwha/model/PermitDetails.dart';
import 'package:perwha/model/PermitResponse.dart';
import 'package:perwha/pages/loginpage.dart';
import 'package:perwha/pages/permit.dart';
import 'package:perwha/utils/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Widgets/message.dart';
import '../main.dart';
import '../model/ProfileDetails.dart';
import '../services/repo.dart';
import 'permitdetailspage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String url = "http://mngl.intileo.com/api/logout";
  String userProfile = "";
  var jobDescItems = ['Select Job Desc.'];
  String jobDefaultValue = 'Select Job Desc.';
  String jobDefaultId = '';
  var tpeItems = ['Select Tpe.'];
  String tpeDefaultValue = 'Select Tpe.';
  String tpeDefaultId = '';
  String fromDate = " ";
  String toDate = " ";
  String data = "";
  bool isFromSearch = false;
  PermitResponse permitResponse = PermitResponse();
  PermitResponse permitData = PermitResponse();
  late SharedPreferences sharedPreferences;
  late bool _isFrist = false;
  String token = "";
  String state = "";
  String geo_area = "";
  String charge_area = "";
  String project_area = "";
  late bool _isFirstJob = false;
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _showSavedValue();
    _isFrist = true;
    fromDateController.addListener(() {
      if(fromDateController.text.isEmpty) {
       setState(() {
         fromDate = "01-10-2022";
       });
      }
    });

    toDateController.addListener(() {
      if(toDateController.text.isEmpty) {
        setState(() {
          toDate = dateFormater(DateTime.now(), "dd-MM-yyyy");
        });
      }
    });

    FirebaseMessaging.onMessage.listen(showFlutterNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("permitId   "+getPermitIdFromNotification(message));

      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> PermitDetailsPage(getPermitIdFromNotification(message))));
      // Navigator.pushNamed(
      //   context,
      //   '/message',
      //   arguments: MessageArguments(message, true),
      // );
    });
  }

  _showSavedValue() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userProfile = sharedPreferences.getString("degination")!;
      token = sharedPreferences.getString("Authentication_token")!;
      state = sharedPreferences.getString("state")!;
      geo_area = sharedPreferences.getString("GA")!;
      charge_area = sharedPreferences.getString("CA")!;
      project_area = sharedPreferences.getString("PA")!;
    });
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    build(context);
    super.didUpdateWidget(oldWidget);
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

 filterPermitList(List<PermitDetails> items, String value){
    List<PermitDetails> newPermitList = List.empty(growable: true);
    for(var permit in items){

      if(permit.locality == value) {
        newPermitList.add(permit);
        }

      if(value == "Approved"){

        if(permit.status =="Live"){

          newPermitList.add(permit);
        }

        if(permit.status == "Closure Applied"){
          newPermitList.add(permit);
        }

        if(permit.status == "Closed"){
          newPermitList.add(permit);
        }

        if(permit.status == "Suspended"){
          newPermitList.add(permit);
        }

        if(permit.status == "Recomd. to Suspend"){
          newPermitList.add(permit);
        }

      }

      if(permit.status == value){
        newPermitList.add(permit);
      }

    if(value == "Live"){

      if(permit.status == "Recomd. to Suspend"){
        newPermitList.add(permit);
      }

    }

 }
    return newPermitList;
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
        resizeToAvoidBottomInset: true,
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: FutureBuilder<ProfileDetails>(
            future: getProfileDetails(token),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _isFrist = false;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Positioned(
                              child: Image.asset(
                            'assets/images/rec.png',
                          )),
                          Positioned(
                            //  top: 30,
                            // left: MediaQuery.of(context).size.width * 0.4 - 125,
                            child: Image.asset(
                              'assets/images/ce.png',
                            ),
                          ),
                          Positioned(
                            top: 24,
                            left: 24,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop(
                                  MaterialPageRoute(
                                    builder: (context) => const HomePage(),
                                  ),
                                );
                              },
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                                size: 24.0,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              padding: EdgeInsets.all(11),
                              width: 300,
                              alignment: Alignment.center,
                              child: Text(
                                textAlign: TextAlign.center,
                                snapshot.data!.data!.name!,
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 24),
                              ),
                            ),
                          )
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            color: Color(0x32CB8C52),
                            borderRadius: BorderRadius.all(Radius.circular(10))),
                        width: 250,
                        child: Text(
                          snapshot.data!.data!.designation!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(0xffCC6F00),
                              fontWeight: FontWeight.w400),
                          textScaleFactor: 1.5,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                            color: Color(0x36D9D9D9),
                            borderRadius: BorderRadius.all(Radius.circular(4))),
                        padding: const EdgeInsets.all(14),
                        width: 244,
                        child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children:  [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person),
                                    SizedBox(width: 15,),
                                    Text(
                                      '${snapshot.data!.data!.userid!}',
                                      style: TextStyle(),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.call),
                                    SizedBox(width: 15,),
                                    Text(
                                      '+91 ${snapshot.data!.data!.mobile!}',
                                      style: TextStyle(),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.mail_outline),
                                    SizedBox(width: 15,),
                                    Text(
                                      snapshot.data!.data!.email!,
                                      style: TextStyle(),
                                    )
                                  ],
                                ),
                              ],
                            ),
                      ),
                      const SizedBox(
                        height: 31,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                            color: Color(0x36D9D9D9),
                            borderRadius: BorderRadius.all(Radius.circular(4))),
                        padding: const EdgeInsets.all(14),
                        width: 244,
                        child: Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('State'),
                                Text('GA'),
                                Text('PA'),
                                userProfile == "3" ? Text('CA') : Container(),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  snapshot.data!.data!.state!,
                                ),
                                Text(
                                  snapshot.data!.data!.geoArea!,
                                ),
                                Text(
                                  snapshot
                                      .data!.data!.projectArea![0].description!,
                                ),
                                userProfile == "3"
                                    ? Text(
                                        snapshot.data!.data!.chargeArea![0]
                                            .description!,
                                      )
                                    : Container(),
                              ],
                            )
                          ],
                        ),
                      ),
                      Stack(
                        children: [
                          Positioned(
                            // right: 0,
                            // bottom: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                height: 200,
                                'assets/images/pg.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 150,
                            left: 20,
                            child: SizedBox(
                              width: 102,
                              height: 36,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: const Color(0xFFF5A443),
                                ),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        icon: Image.asset("assets/images/mngl_1.png", width: 50, height: 50,),
                                            title: Text(
                                                "Are you sure, you want to logout from the PerWAH application?"),
                                            // titleTextStyle: TextStyle(
                                            //   fontSize: 14,
                                            //   fontWeight: FontWeight.normal
                                            // ),
                                            actions: [
                                              ElevatedButton(
                                                  onPressed: () {
                                                    _logout();

                                                  },
                                                  child: Text("Yes")),
                                              ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.of(context).pop(),
                                                  child: Text("No")),
                                            ],
                                          ));
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Icon(
                                      Icons.logout,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      "Logout",
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                );
              } else {
                return Visibility(
                  visible: _isFrist = true,
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                );
              }
            },
          ),
        ),
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(Icons.search_rounded, size: 30),
              onPressed: () async {
                 var data1 = await showSearch(
                    context: context,
                    delegate: CustomSearchBar(permitData.permitDetails!));

                setState(() {
                  data = data1;
                  _isFrist = true;
                  permitResponse.permitDetails = filterPermitList(permitData.permitDetails!, data);
                  isFromSearch = true;

                });
              }
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  if( isFromSearch == true){
                    isFromSearch = false;
                  }
                });

                showDialog(
                    context: context,
                    builder: (context) => userProfile == "3"
                        ? StatefulBuilder(
                            builder: (BuildContext context,
                                void Function(void Function()) setState1) {
                              return Dialog(
                                alignment: Alignment.topCenter,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  height: 240,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.8,
                                            height: 48,
                                            child: TextField(
                                              readOnly: true,
                                              controller: fromDateController,
                                              decoration: InputDecoration(
                                                filled: true,
                                                focusColor: Colors.white,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                    gapPadding: 5),
                                                labelText: 'From Date',
                                              ),
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                              onTap: () async {
                                                var pickedDate =
                                                    await showDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            DateTime.now(),
                                                        firstDate:
                                                            DateTime(2021),
                                                        lastDate:
                                                            DateTime.now());
                                                setState1(() {
                                                  fromDate = dateFormater(
                                                      pickedDate!,
                                                      "dd-MM-yyyy");
                                                  fromDateController.text =
                                                      dateFormater(pickedDate!,
                                                          "dd-MM-yyyy");
                                                });
                                              },
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.8,
                                            height: 48,
                                            child: TextField(
                                              readOnly: true,
                                              controller: toDateController,
                                              decoration: InputDecoration(
                                                filled: true,
                                                focusColor: Colors.white,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                    gapPadding: 5),
                                                labelText: 'To Date',
                                              ),
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                              onTap: () async {
                                                var pickedDate =
                                                    await showDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            DateTime.now(),
                                                        firstDate:
                                                            DateTime(2021),
                                                        lastDate:
                                                            DateTime.now());
                                                setState1(() {
                                                  toDate = dateFormater(
                                                      pickedDate!,
                                                      "dd-MM-yyyy");
                                                  toDateController.text =
                                                      dateFormater(pickedDate,
                                                          "dd-MM-yyyy");
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                color: Colors.black,
                                                width: 0.9),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(4))),
                                        child: SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: FutureBuilder(
                                              future: getJobDecsList(token),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  print(snapshot.data!.data);
                                                  var jobItems;
                                                  _isFirstJob = true;
                                                  for (var jobItem
                                                      in snapshot.data!.data!) {
                                                    if (!jobDescItems.contains(
                                                        jobItem.description)) {
                                                      jobItems = jobItem;
                                                      jobDescItems.add(
                                                          jobItem.description!);
                                                    }
                                                  }
                                                  return DropdownButton<String>(
                                                    isExpanded: true,
                                                    value: jobDefaultValue,
                                                    icon: const Icon(Icons
                                                        .keyboard_arrow_down),
                                                    items: jobDescItems
                                                        .map((String items) {
                                                      return DropdownMenuItem(
                                                        value: items,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            items,
                                                            style: TextStyle(
                                                                fontSize: 14),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged: (val) {
                                                      setState1(() {
                                                        jobDefaultValue = val!;
                                                        jobDefaultId = snapshot.data!.data![snapshot.data!.data!.indexWhere((element) => element.description == val,0)].id!.toString();
                                                        print(snapshot.data);
                                                      });

                                                    },
                                                  );
                                                } else {
                                                  return DropdownButton<String>(
                                                    isExpanded: true,
                                                    // Initial Value
                                                    value: jobDefaultValue,

                                                    // Down Arrow Icon
                                                    icon: const Icon(Icons
                                                        .keyboard_arrow_down),

                                                    // Array list of items
                                                    items: jobDescItems
                                                        .map((String items) {
                                                      return DropdownMenuItem(
                                                        value: items,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            items,
                                                            style: TextStyle(
                                                                fontSize: 14),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    // After selecting the desired option,it will
                                                    // change button value to selected value
                                                    onChanged:
                                                        (String? newValue) {
                                                      setState1(() {
                                                        jobDefaultValue =
                                                            newValue!;
                                                      });
                                                    },
                                                  );
                                                }
                                              }),
                                        ),
                                      ),
                                      SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  if(fromDate.isEmpty){
                                                    fromDate="01-10-2022";
                                                  }
                                                  if(toDate.isEmpty){
                                                    toDate = dateFormater(DateTime.now(), "dd-MM-yyyy");
                                                  }
                                                  fromDateController.text = "";
                                                  toDateController.text = "";
                                                  _isFrist = true;
                                                });
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Submit"))),
                                      Text("Note: By default, on clicking 'Submit' button, all records will get displayed.")
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : StatefulBuilder(
                            builder: (BuildContext context,
                                void Function(void Function()) setState1) {
                              return Dialog(
                                alignment: Alignment.topCenter,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  height: 240,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.8,
                                            height: 48,
                                            child: TextField(
                                              readOnly: true,
                                              controller: fromDateController,
                                              decoration: InputDecoration(
                                                filled: true,
                                                focusColor: Colors.white,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                    gapPadding: 5),
                                                labelText: 'From Date',
                                              ),
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                              onTap: () async {
                                                var pickedDate =
                                                    await showDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            DateTime.now(),
                                                        firstDate:
                                                            DateTime(2021),
                                                        lastDate:
                                                            DateTime.now());
                                                setState1(() {
                                                  fromDate = dateFormater(
                                                      pickedDate!,
                                                      "dd-MM-yyyy");
                                                  fromDateController.text =
                                                      dateFormater(pickedDate!,
                                                          "dd-MM-yyyy");
                                                });
                                              },
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.8,
                                            height: 48,
                                            child: TextField(
                                              readOnly: true,
                                              controller: toDateController,
                                              decoration: InputDecoration(
                                                filled: true,
                                                focusColor: Colors.white,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                    gapPadding: 5),
                                                labelText: 'To Date',
                                              ),
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                              onTap: () async {
                                                var pickedDate =
                                                    await showDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            DateTime.now(),
                                                        firstDate:
                                                            DateTime(2021),
                                                        lastDate:
                                                            DateTime.now());
                                                setState1(() {
                                                  toDate = dateFormater(
                                                      pickedDate!,
                                                      "dd-MM-yyyy");
                                                  toDateController.text =
                                                      dateFormater(pickedDate,
                                                          "dd-MM-yyyy");
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.8,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                    color: Colors.black,
                                                    width: 0.9),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(4))),
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: FutureBuilder(
                                                  future:getJobDecsList(token),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) {
                                                      var jobItems;
                                                      _isFirstJob = true;
                                                      for (var jobItem
                                                          in snapshot
                                                              .data!.data!) {
                                                        if (!jobDescItems
                                                            .contains(jobItem
                                                                .description)) {
                                                          jobItems = jobItem;
                                                          jobDescItems.add(
                                                              jobItem
                                                                  .description!);
                                                        }
                                                      }
                                                      return DropdownButton<
                                                          String>(
                                                        isExpanded: true,
                                                        value: jobDefaultValue,
                                                        icon: const Icon(Icons
                                                            .keyboard_arrow_down),
                                                        items: jobDescItems.map(
                                                            (String items) {
                                                          return DropdownMenuItem(
                                                            value: items,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                items,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                        onChanged: (val) {
                                                          setState1(() {
                                                            jobDefaultValue =
                                                                val!;
                                                            jobDefaultId = snapshot
                                                                .data!
                                                                .data![snapshot
                                                                    .data!.data!
                                                                    .indexWhere(
                                                                        (element) =>
                                                                            element.description ==
                                                                            val,
                                                                        0)]
                                                                .id!
                                                                .toString();
                                                            print(jobDefaultId);
                                                          });
                                                        },
                                                      );
                                                    } else {
                                                      return DropdownButton<
                                                          String>(
                                                        isExpanded: true,
                                                        // Initial Value
                                                        value: jobDefaultValue,

                                                        // Down Arrow Icon
                                                        icon: const Icon(Icons
                                                            .keyboard_arrow_down),

                                                        // Array list of items
                                                        items: jobDescItems.map(
                                                            (String items) {
                                                          return DropdownMenuItem(
                                                            value: items,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                items,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                        // After selecting the desired option,it will
                                                        // change button value to selected value
                                                        onChanged:
                                                            (String? newValue) {
                                                          setState1(() {
                                                            jobDefaultValue =
                                                                newValue!;
                                                          });
                                                        },
                                                      );
                                                    }
                                                  }),
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.8,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                    color: Colors.black,
                                                    width: 0.9),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(4))),
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: FutureBuilder(
                                                  future: getTpeList(token),
                                                  builder: (context, snapshot) {
                                                    print(snapshot.error);
                                                    if (snapshot.hasData) {
                                                      var jobItems;
                                                      _isFirstJob = true;
                                                      for (var tpeItem
                                                          in snapshot
                                                              .data!.tpedata!) {
                                                        if (!tpeItems.contains(
                                                            tpeItem.name)) {
                                                          jobItems = tpeItem;
                                                          tpeItems.add(
                                                              tpeItem.name!);
                                                        }
                                                      }
                                                      return DropdownButton<
                                                          String>(
                                                        isExpanded: true,
                                                        value: tpeDefaultValue,
                                                        icon: const Icon(Icons
                                                            .keyboard_arrow_down),
                                                        items: tpeItems.map(
                                                            (String items) {
                                                          return DropdownMenuItem(
                                                            value: items,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                items,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                        onChanged: (val) {
                                                          setState1(() {
                                                            tpeDefaultValue =
                                                                val!;
                                                            tpeDefaultId = snapshot
                                                                .data!
                                                                .tpedata![snapshot
                                                                    .data!
                                                                    .tpedata!
                                                                    .indexWhere(
                                                                        (element) =>
                                                                            element.name ==
                                                                            val,
                                                                        0)]
                                                                .id!
                                                                .toString();
                                                            print(tpeDefaultId);
                                                          });
                                                        },
                                                      );
                                                    } else {
                                                      return DropdownButton<
                                                          String>(
                                                        isExpanded: true,
                                                        // Initial Value
                                                        value: tpeDefaultValue,

                                                        // Down Arrow Icon
                                                        icon: const Icon(Icons
                                                            .keyboard_arrow_down),

                                                        // Array list of items
                                                        items: tpeItems.map(
                                                            (String items) {
                                                          return DropdownMenuItem(
                                                            value: items,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                items,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                        // After selecting the desired option,it will
                                                        // change button value to selected value
                                                        onChanged:
                                                            (String? newValue) {
                                                          setState1(() {
                                                            tpeDefaultValue =
                                                                newValue!;
                                                          });
                                                        },
                                                      );
                                                    }
                                                  }),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: ElevatedButton(
                                              onPressed: () {
                                                print(fromDate + "  "  +  toDate + "  " +   jobDefaultId + "  " +  tpeDefaultId );
                                                setState(() {
                                                  fromDateController.text = "";
                                                  toDateController.text = "";
                                                  _isFrist = true;
                                                });
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Submit"))),
                                      Text("Note: By default, on clicking 'Submit' button, all records will get displayed.")
                                    ],
                                  ),
                                ),
                              );
                            },
                          ));
              },
              child: const Icon(
                Icons.filter_alt_outlined,
                size: 30,
              ),
            ),
            SizedBox(
              width: 10,
            )
          ],
          titleSpacing: 0.0,
          title: const Text(
            'PerWAH',
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xffFFF7E1), Color(0xffFFFFEF)],
                      end: Alignment.topCenter,
                      begin: Alignment.bottomCenter)),
              child: FutureBuilder<PermitResponse>(
                future: _isFrist
                    ? getPermitDetails(
                        token, fromDate, toDate, jobDefaultId, tpeDefaultId)
                    : null,
                builder: (context, snapshot) {
                  _isFrist = false;
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      jobDefaultId = "";
                      tpeDefaultId = "";
                      fromDate = "";
                      toDate = "";
                          permitData = snapshot.data!;
                    //  permitResponse = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 8,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap : (){
                                        setState(() {
                                          _isFrist = true;
                                         isFromSearch = false;
                                        });
                                    },
                                      child: Container(
                                        width: 80,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(4)),
                                            border: Border.all(
                                                width: 2,
                                                color: const Color(0xff0066FE))),
                                        child: RichText(
                                          text: TextSpan(
                                              style: TextStyle(
                                                  color: Color(0xff0066FE)),
                                              children: [
                                                TextSpan(
                                                    text:
                                                        '${snapshot.data!.total!}\n',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14)),
                                                TextSpan(text: 'Total')
                                              ]),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          _isFrist = true;
                                          isFromSearch = false;
                                          permitResponse.permitDetails = filterPermitList(permitData.permitDetails!, "Approved");
                                          isFromSearch = true;
                                        });
                                      },
                                      child: Container(
                                        height: 38,
                                        width: 80,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(4)),
                                            border: Border.all(
                                                width: 2,
                                                color: const Color(0xff1B6700))),
                                        child: RichText(
                                          text: TextSpan(
                                              style: TextStyle(
                                                  color: Color(0xff1B6700)),
                                              children: [
                                                TextSpan(
                                                    text:
                                                        '${snapshot.data!.approved}\n',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14)),
                                                TextSpan(text: 'Approved')
                                              ]),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          _isFrist = true;
                                          isFromSearch = false;
                                          permitResponse.permitDetails = filterPermitList(permitData.permitDetails!, "Pending");
                                          isFromSearch = true;
                                        });
                                      },
                                      child: Container(
                                        height: 38,
                                        width: 80,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(4)),
                                            border: Border.all(
                                                width: 2,
                                                color: const Color(0xffFFB800))),
                                        child: RichText(
                                          text: TextSpan(
                                              style: TextStyle(
                                                  color: Color(0xffFFB800)),
                                              children: [
                                                TextSpan(
                                                    text:
                                                        '${snapshot.data!.pending}\n',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14)),
                                                TextSpan(text: 'Pending')
                                              ]),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          _isFrist = true;
                                          isFromSearch = false;
                                          permitResponse.permitDetails = filterPermitList(permitData.permitDetails!, "Rejected");
                                          isFromSearch = true;
                                        });
                                      },
                                      child: Container(
                                        height: 38,
                                        width: 80,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(4)),
                                            border: Border.all(
                                                width: 2,
                                                color: const Color(0xffFF0000))),
                                        child: RichText(
                                          text: TextSpan(
                                              style: TextStyle(
                                                  color: Color(0xffFF0000)),
                                              children: [
                                                TextSpan(
                                                    text:
                                                        '${snapshot.data!.rejected}\n',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14)),
                                                TextSpan(text: 'Rejected')
                                              ]),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ]),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(4)),
                                    border: Border.all(
                                        width: 2,
                                        color: const Color(0xff2DAE00)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'From Approved',
                                        style:
                                            TextStyle(color: Color(0xff2DAE00)),
                                      ),
                                      const SizedBox(
                                        height: 7,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          GestureDetector(
                                            onTap: (){
                                              setState(() {
                                                _isFrist = true;
                                                isFromSearch = false;
                                                permitResponse.permitDetails = filterPermitList(permitData.permitDetails!, "Live");
                                                isFromSearch = true;
                                              });
                                            },
                                            child: Container(
                                              height: 38,
                                              width: 80,
                                              alignment: Alignment.center,
                                              margin: const EdgeInsets.all(1),
                                              padding: const EdgeInsets.all(1),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(4)),
                                                  border: Border.all(
                                                      width: 2,
                                                      color: const Color(
                                                          0xff268903))),
                                              child: RichText(
                                                text: TextSpan(
                                                    style: TextStyle(
                                                        color: Color(0xff268903)),
                                                    children: [
                                                      TextSpan(
                                                          text:
                                                              '${snapshot.data!.live}\n',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize: 14)),
                                                      TextSpan(text: 'Live')
                                                    ]),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: (){
                                              setState(() {
                                                _isFrist = true;
                                                isFromSearch = false;
                                                permitResponse.permitDetails = filterPermitList(permitData.permitDetails!, "Closure Applied");
                                                isFromSearch = true;
                                              });
                                            },
                                            child: Container(
                                              height: 38,
                                              width: 80,
                                              alignment: Alignment.center,
                                              margin: const EdgeInsets.all(1),
                                              padding: const EdgeInsets.all(1),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(4)),
                                                  border: Border.all(
                                                      width: 2,
                                                      color: const Color(
                                                          0xff2DAE00))),
                                              child: RichText(
                                                text: TextSpan(
                                                    style: TextStyle(
                                                        color: Color(0xff2DAE00)),
                                                    children: [
                                                      TextSpan(
                                                          text:
                                                              '${snapshot.data!.closureApplied}\n',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize: 14)),
                                                      TextSpan(
                                                          text: 'Closure Applied',
                                                          style: TextStyle(
                                                              fontSize: 10))
                                                    ]),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: (){
                                              setState(() {
                                                _isFrist = true;
                                                isFromSearch = false;
                                                permitResponse.permitDetails = filterPermitList(permitData.permitDetails!, "Closed");
                                                isFromSearch = true;
                                              });
                                            },
                                            child: Container(
                                              height: 38,
                                              width: 80,
                                              alignment: Alignment.bottomCenter,
                                              margin: const EdgeInsets.all(1),
                                              padding: const EdgeInsets.all(1),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(4)),
                                                  border: Border.all(
                                                      width: 2,
                                                      color: const Color(
                                                          0xff1B6700))),
                                              child: RichText(
                                                text: TextSpan(
                                                    style: TextStyle(
                                                        color: Color(0xff1B6700)),
                                                    children: [
                                                      TextSpan(
                                                          text:
                                                              '${snapshot.data!.closed}\n',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize: 14)),
                                                      TextSpan(text: 'Closed')
                                                    ]),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: (){
                                              setState(() {
                                                _isFrist = true;
                                                isFromSearch = false;
                                                permitResponse.permitDetails = filterPermitList(permitData.permitDetails!, "Suspended");
                                                isFromSearch = true;
                                              });
                                            },
                                            child: Container(
                                              height: 38,
                                              width: 80,
                                              alignment: Alignment.center,
                                              margin: const EdgeInsets.all(1),
                                              padding: const EdgeInsets.all(1),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(4)),
                                                  border: Border.all(
                                                      width: 2,
                                                      color: const Color(
                                                          0xffD30000))),
                                              child: RichText(
                                                text: TextSpan(
                                                    style: TextStyle(
                                                        color: Color(0xffD30000)),
                                                    children: [
                                                      TextSpan(
                                                          text:
                                                              '${snapshot.data!.suspended}\n',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize: 14)),
                                                      TextSpan(text: 'Suspended')
                                                    ]),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            userProfile == "3"
                                ? Card(
                                    elevation: 3,
                                    child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: 1),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(4)),
                                        ),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'State : $state',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                                Text(
                                                  'PA : $project_area',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                              ],
                                            ),
                                            const Divider(
                                              height: 1,
                                              thickness: 1,
                                              color: Colors.black,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'GA     : $geo_area',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                                Text(
                                                  'CA : $charge_area',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )),
                                  )
                                : Card(
                                    elevation: 3,
                                    child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: 1),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(4)),
                                        ),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: const [
                                                Text(
                                                  'State',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                                Text(
                                                  'GA',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                                Text(
                                                  'PA',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                              ],
                                            ),
                                            const Divider(
                                              height: 1,
                                              thickness: 1,
                                              color: Colors.black,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  state,
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(geo_area,
                                                    textAlign:
                                                        TextAlign.center),
                                                Text(project_area,
                                                    textAlign:
                                                        TextAlign.center),
                                              ],
                                            ),
                                          ],
                                        )),
                                  ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.65,
                              child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: RefreshIndicator(
                                    onRefresh: () {
                                      setState(() {
                                        if( isFromSearch == true){
                                          isFromSearch = false;
                                        }
                                        _isFrist = true;
                                      });

                                      return getPermitDetails(token, fromDate,
                                          toDate, jobDefaultId, tpeDefaultId);
                                    },
                                    child:
                                        snapshot.data!.permitDetails!.length == 0
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Align(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Center(
                                                    child: Text(
                                                      "No Record Found",
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            :  !isFromSearch ? ListView.builder(
                                                itemCount: snapshot.data!
                                                    .permitDetails!.length,
                                                scrollDirection: Axis.vertical,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return GestureDetector(
                                                    onTap: (() {
                                                      Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  PermitDetailsPage(snapshot.data!
                                                                      .permitDetails![
                                                                          index]
                                                                      .id!
                                                                      .toString())));
                                                    }),
                                                    child: Container(
                                                        margin:
                                                            EdgeInsets.fromLTRB(
                                                                0, 0, 0, 5),
                                                        decoration:
                                                            BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4),
                                                                border:
                                                                    Border.all(
                                                                  width: 1,
                                                                  color: (snapshot.data!
                                                                              .permitDetails![
                                                                                  index]
                                                                              .status ==
                                                                          "Pending")
                                                                      ? Color(
                                                                          0xffDA9D00)
                                                                      : (snapshot.data!.permitDetails![index].status ==
                                                                              "Live")
                                                                          ? Color(
                                                                              0xff268903)
                                                                          : (snapshot.data!.permitDetails![index].status == "Rejected")
                                                                              ? const Color(0xffFF0000)
                                                                              : (snapshot.data!.permitDetails![index].status == "Closed")
                                                                                  ? Color(0xff1B6700)
                                                                                  : (snapshot.data!.permitDetails![index].status == "Suspended")
                                                                                      ? Color(0xffD30000)
                                                                                      : (snapshot.data!.permitDetails![index].status == "Recomd. to Suspend")
                                                                                          ? Color(0xffD30000)
                                                                                          : (snapshot.data!.permitDetails![index].status == "Approved")
                                                                                              ? Color(0xff268903)
                                                                                              : (snapshot.data!.permitDetails![index].status == "Closure Applied")
                                                                                                  ? Color(0xff268903)
                                                                                                  : Color(0xffDA9D00),
                                                                )),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          8,
                                                                          5,
                                                                          0,
                                                                          0),
                                                              child: SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.45,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    snapshot.data!.permitDetails![index].permitNumber == null ? Text("") :Text(
                                                                      snapshot.data!
                                                                          .permitDetails![
                                                                              index]
                                                                          .permitNumber!,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                    Text(
                                                                      "Job Desc: ${snapshot.data!.permitDetails![index].jobDecs!}",
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                    Text(
                                                                      "TPE Name: ${snapshot.data!.permitDetails![index].senderName!}",
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                    Text(
                                                                        "Building:  ${snapshot.data!.permitDetails![index].building!}"),
                                                                    Text(
                                                                        "Location: ${snapshot.data!.permitDetails![index].locality!}"),
                                                                    Text(
                                                                        "CA: ${snapshot.data!.permitDetails![index].chargerArea!}"),
                                                                    Text(
                                                                      snapshot.data!
                                                                          .permitDetails![
                                                                              index]
                                                                          .createTime!,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      right: 5,
                                                                      top: 5),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .end,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Container(
                                                                        width:
                                                                            12,
                                                                        height:
                                                                            12,
                                                                        decoration: BoxDecoration(
                                                                            color: (snapshot.data!.permitDetails![index].status == "Pending")
                                                                                ? Color(0xffDA9D00)
                                                                                : (snapshot.data!.permitDetails![index].status == "Live")
                                                                                    ? Color(0xff268903)
                                                                                    : (snapshot.data!.permitDetails![index].status == "Rejected")
                                                                                        ? const Color(0xffFF0000)
                                                                                        : (snapshot.data!.permitDetails![index].status == "Closed")
                                                                                            ? Color(0xff1B6700)
                                                                                            : (snapshot.data!.permitDetails![index].status == "Suspended")
                                                                                                ? Color(0xffD30000)
                                                                                                : (snapshot.data!.permitDetails![index].status == "Recomd. to Suspend")
                                                                                                    ? Color(0xffD30000)
                                                                                                    : (snapshot.data!.permitDetails![index].status == "Approved")
                                                                                                        ? Color(0xff268903)
                                                                                                        : (snapshot.data!.permitDetails![index].status == "Closure Applied")
                                                                                                            ? Color(0xff268903)
                                                                                                            : Color(0xffDA9D00),
                                                                            borderRadius: BorderRadius.all(Radius.circular(6))),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            4,
                                                                      ),
                                                                      Text(
                                                                        snapshot.data!
                                                                            .permitDetails![index].status!,
                                                                        style: TextStyle(
                                                                            overflow: TextOverflow.fade,
                                                                            color: (snapshot.data!.permitDetails![index].status == "Pending")
                                                                                ? Color(0xffDA9D00)
                                                                                : (snapshot.data!.permitDetails![index].status == "Live")
                                                                                    ? Color(0xff268903)
                                                                                    : (snapshot.data!.permitDetails![index].status == "Rejected")
                                                                                        ? const Color(0xffFF0000)
                                                                                        : (snapshot.data!.permitDetails![index].status == "Closed")
                                                                                            ? Color(0xff1B6700)
                                                                                            : (snapshot.data!.permitDetails![index].status == "Suspended")
                                                                                                ? Color(0xffD30000)
                                                                                                : (snapshot.data!.permitDetails![index].status == "Recomd. to Suspend")
                                                                                                    ? Color(0xffD30000)
                                                                                                    : (snapshot.data!.permitDetails![index].status == "Approved")
                                                                                                        ? Color(0xff268903)
                                                                                                        : (snapshot.data!.permitDetails![index].status == "Closure Applied")
                                                                                                            ? Color(0xff268903)
                                                                                                            : Color(0xffDA9D00),
                                                                            fontWeight: FontWeight.w600),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      )
                                                                    ],
                                                                  ),
                                                                  snapshot.data!.permitDetails![index].status! !=
                                                                          "Pending"
                                                                      ? Text(
                                                                      snapshot.data!
                                                                              .permitDetails![
                                                                                  index]
                                                                              .statusTime!,
                                                                          style:
                                                                              TextStyle(
                                                                            color: (snapshot.data!.permitDetails![index].status == "Pending")
                                                                                ? Color(0xffDA9D00)
                                                                                : (snapshot.data!.permitDetails![index].status == "Live")
                                                                                    ? Color(0xff268903)
                                                                                    : (snapshot.data!.permitDetails![index].status == "Rejected")
                                                                                        ? const Color(0xffFF0000)
                                                                                        : (snapshot.data!.permitDetails![index].status == "Closed")
                                                                                            ? Color(0xff1B6700)
                                                                                            : (snapshot.data!.permitDetails![index].status == "Suspended")
                                                                                                ? Color(0xffD30000)
                                                                                                : (snapshot.data!.permitDetails![index].status == "Recomd. to Suspend")
                                                                                                    ? Color(0xffD30000)
                                                                                                    : (snapshot.data!.permitDetails![index].status == "Approved")
                                                                                                        ? Color(0xff268903)
                                                                                                        : (snapshot.data!.permitDetails![index].status == "Closure Applied")
                                                                                                            ? Color(0xff268903)
                                                                                                            : Color(0xffDA9D00),
                                                                          ))
                                                                      : Container()
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                  );
                                                },
                                              )
                                            : permitResponse
                                            .permitDetails!.length !=0 ?ListView.builder(
                                  itemCount: permitResponse
                                      .permitDetails!.length,
                                    scrollDirection: Axis.vertical,
                                    itemBuilder:
                                        (BuildContext context,
                                        int index) {
                                      return GestureDetector(
                                        onTap: (() {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PermitDetailsPage(permitResponse
                                                          .permitDetails![
                                                      index]
                                                          .id!
                                                          .toString())));
                                        }),
                                        child: Container(
                                            margin:
                                            EdgeInsets.fromLTRB(
                                                0, 0, 0, 5),
                                            decoration:
                                            BoxDecoration(
                                                borderRadius:
                                                BorderRadius
                                                    .circular(
                                                    4),
                                                border:
                                                Border.all(
                                                  width: 1,
                                                  color: (permitResponse
                                                      .permitDetails![
                                                  index]
                                                      .status ==
                                                      "Pending")
                                                      ? Color(
                                                      0xffDA9D00)
                                                      : (permitResponse.permitDetails![index].status ==
                                                      "Live")
                                                      ? Color(
                                                      0xff268903)
                                                      : (permitResponse.permitDetails![index].status == "Rejected")
                                                      ? const Color(0xffFF0000)
                                                      : (permitResponse.permitDetails![index].status == "Closed")
                                                      ? Color(0xff1B6700)
                                                      : (permitResponse.permitDetails![index].status == "Suspended")
                                                      ? Color(0xffD30000)
                                                      : (permitResponse.permitDetails![index].status == "Recomd. to Suspend")
                                                      ? Color(0xffD30000)
                                                      : (permitResponse.permitDetails![index].status == "Approved")
                                                      ? Color(0xff268903)
                                                      : (permitResponse.permitDetails![index].status == "Closure Applied")
                                                      ? Color(0xff268903)
                                                      : Color(0xffDA9D00),
                                                )),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Padding(
                                                  padding:
                                                  EdgeInsets
                                                      .fromLTRB(
                                                      8,
                                                      5,
                                                      0,
                                                      0),
                                                  child: SizedBox(
                                                    width: MediaQuery.of(
                                                        context)
                                                        .size
                                                        .width *
                                                        0.45,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        permitResponse.permitDetails![index].permitNumber == null ? Text("") :Text(
                                                          permitResponse
                                                              .permitDetails![
                                                          index]
                                                              .permitNumber!,
                                                          style:
                                                          TextStyle(
                                                            fontSize:
                                                            14,
                                                            fontWeight:
                                                            FontWeight.bold,
                                                          ),
                                                          overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Text(
                                                          "Job Desc: ${permitResponse.permitDetails![index].jobDecs!}",
                                                          overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Text(
                                                          "TPE Name: ${permitResponse.permitDetails![index].senderName!}",
                                                          overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Text(
                                                            "Building:  ${permitResponse.permitDetails![index].building!}"),
                                                        Text(
                                                            "Location: ${permitResponse.permitDetails![index].locality!}"),
                                                        Text(
                                                            "CA: ${permitResponse.permitDetails![index].chargerArea!}"),
                                                        Text(
                                                          permitResponse
                                                              .permitDetails![
                                                          index]
                                                              .createTime!,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets
                                                      .only(
                                                      right: 5,
                                                      top: 5),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .end,
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width:
                                                            12,
                                                            height:
                                                            12,
                                                            decoration: BoxDecoration(
                                                                color: (permitResponse.permitDetails![index].status == "Pending")
                                                                    ? Color(0xffDA9D00)
                                                                    : (permitResponse.permitDetails![index].status == "Live")
                                                                    ? Color(0xff268903)
                                                                    : (permitResponse.permitDetails![index].status == "Rejected")
                                                                    ? const Color(0xffFF0000)
                                                                    : (permitResponse.permitDetails![index].status == "Closed")
                                                                    ? Color(0xff1B6700)
                                                                    : (permitResponse.permitDetails![index].status == "Suspended")
                                                                    ? Color(0xffD30000)
                                                                    : (permitResponse.permitDetails![index].status == "Recomd. to Suspend")
                                                                    ? Color(0xffD30000)
                                                                    : (permitResponse.permitDetails![index].status == "Approved")
                                                                    ? Color(0xff268903)
                                                                    : (permitResponse.permitDetails![index].status == "Closure Applied")
                                                                    ? Color(0xff268903)
                                                                    : Color(0xffDA9D00),
                                                                borderRadius: BorderRadius.all(Radius.circular(6))),
                                                          ),
                                                          SizedBox(
                                                            width:
                                                            4,
                                                          ),
                                                          Text(
                                                            permitResponse
                                                                .permitDetails![index]
                                                                .status!,
                                                            style: TextStyle(
                                                                overflow: TextOverflow.fade,
                                                                color: (permitResponse.permitDetails![index].status == "Pending")
                                                                    ? Color(0xffDA9D00)
                                                                    : (permitResponse.permitDetails![index].status == "Live")
                                                                    ? Color(0xff268903)
                                                                    : (permitResponse.permitDetails![index].status == "Rejected")
                                                                    ? const Color(0xffFF0000)
                                                                    : (permitResponse.permitDetails![index].status == "Closed")
                                                                    ? Color(0xff1B6700)
                                                                    : (permitResponse.permitDetails![index].status == "Suspended")
                                                                    ? Color(0xffD30000)
                                                                    : (permitResponse.permitDetails![index].status == "Recomd. to Suspend")
                                                                    ? Color(0xffD30000)
                                                                    : (permitResponse.permitDetails![index].status == "Approved")
                                                                    ? Color(0xff268903)
                                                                    : (permitResponse.permitDetails![index].status == "Closure Applied")
                                                                    ? Color(0xff268903)
                                                                    : Color(0xffDA9D00),
                                                                fontWeight: FontWeight.w600),
                                                          ),
                                                          SizedBox(
                                                            height:
                                                            10,
                                                          )
                                                        ],
                                                      ),
                                                      permitResponse.permitDetails![index].status! !=
                                                          "Pending"
                                                          ? Text(
                                                          permitResponse
                                                              .permitDetails![
                                                          index]
                                                              .statusTime!,
                                                          style:
                                                          TextStyle(
                                                            color: (permitResponse.permitDetails![index].status == "Pending")
                                                                ? Color(0xffDA9D00)
                                                                : (permitResponse.permitDetails![index].status == "Live")
                                                                ? Color(0xff268903)
                                                                : (permitResponse.permitDetails![index].status == "Rejected")
                                                                ? const Color(0xffFF0000)
                                                                : (permitResponse.permitDetails![index].status == "Closed")
                                                                ? Color(0xff1B6700)
                                                                : (permitResponse.permitDetails![index].status == "Suspended")
                                                                ? Color(0xffD30000)
                                                                : (permitResponse.permitDetails![index].status == "Recomd. to Suspend")
                                                                ? Color(0xffD30000)
                                                                : (permitResponse.permitDetails![index].status == "Approved")
                                                                ? Color(0xff268903)
                                                                : (permitResponse.permitDetails![index].status == "Closure Applied")
                                                                ? Color(0xff268903)
                                                                : Color(0xffDA9D00),
                                                          ))
                                                          : Container()
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )),
                                      );
                                    },
                                  ):Padding(
                                          padding:
                                          const EdgeInsets.all(8.0),
                                          child: Align(
                                            alignment:
                                            Alignment.topCenter,
                                            child: Center(
                                              child: Text(
                                                "No Record Found",
                                                style: TextStyle(
                                                    fontSize: 20),
                                              ),
                                            ),
                                          ),
                                        ) ,
                                  )),
                            )
                          ],
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Visibility(
                          visible: _isFrist = true,
                          child: Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.orangeAccent),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.white,
                                    semanticsValue: "2",
                                    semanticsLabel: "Loading...",
                                    backgroundColor: Colors.blueGrey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Visibility(
                        visible: _isFrist = true,
                        child: Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.orangeAccent),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: Colors.white,
                                  semanticsValue: "2",
                                  semanticsLabel: "Loading...",
                                  backgroundColor: Colors.blueGrey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                },
              )),
        ),
        floatingActionButton: (userProfile == "3") ? SizedBox(
                height: 50,
                width: 150,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const Permit()));
                  },
                  backgroundColor: const Color(0xffF5A443),
                  icon: const Icon(
                    Icons.add_box_outlined,
                    size: 28,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "New Permit",
                    textAlign: TextAlign.end,
                    style:
                        TextStyle(fontSize: 16, height: 1, color: Colors.white),
                  ),
                  shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(2)),
                  tooltip: "New Permit",
                ),
              )
            : null,
      ),
    );
  }


  _logout() async {
    sharedPreferences = await SharedPreferences.getInstance();

    sharedPreferences.setBool("is_Login", false);
    sharedPreferences.setString("user_name", "");
    sharedPreferences.setString("degination", "");
    sharedPreferences.setString("mobile", "");
    sharedPreferences.setString("email", "");
    sharedPreferences.setString("state", "");
    sharedPreferences.setString("GA", "");
    sharedPreferences.setString("PA", "");
    sharedPreferences.setString("Authentication_token", "");
    sharedPreferences.setString("user_profile", "");
    final forgetResponse = await http.get(
        Uri.parse(url),
        headers: {
          'authorization': token,
          'Content-Type':
          'application/json; charset=UTF-8',
        }
        );
    if(forgetResponse.statusCode == 200){
      try{
        var data = jsonDecode(forgetResponse.body);
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(
                builder: (context) =>
                const LoginPage()),(Route<dynamic> route) => false);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Logout")));
      } on Exception catch(_){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Logout")));
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something Wrong")));
    }
  }
}
