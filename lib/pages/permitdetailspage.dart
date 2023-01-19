import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:perwha/model/PermitDocuments.dart';
import 'package:perwha/model/UpdatePermit.dart';
import 'package:perwha/pages/image_view.dart';
import 'package:perwha/utils/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/repo.dart';
import 'homepage.dart';

class PermitDetailsPage extends StatefulWidget {
  PermitDetailsPage(this.id, {super.key});

  String id;

  @override
  State<PermitDetailsPage> createState() => _PermitDetailsPageState();
}

class _PermitDetailsPageState extends State<PermitDetailsPage> {
  PageController controller = PageController();
  late TextEditingController remarksController;
  var approvedItemsCount = 0;
  var closureItemsCount = 0;
  int photoLength = 0;
  bool _isVisible = false;
  bool _isRemarksEmpty = false;
  bool photos = false;
  double fill = 10;
  double fill2 = 20;
  final List<bool> _selectedButtons = <bool>[true, false];
  late final ScrollBehavior? scrollBehavior;
  late SharedPreferences sharedPreferences;
  String token = "";
  String userProfile = "";
  late Dialog aproveDialog;
  late bool _isFirst = false;
  bool permitImg = true;
  bool closureImg = false;
  List<File> imageList = [];
  String state = "";
  String geo_area = "";
  String project_area = "";
  String charge_area = "";
  List clouserPhotoList = [
    "Site Photo 1",
    "Site Photo 2",
    "Site Photo 3",
    "Site Photo 4"
  ];
  final ImagePicker _picker = ImagePicker();

  void setImageSection() {
    for (int i = 0; i < 4; i++) {
      imageList.add(File(""));
    }
  }

  void takephoto(int index) async {
    var imgFile = await _picker.pickImage(source: ImageSource.camera);
    File compressedFile = (await FlutterImageCompress.compressWithFile(imgFile!.path)) as File;
    // File compressedFile = await FlutterNativeImage.compressImage(imgFile!.path,
    //     percentage: 0,
    //     quality: 50,
    //     targetWidth: 600,
    //     targetHeight: 600);

    setState(() {
      int imgLength = 0;
      imageList[index] = File(compressedFile.path);
      var i = 0;
      for (var image in imageList) {
        if (image.path.isNotEmpty) {
          imgLength++;
        }
      }
      photoLength = imgLength;
      if (photoLength == 4) {
        photos = true;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    remarksController = TextEditingController();
    remarksController.addListener(() {
      setState(() {
        _isRemarksEmpty = remarksController.text.isNotEmpty;
      });
    });
    _isFirst = true;
    _showSavedValue();
    setImageSection();
  }

  _showSavedValue() async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool('boolValue', true);
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
  Widget build(BuildContext context) {
    print(userProfile);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.orange, // Note RED here
      ),
    );
    List<Widget> pager = <Widget>[];
    List<Widget> pager2 = <Widget>[];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            "Permit Details ",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Stack(children: [
            Container(
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xffFFF7E1), Color(0xffFFFFEF)],
                      end: Alignment.topCenter,
                      begin: Alignment.bottomCenter)),
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FutureBuilder<PermitDocuments>(
                          future: _isFirst
                              ? getdocumentbypermitid(widget.id, token)
                              : null,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              print(dateFormater(
                                  DateTime.parse(dateFormater2(
                                      snapshot.data!.submittedDate!,
                                      "dd MMM yyyy")),
                                  "dd MMM yyyy"));
                              List<Widget> buttonName = <Widget>[
                                Text("Approved($approvedItemsCount)"),
                                Text("Closure($closureItemsCount)")
                              ];
                              _isFirst = false;
                              approvedItemsCount =
                                  snapshot.data!.permitImgData!.length;
                              closureItemsCount =
                                  snapshot.data!.closureImgData!.length;

                              for (var permidImg
                                  in snapshot.data!.permitImgData!) {
                                if (!pager.contains(SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: 320,
                                  child: GestureDetector(
                                    onTap: (() {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => ImageView(
                                                    "Permit Image",
                                                    permitImgData: snapshot
                                                        .data!.permitImgData!,
                                                  )));
                                    }),
                                    child: CachedNetworkImage(
                                      imageUrl: permidImg.image!,
                                      progressIndicatorBuilder: (context, url,
                                              downloadProgress) =>
                                          SizedBox(
                                              height: 30,
                                              width: 30,
                                              child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          value:
                                                              downloadProgress
                                                                  .progress))),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ))) {
                                  pager.add(GestureDetector(
                                    onTap: (() {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => ImageView(
                                                    "Permit Image",
                                                    permitImgData: snapshot
                                                        .data!.permitImgData!,
                                                  )));
                                    }),
                                    child: CachedNetworkImage(
                                      imageUrl: permidImg.image!,
                                      progressIndicatorBuilder: (context, url,
                                              downloadProgress) =>
                                          SizedBox(
                                              height: 30,
                                              width: 30,
                                              child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          value:
                                                              downloadProgress
                                                                  .progress))),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                      fit: BoxFit.cover,
                                    ),
                                  ));
                                }
                              }

                              for (var closureIdImg
                                  in snapshot.data!.closureImgData!) {
                                if (!pager2.contains(GestureDetector(
                                  onTap: (() {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => ImageView(
                                                  "Closure Image",
                                                  permitImgData: snapshot
                                                      .data!.permitImgData!,
                                                )));
                                  }),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 320,
                                    child: CachedNetworkImage(
                                      imageUrl: closureIdImg.image!,
                                      fit: BoxFit.fill,
                                      progressIndicatorBuilder: (context, url,
                                              downloadProgress) =>
                                          SizedBox(
                                              height: 30,
                                              width: 30,
                                              child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          value:
                                                              downloadProgress
                                                                  .progress))),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                ))) {
                                  pager2.add(
                                    GestureDetector(
                                      onTap: (() {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) => ImageView(
                                                      "Closure Image",
                                                      closureImgData: snapshot
                                                          .data!
                                                          .closureImgData!,
                                                    )));
                                      }),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 320,
                                        child: CachedNetworkImage(
                                            fit: BoxFit.fill,
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                SizedBox(
                                                    height: 30,
                                                    width: 30,
                                                    child: Center(
                                                        child: CircularProgressIndicator(
                                                            value:
                                                                downloadProgress
                                                                    .progress))),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                            imageUrl: closureIdImg.image!),
                                      ),
                                    ),
                                  );
                                }
                              }
                              return Column(children: [
                                userProfile == "3"
                                    ? Card(
                                        elevation: 3,
                                        child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 1),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(4)),
                                            ),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'State : $state',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                                    Text(
                                                      'PA : $project_area',
                                                      textAlign:
                                                          TextAlign.center,
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
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                                    Text(
                                                      'CA : $charge_area',
                                                      textAlign:
                                                          TextAlign.center,
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
                                                  color: Colors.black,
                                                  width: 1),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(4)),
                                            ),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: const [
                                                    Text(
                                                      'State',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                                    Text(
                                                      'GA',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                                    Text(
                                                      'PA',
                                                      textAlign:
                                                          TextAlign.center,
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
                                                      textAlign:
                                                          TextAlign.center,
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
                                  height: 320,
                                  child: Stack(children: [
                                    Visibility(
                                      visible: permitImg,
                                      child: PageView(
                                        children: pager,
                                        onPageChanged: (index) {
                                          var length = index;
                                          setState(() => {
                                                fill = (length + 1) * 10,
                                              });
                                        },
                                        scrollDirection: Axis.horizontal,
                                        controller: controller,
                                      ),
                                    ),
                                    Visibility(
                                      visible: closureImg,
                                      child: PageView(
                                        children: pager2,
                                        onPageChanged: (index) {
                                          var length = index;
                                          setState(() => {
                                                fill2 = (length + 1) * 20,
                                              });
                                        },
                                        scrollDirection: Axis.horizontal,
                                        controller: controller,
                                      ),
                                    ),
                                  ]),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Stack(
                                  // alignment: Alignment.center,
                                  children: [
                                    Container(
                                      height: 6,
                                      width: permitImg
                                          ? pager.length * 10
                                          : pager2.length * 20,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1, color: Colors.orange),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(5))),
                                    ),
                                    Container(
                                      height: 6,
                                      width: permitImg ? fill : fill2,
                                      decoration: const BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5))),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                ToggleButtons(
                                    direction: Axis.horizontal,
                                    onPressed: (int index) {
                                      setState(() {
                                        if (index == 0) {
                                          fill = 10;
                                          permitImg = true;
                                          closureImg = false;
                                        } else if (index == 1) {
                                          if (snapshot.data!.closureImgData!
                                              .isNotEmpty) {
                                            fill2 = 20;
                                            permitImg = false;
                                            closureImg = true;
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "No Images in Closure")));
                                          }
                                        }
                                        for (int i = 0;
                                            i < _selectedButtons.length;
                                            i++) {
                                          if (i == index) {
                                            _selectedButtons[i] = true;
                                          } else {
                                            _selectedButtons[i] = false;
                                          }
                                        }
                                      });
                                    },
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20)),
                                    selectedBorderColor:
                                        const Color(0xffF5A443),
                                    selectedColor: const Color(0xffF5A443),
                                    fillColor: const Color.fromARGB(
                                        255, 218, 226, 231),
                                    color: const Color(0xff263238),
                                    constraints: const BoxConstraints(
                                      minHeight: 40.0,
                                      minWidth: 150.0,
                                    ),
                                    isSelected: _selectedButtons,
                                    children: [
                                      Text("Approved($approvedItemsCount)"),
                                      Text("Closure($closureItemsCount)")
                                    ]),
                                SizedBox(
                                  height: 12,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          23, 0, 0, 0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Submitted on',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(snapshot.data!.submittedDate!)
                                        ],
                                      ),
                                    ),
                                    snapshot.data!.permitStatus! != "Pending"
                                        ? Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 30, 0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  'Action on',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Text(snapshot.data!.actionDate!)
                                              ],
                                            ),
                                          )
                                        : Container()
                                  ],
                                ),
                                const SizedBox(
                                  height: 14,
                                ),
                                Container(
                                  margin: EdgeInsets.all(8),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: const Color(0x40D9D9D9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              snapshot.data!.permitNo!,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              "TPE Name: ${snapshot.data!.name!}",
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                            Text(
                                              "Job Desc.: ${snapshot.data!.jobDescription!}",
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                            Text(
                                              "Building: ${snapshot.data!.building!}",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            Text(
                                              "Location: ${snapshot.data!.locality!}",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            Text(
                                              "CA: ${snapshot.data!.charge_area!}",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                    color: (snapshot.data!
                                                                .permitStatus! ==
                                                            "Pending")
                                                        ? Color(0xffDA9D00)
                                                        : (snapshot.data!
                                                                    .permitStatus! ==
                                                                "Live")
                                                            ? Color(0xff268903)
                                                            : (snapshot.data!
                                                                        .permitStatus! ==
                                                                    "Rejected")
                                                                ? const Color(
                                                                    0xffFF0000)
                                                                : (snapshot.data!
                                                                            .permitStatus! ==
                                                                        "Closed")
                                                                    ? Color(
                                                                        0xff1B6700)
                                                                    : (snapshot.data!.permitStatus! ==
                                                                            "Suspended")
                                                                        ? Color(
                                                                            0xffD30000)
                                                                        : (snapshot.data!.permitStatus! ==
                                                                                "Recomd. to Suspend")
                                                                            ? Color(0xffD30000)
                                                                            : (snapshot.data!.permitStatus! == "Approved")
                                                                                ? Color(0xff268903)
                                                                                : (snapshot.data!.permitStatus! == "Closure Applied")
                                                                                    ? Color(0xff268903)
                                                                                    : Color(0xffDA9D00),
                                                    borderRadius: BorderRadius.all(Radius.circular(6))),
                                              ),
                                              const SizedBox(
                                                width: 0,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  snapshot.data!.permitStatus!,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: (snapshot.data!
                                                                  .permitStatus! ==
                                                              "Pending")
                                                          ? Color(0xffDA9D00)
                                                          : (snapshot.data!
                                                                      .permitStatus! ==
                                                                  "Live")
                                                              ? Color(
                                                                  0xff268903)
                                                              : (snapshot.data!
                                                                          .permitStatus! ==
                                                                      "Rejected")
                                                                  ? const Color(
                                                                      0xffFF0000)
                                                                  : (snapshot.data!
                                                                              .permitStatus! ==
                                                                          "Closed")
                                                                      ? Color(
                                                                          0xff1B6700)
                                                                      : (snapshot.data!.permitStatus! ==
                                                                              "Suspended")
                                                                          ? Color(
                                                                              0xffD30000)
                                                                          : (snapshot.data!.permitStatus! == "Recomd. to Suspend")
                                                                              ? Color(0xffD30000)
                                                                              : (snapshot.data!.permitStatus! == "Approved")
                                                                                  ? Color(0xff268903)
                                                                                  : (snapshot.data!.permitStatus! == "Closure Applied")
                                                                                      ? Color(0xff268903)
                                                                                      : Color(0xffDA9D00)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(14, 0, 0, 0),
                                  child: Row(
                                    children: const [
                                      Text(
                                        'Remarks Trail',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 1,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                      itemCount:
                                          snapshot.data!.permitRemark!.length,
                                      physics: BouncingScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      itemBuilder: (context, index) {
                                        return  Padding(
                                          padding:
                                          const EdgeInsets.fromLTRB(
                                              12, 12, 12, 0),
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width,
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    Text(
                                                      "${snapshot.data!.permitRemark![index].designationId}: ${snapshot.data!.permitRemark![index].senderBy!}",
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight
                                                              .w500),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .end,
                                                      children: [
                                                        Text(
                                                          dateFormater(
                                                              DateTime.parse(dateFormater2(
                                                                  snapshot
                                                                      .data!
                                                                      .permitRemark![index]
                                                                      .date!,
                                                                  "dd MMM yyyy hh:mm a")),
                                                              "hh:mm a"),
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight
                                                                  .w500),

                                                        ),
                                                        snapshot.data!.permitRemark![index]
                                                            .status! !=
                                                            "Pending"
                                                            ? Text(
                                                          "${snapshot.data!.permitRemark![index].status!}",
                                                          style:
                                                          TextStyle(
                                                            fontWeight:
                                                            FontWeight.w500,
                                                            color: ((snapshot.data!.permitRemark![index].status! == "Live")
                                                                ? Color(0xff268903)
                                                                : (snapshot.data!.permitRemark![index].status! == "Rejected")
                                                                ? const Color(0xffFF0000)
                                                                : (snapshot.data!.permitRemark![index].status! == "Closed")
                                                                ? Color(0xff1B6700)
                                                                : (snapshot.data!.permitRemark![index].status! == "Suspended")
                                                                ? Color(0xffD30000)
                                                                : (snapshot.data!.permitRemark![index].status! == "Recomd. to Suspend")
                                                                ? Color(0xffD30000)
                                                                : (snapshot.data!.permitRemark![index].status! == "Approved")
                                                                ? Color(0xff268903)
                                                                : (snapshot.data!.permitRemark![index].status! == "Closure Applied")
                                                                ? Color(0xff268903)
                                                                : Color(0xffDA9D00)),
                                                          ),
                                                        )
                                                            : Text(
                                                          "Submitted",
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight.w500),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 2,
                                              ),
                                              Container(
                                                width: MediaQuery.of(context).size.width,
                                                decoration: BoxDecoration(
                                                    color: const Color(
                                                        0x40D9D9D9),
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                        8)),
                                                child: Padding(
                                                  padding: EdgeInsets
                                                      .fromLTRB(10, 7,
                                                      10, 12),
                                                  child: Text(
                                                      snapshot
                                                          .data!
                                                          .permitRemark![
                                                      index]
                                                          .remark!,
                                                      style: TextStyle(
                                                          fontSize:
                                                          14)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        //   Row(
                                        //   crossAxisAlignment:
                                        //       CrossAxisAlignment.start,
                                        //   children: [
                                        //     // Padding(
                                        //     //   padding:
                                        //     //       const EdgeInsets.fromLTRB(
                                        //     //           16, 0, 0, 0),
                                        //     //   child: SizedBox(
                                        //     //     width: 25,
                                        //     //     child: Stack(
                                        //     //       alignment: Alignment.center,
                                        //     //       children: [
                                        //     //         Column(
                                        //     //           children: [
                                        //     //             Container(
                                        //     //               width: 1,
                                        //     //               height: 30,
                                        //     //               color: index == 0
                                        //     //                   ? Color(
                                        //     //                       0x00000000)
                                        //     //                   : Colors.black,
                                        //     //             ),
                                        //     //             Container(
                                        //     //               width: 1,
                                        //     //               height: 90,
                                        //     //               color: index ==
                                        //     //                       snapshot
                                        //     //                               .data!
                                        //     //                               .permitRemark!
                                        //     //                               .length -
                                        //     //                           1
                                        //     //                   ? Color(
                                        //     //                       0x00000000)
                                        //     //                   : Colors.black,
                                        //     //             ),
                                        //     //           ],
                                        //     //         ),
                                        //     //         Positioned(
                                        //     //           top: 14,
                                        //     //           child: Container(
                                        //     //             width: 16,
                                        //     //             height: 16,
                                        //     //             decoration:
                                        //     //                 BoxDecoration(
                                        //     //               borderRadius:
                                        //     //                   BorderRadius
                                        //     //                       .circular(10),
                                        //     //               color: const Color(
                                        //     //                   0xffD9D9D9),
                                        //     //             ),
                                        //     //           ),
                                        //     //         ),
                                        //     //       ],
                                        //     //     ),
                                        //     //   ),
                                        //     // ),
                                        //
                                        //   ],
                                        // );
                                      }),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                dateFormater(
                                            DateTime.parse(dateFormater2(
                                                snapshot.data!.submittedDate!,
                                                "dd MMM yyyy")),
                                            "dd MMM yyyy") ==
                                        dateFormater(
                                            DateTime.now(), "dd MMM yyyy")
                                    ? Column(
                                        children: [
                                          userProfile == "1" &&
                                                      snapshot.data!
                                                              .permitStatus! ==
                                                          "Pending" ||
                                                  userProfile == "1" &&
                                                      snapshot.data!
                                                              .permitStatus! ==
                                                          "Recomd. to Suspend" ||
                                                  userProfile == "1" &&
                                                      snapshot.data!
                                                              .permitStatus! ==
                                                          "Closure Applied" ||
                                                  userProfile == "1" &&
                                                      snapshot.data!
                                                              .permitStatus! ==
                                                          "Live"
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: TextField(
                                                    controller:
                                                        remarksController,
                                                    maxLines: 5,
                                                    decoration:
                                                        const InputDecoration(
                                                      filled: true,
                                                      focusColor: Colors.white,
                                                      fillColor: Colors.white,
                                                      border:
                                                          OutlineInputBorder(),
                                                      hintText: 'Remarks',
                                                      labelText: 'Remarks',
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                )
                                              : userProfile == "3" &&
                                                      snapshot.data!
                                                              .permitStatus! ==
                                                          "Live"
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: TextField(
                                                        controller:
                                                            remarksController,
                                                        maxLines: 5,
                                                        decoration:
                                                            const InputDecoration(
                                                          filled: true,
                                                          focusColor:
                                                              Colors.white,
                                                          fillColor:
                                                              Colors.white,
                                                          border:
                                                              OutlineInputBorder(),
                                                          hintText: 'Remarks',
                                                          labelText: 'Remarks',
                                                        ),
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    )
                                                  : Container(),
                                          userProfile == "3" &&
                                                  snapshot.data!.permitStatus ==
                                                      "Live"
                                              ? Padding(
                                                  padding: EdgeInsets.all(5),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text('Photos',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 14,
                                                              )),
                                                          Text('$photoLength/4',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize:
                                                                      14)),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 1,
                                                      ),
                                                      Divider(
                                                        height: 10,
                                                        thickness: 1.5,
                                                        indent: 0,
                                                        endIndent: 0,
                                                        color: Colors.black,
                                                      ),
                                                      InkWell(
                                                        child: Container(
                                                          height: 180,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .black,
                                                                  width: 1),
                                                              borderRadius:
                                                                  const BorderRadius
                                                                          .all(
                                                                      Radius.circular(
                                                                          4))),
                                                          child:
                                                              ListView.builder(
                                                                  scrollDirection:
                                                                      Axis
                                                                          .horizontal,
                                                                  itemCount:
                                                                      clouserPhotoList
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return GestureDetector(
                                                                      onTap:
                                                                          (() =>
                                                                              {
                                                                                takephoto(index)
                                                                              }),
                                                                      child:
                                                                          Container(
                                                                        margin:
                                                                            EdgeInsets.all(8),
                                                                        width:
                                                                            80,
                                                                        height:
                                                                            162,
                                                                        child:
                                                                            DottedBorder(
                                                                          padding:
                                                                              EdgeInsets.all(1),
                                                                          borderType:
                                                                              BorderType.RRect,
                                                                          radius:
                                                                              Radius.circular(8),
                                                                          dashPattern: const [
                                                                            5,
                                                                            5
                                                                          ],
                                                                          color:
                                                                              Colors.grey,
                                                                          strokeWidth:
                                                                              2,
                                                                          child: imageList[index].path == ""
                                                                              ? Container(
                                                                                  width: 80,
                                                                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                                  child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                                    const Icon(Icons.add, size: 32),
                                                                                    Text(clouserPhotoList[index], textAlign: TextAlign.center, style: const TextStyle(fontSize: 13))
                                                                                  ]),
                                                                                )
                                                                              : ClipRRect(
                                                                                  borderRadius: BorderRadius.circular(8),
                                                                                  child: SizedBox(width: 80, height: 162, child: Image.file(imageList[index])),
                                                                                ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              : Container(),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          SizedBox(
                                            height: 40,
                                            width: 326,
                                            child:
                                                userProfile == "3" &&
                                                        snapshot.data!.permitStatus! ==
                                                            "Live"
                                                    ? ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                            primary: const Color(
                                                                0xFF268903)),
                                                        onPressed:
                                                            _isRemarksEmpty &&
                                                                    photos
                                                                ? () {
                                                                    aproveDialog =
                                                                        Dialog(
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(12.0)),
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            MediaQuery.of(context).size.width *
                                                                                8,
                                                                        height:
                                                                            200,
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(16.0),
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              Text(
                                                                                "Are you sure, you want to proceed with the “Action Details”? Action Details can’t be modified after submission.",
                                                                                style: TextStyle(fontSize: 20),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 12,
                                                                              ),
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                children: [
                                                                                  ElevatedButton(
                                                                                    style: ElevatedButton.styleFrom(primary: Color(0xffF5A443)),
                                                                                    onPressed: () async {
                                                                                      Navigator.of(context).pop();
                                                                                      setState(() {
                                                                                        _isVisible = true;
                                                                                      });
                                                                                      var d = dio.Dio();
                                                                                      dio.FormData formData = dio.FormData.fromMap({
                                                                                        "permit_id": snapshot.data!.id!,
                                                                                        "remark": remarksController.text,
                                                                                        "site_photo1": await dio.MultipartFile.fromFile(imageList[0].path, filename: imageList[0].path.split('/').last, contentType: MediaType('image', 'jpg')),
                                                                                        "site_photo2": await dio.MultipartFile.fromFile(imageList[1].path, filename: imageList[1].path.split('/').last, contentType: MediaType('image', 'jpg')),
                                                                                        "site_photo3": await dio.MultipartFile.fromFile(imageList[2].path, filename: imageList[2].path.split('/').last, contentType: MediaType('image', 'jpg')),
                                                                                        "site_photo4": await dio.MultipartFile.fromFile(imageList[3].path, filename: imageList[3].path.split('/').last, contentType: MediaType('image', 'jpg')),
                                                                                        'type': 'image/jpg'
                                                                                      });

                                                                                      dio.Response response = await d.post('http://mngl.intileo.com/api/closePermitDetails',
                                                                                          data: formData,
                                                                                          options: Options(sendTimeout: 120000, receiveTimeout: 120000, headers: {
                                                                                            'Accept': '*/*',
                                                                                            'Content-Type': 'multipart/form-data; boundary=<calculated when request is sent>',
                                                                                            'authorization': token,
                                                                                          }));

                                                                                      setState(() {
                                                                                        if (response.requestOptions.connectTimeout > 0) {
                                                                                          setState(() {
                                                                                            _isVisible = false;
                                                                                          });
                                                                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Connection Timeout try again.")));
                                                                                        }

                                                                                        if (response.statusCode == 200) {
                                                                                          try {
                                                                                            var data = UpdatePermit.fromJson(response.data);
                                                                                            setState(() {
                                                                                              _isVisible = false;
                                                                                            });

                                                                                            if (data.status!) {
                                                                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Closure applied")));
                                                                                              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage()), (route) => false);
                                                                                            } else {
                                                                                              _isVisible = false;
                                                                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something went wrong, try again!")));
                                                                                            }
                                                                                          } on Exception catch (_) {
                                                                                            setState(() {
                                                                                              _isVisible = false;
                                                                                              const SnackBar(content: Text("Something went wrong, try again!"));
                                                                                            });
                                                                                          }
                                                                                        } else {
                                                                                          setState(() {
                                                                                            _isVisible = false;
                                                                                          });
                                                                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something went wrong, try again!")));
                                                                                        }
                                                                                        if (response.statusCode == 429) {
                                                                                          setState(() {
                                                                                            _isVisible = false;
                                                                                          });
                                                                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something went wrong, try again!")));
                                                                                        }
                                                                                      });
                                                                                    },
                                                                                    child: Text(
                                                                                      'Yes',
                                                                                      style: TextStyle(color: Colors.white),
                                                                                    ),
                                                                                  ),
                                                                                  ElevatedButton(
                                                                                      style: ElevatedButton.styleFrom(primary: Color(0xffF5A443)),
                                                                                      onPressed: () {
                                                                                        Navigator.of(context).pop(MaterialPageRoute(builder: (context) => const HomePage()));
                                                                                      },
                                                                                      child: Text(
                                                                                        'No',
                                                                                        style: TextStyle(color: Colors.white),
                                                                                      )),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) =>
                                                                                aproveDialog);
                                                                  }
                                                                : null,
                                                        child: const Text(
                                                          "Apply for Closure",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ))
                                                    : snapshot.data!.permitStatus! ==
                                                                "Pending" &&
                                                            userProfile == "1"
                                                        ? Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              //Button for Permit Approve
                                                              ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                        primary:
                                                                            Color(0xff268903)),
                                                                onPressed: () {
                                                                  aproveDialog =
                                                                      Dialog(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(12.0)),
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          200,
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(16.0),
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            Text(
                                                                              "Are you sure, you want to proceed with the “Action Details”?\n Action Details can’t be modified after submission.",
                                                                              style: TextStyle(fontSize: 20),
                                                                            ),
                                                                            SizedBox(
                                                                              height: 12,
                                                                            ),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                              children: [
                                                                                ElevatedButton(
                                                                                  style: ElevatedButton.styleFrom(primary: Color(0xffF5A443)),
                                                                                  onPressed: () async {
                                                                                    var remarks;
                                                                                    if (remarksController.text.isEmpty) {
                                                                                      remarksController.text = "N/A";
                                                                                    }
                                                                                    Navigator.pop(context);
                                                                                    setState(() {
                                                                                      _isVisible = true;
                                                                                    });
                                                                                    final Uploaddocuments = await http.post(Uri.parse("http://mngl.intileo.com/api/updatepermitstatus"),
                                                                                        headers: {
                                                                                          'authorization': "${token}",
                                                                                          'Content-Type': 'application/json; charset=UTF-8',
                                                                                        },
                                                                                        body: jsonEncode(<String, dynamic>{
                                                                                          'permit_id': snapshot.data!.id!,
                                                                                          "remark": remarksController.text,
                                                                                          "status_id": "2"
                                                                                        }));
                                                                                    //  var data = UpdatePermit.fromJson(Uploaddocuments.body.toString());
                                                                                    if (Uploaddocuments.statusCode == 200) {
                                                                                      setState(() {
                                                                                        _isVisible = false;
                                                                                      });

                                                                                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage()), (route) => false);
                                                                                      UpdatePermit.fromJson(jsonDecode(Uploaddocuments.body));
                                                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Permit Approved")));
                                                                                    } else {
                                                                                      setState(() {
                                                                                        _isVisible = false;
                                                                                      });
                                                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Somthing Wromg!")));
                                                                                    }
                                                                                  },
                                                                                  child: Text(
                                                                                    'Yes',
                                                                                    style: TextStyle(color: Colors.white),
                                                                                  ),
                                                                                ),
                                                                                ElevatedButton(
                                                                                    style: ElevatedButton.styleFrom(primary: Color(0xffF5A443)),
                                                                                    onPressed: () {
                                                                                      Navigator.of(context).pop(MaterialPageRoute(builder: (context) => const HomePage()));
                                                                                    },
                                                                                    child: Text(
                                                                                      'No',
                                                                                      style: TextStyle(color: Colors.white),
                                                                                    )),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                  showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) =>
                                                                              aproveDialog);
                                                                },
                                                                child: Text(
                                                                  'Approve',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                              //Button for Permit reject
                                                              ElevatedButton(
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                          primary: Color(
                                                                              0xffFF0000)),
                                                                  onPressed:
                                                                      _isRemarksEmpty
                                                                          ? () {
                                                                              aproveDialog = Dialog(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                                                                child: SizedBox(
                                                                                  width: MediaQuery.of(context).size.width * 8,
                                                                                  height: 200,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(16.0),
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(
                                                                                          "Are you sure, you want to proceed with the “Action Details”? Action Details can’t be modified after submission.",
                                                                                          style: TextStyle(fontSize: 20),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          height: 12,
                                                                                        ),
                                                                                        Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                          children: [
                                                                                            ElevatedButton(
                                                                                              style: ElevatedButton.styleFrom(primary: Color(0xffF5A443)),
                                                                                              onPressed: () async {
                                                                                                Navigator.of(context).pop();
                                                                                                setState(() {
                                                                                                  _isVisible = true;
                                                                                                });
                                                                                                final Uploaddocuments = await http.post(Uri.parse("http://mngl.intileo.com/api/updatepermitstatus"),
                                                                                                    headers: {
                                                                                                      'authorization': "${token}",
                                                                                                      'Content-Type': 'application/json; charset=UTF-8',
                                                                                                    },
                                                                                                    body: jsonEncode(<String, dynamic>{
                                                                                                      'permit_id': snapshot.data!.id!,
                                                                                                      "remark": remarksController.text,
                                                                                                      "status_id": "3"
                                                                                                    }));
                                                                                                if (Uploaddocuments.statusCode == 200) {
                                                                                                  _isVisible = false;
                                                                                                  var data = jsonDecode(Uploaddocuments.body);
                                                                                                  print(data);
                                                                                                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage()), (route) => false);
                                                                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Permit Reject")));
                                                                                                  UpdatePermit.fromJson(jsonDecode(Uploaddocuments.body));
                                                                                                } else {
                                                                                                  _isVisible = false;
                                                                                                  throw Exception('Failed to post user.');
                                                                                                }
                                                                                              },
                                                                                              child: Text(
                                                                                                'Yes',
                                                                                                style: TextStyle(color: Colors.white),
                                                                                              ),
                                                                                            ),
                                                                                            ElevatedButton(
                                                                                                style: ElevatedButton.styleFrom(primary: Color(0xffF5A443)),
                                                                                                onPressed: () {
                                                                                                  Navigator.of(context).pop();
                                                                                                },
                                                                                                child: Text(
                                                                                                  'No',
                                                                                                  style: TextStyle(color: Colors.white),
                                                                                                )),
                                                                                          ],
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                              showDialog(context: context, builder: (context) => aproveDialog);
                                                                            }
                                                                          : null,
                                                                  child: Text(
                                                                    'Reject',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                              ),
                                                            ],
                                                          )
                                                        : userProfile == "1" &&
                                                                    snapshot.data!.permitStatus ==
                                                                        "Live" ||
                                                                userProfile == "1" &&
                                                                    snapshot.data!.permitStatus ==
                                                                        "Recomd. to Suspend"
                                                            ? ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                    primary: const Color(
                                                                        0xffD30000)),
                                                                onPressed:
                                                                    _isRemarksEmpty
                                                                        ? () {
                                                                            aproveDialog =
                                                                                Dialog(
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                                                              child: SizedBox(
                                                                                width: MediaQuery.of(context).size.width * 8,
                                                                                height: 200,
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(16.0),
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    children: [
                                                                                      Text(
                                                                                        "Are you sure, you want to proceed with the “Action Details”? Action Details can’t be modified after submission.",
                                                                                        style: TextStyle(fontSize: 20),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        height: 12,
                                                                                      ),
                                                                                      Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                        children: [
                                                                                          ElevatedButton(
                                                                                            style: ElevatedButton.styleFrom(primary: Color(0xffF5A443)),
                                                                                            onPressed: () async {
                                                                                              Navigator.of(context).pop();
                                                                                              setState(() {
                                                                                                _isVisible = true;
                                                                                              });
                                                                                              final Uploaddocuments = await http.post(Uri.parse("http://mngl.intileo.com/api/updatepermitstatus"),
                                                                                                  headers: {
                                                                                                    'authorization': "${token}",
                                                                                                    'Content-Type': 'application/json; charset=UTF-8',
                                                                                                  },
                                                                                                  body: jsonEncode(<String, dynamic>{
                                                                                                    'permit_id': snapshot.data!.id!,
                                                                                                    "remark": remarksController.text,
                                                                                                    "status_id": "8"
                                                                                                  }));
                                                                                              if (Uploaddocuments.statusCode == 200) {
                                                                                                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage()), (route) => false);
                                                                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Permit Suspended")));

                                                                                                setState(() {
                                                                                                  _isVisible = false;
                                                                                                });
                                                                                                UpdatePermit.fromJson(jsonDecode(Uploaddocuments.body));
                                                                                              } else {
                                                                                                throw Exception('Failed to post user.');
                                                                                              }
                                                                                            },
                                                                                            child: Text(
                                                                                              'Yes',
                                                                                              style: TextStyle(color: Colors.white),
                                                                                            ),
                                                                                          ),
                                                                                          ElevatedButton(
                                                                                              style: ElevatedButton.styleFrom(primary: Color(0xffF5A443)),
                                                                                              onPressed: () {
                                                                                                Navigator.of(context).pop(MaterialPageRoute(builder: (context) => const HomePage()));
                                                                                              },
                                                                                              child: Text(
                                                                                                'No',
                                                                                                style: TextStyle(color: Colors.white),
                                                                                              )),
                                                                                        ],
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                            showDialog(
                                                                                context: context,
                                                                                builder: (context) => aproveDialog);
                                                                          }
                                                                        : null,
                                                                child:
                                                                    const Text(
                                                                  "Suspend",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                )
                                                            : snapshot.data!.permitStatus ==
                                                                        "Closure Applied" &&
                                                                    userProfile ==
                                                                        "1"
                                                                ? Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    children: [
                                                                      //Buttons for permit Closed
                                                                      ElevatedButton(
                                                                        style: ElevatedButton.styleFrom(
                                                                            primary:
                                                                                Color(0xff268903)),
                                                                        onPressed: _isRemarksEmpty
                                                                            ? () {
                                                                                aproveDialog = Dialog(
                                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                                                                  child: SizedBox(
                                                                                    width: MediaQuery.of(context).size.width * 8,
                                                                                    height: 200,
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.all(16.0),
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        children: [
                                                                                          Text(
                                                                                            "Are you sure, you want to proceed with the “Action Details”? Action Details can’t be modified after submission.",
                                                                                            style: TextStyle(fontSize: 20),
                                                                                          ),
                                                                                          SizedBox(
                                                                                            height: 12,
                                                                                          ),
                                                                                          Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                            children: [
                                                                                              ElevatedButton(
                                                                                                style: ElevatedButton.styleFrom(primary: Color(0xffF5A443)),
                                                                                                onPressed: () async {
                                                                                                  Navigator.of(context).pop();
                                                                                                  setState(() {
                                                                                                    _isVisible = true;
                                                                                                  });
                                                                                                  final Uploaddocuments = await http.post(Uri.parse("http://mngl.intileo.com/api/updatepermitstatus"),
                                                                                                      headers: {
                                                                                                        'authorization': "${token}",
                                                                                                        'Content-Type': 'application/json; charset=UTF-8',
                                                                                                      },
                                                                                                      body: jsonEncode(<String, dynamic>{
                                                                                                        'permit_id': snapshot.data!.id!,
                                                                                                        "remark": remarksController.text,
                                                                                                        "status_id": "6"
                                                                                                      }));
                                                                                                  if (Uploaddocuments.statusCode == 200) {
                                                                                                    setState(() {
                                                                                                      _isVisible = false;
                                                                                                    });
                                                                                                    var data = jsonDecode(Uploaddocuments.body);
                                                                                                    print(data);
                                                                                                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage()), (route) => false);
                                                                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Permit Approved")));
                                                                                                    UpdatePermit.fromJson(jsonDecode(Uploaddocuments.body));
                                                                                                  } else {
                                                                                                    throw Exception('Failed to post user.');
                                                                                                  }
                                                                                                },
                                                                                                child: Text(
                                                                                                  'Yes',
                                                                                                  style: TextStyle(color: Colors.white),
                                                                                                ),
                                                                                              ),
                                                                                              ElevatedButton(
                                                                                                  style: ElevatedButton.styleFrom(primary: Color(0xffF5A443)),
                                                                                                  onPressed: () {
                                                                                                    Navigator.of(context).pop();
                                                                                                  },
                                                                                                  child: Text(
                                                                                                    'No',
                                                                                                    style: TextStyle(color: Colors.white),
                                                                                                  )),
                                                                                            ],
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                                showDialog(context: context, builder: (context) => aproveDialog);
                                                                              }
                                                                            : null,
                                                                        child:
                                                                            Text(
                                                                          'Closed',
                                                                          style:
                                                                              TextStyle(color: Colors.white),
                                                                        ),
                                                                      ),
                                                                      //Buttons for permit Closed reject
                                                                      ElevatedButton(
                                                                          style:
                                                                              ElevatedButton.styleFrom(primary: Colors.red),
                                                                          onPressed: _isRemarksEmpty
                                                                              ? () {
                                                                                  aproveDialog = Dialog(
                                                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                                                                    child: SizedBox(
                                                                                      width: MediaQuery.of(context).size.width * 8,
                                                                                      height: 200,
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.all(16.0),
                                                                                        child: Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                                          children: [
                                                                                            Text(
                                                                                              "Are you sure, you want to proceed with the “Action Details”? Action Details can’t be modified after submission.",
                                                                                              style: TextStyle(fontSize: 20),
                                                                                            ),
                                                                                            SizedBox(
                                                                                              height: 12,
                                                                                            ),
                                                                                            Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                              children: [
                                                                                                ElevatedButton(
                                                                                                  style: ElevatedButton.styleFrom(primary: Color(0xffF5A443)),
                                                                                                  onPressed: () async {
                                                                                                    Navigator.of(context).pop();
                                                                                                    setState(() {
                                                                                                      _isVisible = true;
                                                                                                    });
                                                                                                    final Uploaddocuments = await http.post(Uri.parse("http://mngl.intileo.com/api/updatepermitstatus"),
                                                                                                        headers: {
                                                                                                          'authorization': "${token}",
                                                                                                          'Content-Type': 'application/json; charset=UTF-8',
                                                                                                        },
                                                                                                        body: jsonEncode(<String, dynamic>{
                                                                                                          'permit_id': snapshot.data!.id!,
                                                                                                          "remark": remarksController.text,
                                                                                                          "status_id": "2",
                                                                                                          "rework": "Rework"
                                                                                                        }));
                                                                                                    if (Uploaddocuments.statusCode == 200) {
                                                                                                      _isVisible = false;
                                                                                                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage()), (route) => false);
                                                                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Permit sent for rework")));
                                                                                                      UpdatePermit.fromJson(jsonDecode(Uploaddocuments.body));
                                                                                                    } else {
                                                                                                      _isVisible = false;
                                                                                                      throw Exception('Failed to post user.');
                                                                                                    }
                                                                                                  },
                                                                                                  child: Text(
                                                                                                    'Yes',
                                                                                                    style: TextStyle(color: Colors.white),
                                                                                                  ),
                                                                                                ),
                                                                                                ElevatedButton(
                                                                                                    style: ElevatedButton.styleFrom(primary: Color(0xffF5A443)),
                                                                                                    onPressed: () {
                                                                                                      Navigator.of(context).pop();
                                                                                                    },
                                                                                                    child: Text(
                                                                                                      'No',
                                                                                                      style: TextStyle(color: Colors.white),
                                                                                                    )),
                                                                                              ],
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                  showDialog(context: context, builder: (context) => aproveDialog);
                                                                                }
                                                                              : null,
                                                                          child: Text(
                                                                            'Rework',
                                                                            style:
                                                                                TextStyle(color: Colors.white),
                                                                          ),
                                                                      ),
                                                                    ],
                                                                  )
                                                                : null,
                                          ),
                                        ],
                                      )
                                    : Container(),
                                SizedBox(
                                  height: 20,
                                ),
                              ]);
                            } else {
                              return Container(
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                child: CircularProgressIndicator(),
                              );
                            }
                          }),
                    ]),
              ),
            ),
            Visibility(
              visible: _isVisible,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Color(0x4034d3e3),
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
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
