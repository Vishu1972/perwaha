import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as ui;
import 'package:image_picker/image_picker.dart';
import 'package:image_watermark/image_watermark.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:perwha/model/JobDetails.dart';
import 'package:perwha/model/PhotographDetail.dart';
import 'package:perwha/model/UpdatePermit.dart';
import 'package:perwha/pages/homepage.dart';
import 'package:perwha/pages/permitdetailspage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Widgets/message.dart';
import '../main.dart';
import '../model/ChargeAreaDetails.dart';
import '../services/repo.dart';
import '../utils/util.dart';

class Permit extends StatefulWidget {
  const Permit({super.key});

  @override
  State<Permit> createState() => _PermitState();
}

class _PermitState extends State<Permit> {
  String jobDefaultValue = 'Select Job Desc.';
  String jobDefaultId= '';
  String chargeAreaDefaultValue = 'Select Charge Area.';
  String chargeAreaDefaultId = '';
  var chargeAreaItems = ['Select Charge Area.'];
  var jobDescItems = ['Select Job Desc.'];
  late TextEditingController localityController ;
  late TextEditingController buildingController ;
  late TextEditingController remarksController;
  String jobDescID = "", chargeAreaID = "";
  late SharedPreferences sharedPreferences;
  late bool _isVisible = false;
  late bool _isFirst = false;
  late bool _isFirstJob = false;
  late bool _isFirstCa = false;
  String token = "";
  String project_area_id = "";
  var permitData = Map<String, String>();
  String state = "";
  String geo_area = "";
  String project_area = "";
  String userProfile = "";
  String charge_area = "";
  bool job_desc = false;
  bool location = false;
  bool building = false;
  bool remarks = false;
  bool photos = false;

  // var permitImg = List<MultipartFile>.empty();
  // XFile? pictureFile;
  late Permission _permission;

  PermissionStatus _permissionStatus = PermissionStatus.denied;

  late Position _position;
  String _currentAddress = "";

  final ImagePicker _picker = ImagePicker();
  List<File> imageList = [];

  int photoLength = 0;

  void setImageSection() {
    for (int i = 0; i < 8; i++) {
      imageList.add(File(""));
    }
  }

  @override
  void initState() {

    remarksController = TextEditingController();
    remarksController.addListener(() {
      setState(() {
        remarks = remarksController.text.isNotEmpty;
      });
    });
    localityController = TextEditingController();
    localityController.addListener(() {
      setState(() {
        location = localityController.text.isNotEmpty;
      });
    });
    buildingController = TextEditingController();
    buildingController.addListener(() {
      setState(() {
        building = buildingController.text.isNotEmpty;
      });
    });
    _permission = Permission.location;
  //  checkServiceStatus(context, _permission as PermissionWithService);
   // requestPermission(_permission);
    _getCurrentLocation();

    _showSavedValue();
    setImageSection();
    super.initState();
  }

  _showSavedValue() async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool('boolValue', true);
    setState(() {
      //  userProfile = sharedPreferences.getString("user_profile")!;
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
    var size = MediaQuery.of(context).size;
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
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xffFFF7E1), Color(0xffFFFFEF)],
                  end: Alignment.topCenter,
                  begin: Alignment.bottomCenter)),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Stack(children: [
              Column(
                children: [
                  userProfile =="3" ?  Card(
                    elevation: 3,
                    child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border:
                          Border.all(color: Colors.black, width: 1),
                          borderRadius: const BorderRadius.all(
                              Radius.circular(4)),
                        ),
                        width: MediaQuery.of(context).size.width,

                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'State : $state',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  'PA : $project_area',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700),
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
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '    GA : $geo_area',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  'CA : $charge_area',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ],
                        )),
                  )
                      :Card(
                    elevation: 3,
                    child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border:
                          Border.all(color: Colors.black, width: 1),
                          borderRadius: const BorderRadius.all(
                              Radius.circular(4)),
                        ),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'State',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  'GA',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  'PA',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700),
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
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  state,
                                  textAlign: TextAlign.center,
                                ),
                                Text(geo_area,
                                    textAlign: TextAlign.center),
                                Text(project_area,
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          ],
                        )),
                  ),
                  SizedBox(
                    height: 13,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(4))),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: FutureBuilder(
                          future: !_isFirstJob ? getJobDecsList(token) : null,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var jobItems;
                              _isFirstJob = false;
                              for (var jobItem in snapshot.data!.data!) {
                                if (!jobDescItems
                                    .contains(jobItem.description)) {
                                  jobItems = jobItem;
                                  jobDescItems.add(jobItem.description!);
                                }
                              }
                              return DropdownButton<String>(

                                isExpanded: true,
                                value: jobDefaultValue,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: jobDescItems.map((String items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        items,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    jobDefaultValue = val!;
                                    jobDefaultId = snapshot.data!.data![snapshot.data!.data!.indexWhere((element) => element.description == val,0)].id!.toString();
                                    if(jobDefaultId != ""){
                                      job_desc =true;
                                    }
                                  });
                                },
                              );
                            } else {
                              return DropdownButton<String>(
                                isExpanded: true,
                                // Initial Value
                                value: jobDefaultValue,

                                // Down Arrow Icon
                                icon: const Icon(Icons.keyboard_arrow_down),

                                // Array list of items
                                items: jobDescItems.map((String items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        items,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                // After selecting the desired option,it will
                                // change button value to selected value
                                onChanged: (String? newValue) {
                                  setState(() {
                                    jobDefaultValue = newValue!;

                                  });
                                },
                              );
                            }
                          }),
                    ),
                  ),
                  SizedBox(
                    height: 11,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      controller: localityController,
                      decoration: InputDecoration(
                        filled: true,
                        focusColor: Colors.white,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        hintText: 'Enter Locality',
                        labelText: 'Locality',
                      ),
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 13,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      controller: buildingController,
                      decoration: InputDecoration(
                        filled: true,
                        focusColor: Colors.white,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        hintText: 'Enter Building Name',
                        labelText: 'Building / Society Name',
                      ),
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 13,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      controller: remarksController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        filled: true,
                        focusColor: Colors.white,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        hintText: 'Remarks',
                        labelText: 'Remarks',
                      ),
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 17,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Photos',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          )),
                      Text('$photoLength/8',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14)),
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
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 1)),
                      child: FutureBuilder<PhotographDetail>(
                          future:
                              !_isFirst ? getPhotoGraphDetails(token) : null,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              _isFirst = true;
                              return GridView.count(
                                childAspectRatio: (1.65 / 3),
                                shrinkWrap: false,
                                crossAxisCount: 4,
                                children: List.generate(
                                    8, (index) {
                                  return GestureDetector(
                                    onTap: (() => {takephoto(index)}),
                                    child: Container(
                                      margin: EdgeInsets.all(8),
                                      width: 80,
                                      height: 162,
                                      child: DottedBorder(
                                        padding: EdgeInsets.all(1),
                                        borderType: BorderType.RRect,
                                        radius: Radius.circular(8),
                                        dashPattern: [5, 5],
                                        color: Colors.grey,
                                        strokeWidth: 2,
                                        child: imageList[index].path == ""
                                            ? Container(
                                                width: 80,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 4),
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(Icons.add, size: 32),
                                                      Text(
                                                          snapshot
                                                              .data!
                                                              .data![index]
                                                              .description!,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 13))
                                                    ]),
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Container(
                                                    width: 80,
                                                    height: 162,
                                                    child: Image.file(
                                                        imageList[index])),
                                              ),
                                      ),
                                    ),
                                  );
                                }),
                              );
                            } else {
                              return Container(
                                child: Center(
                                  child: Text(
                                    "Please wait...",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              );
                            }
                          }),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Color(0xffF5A443)),
                          onPressed: job_desc && location && building && remarks && photos ? () async {

                            showDialog(context: context, builder: (context) {
                              return  Dialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(12.0)),
                                child:
                                SizedBox(
                                  height: 250,
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
                                          "Are you sure, you want to proceed with the “Permit Details”?\nPermit Details can’t be modified after submission",
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
                                                setState((){
                                                  _isVisible = true;
                                                });
                                                _sendPermit();
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
                            });
                          } : null,
                          child: Text(
                            'Submit',
                            style: TextStyle(color: Colors.white),
                          )),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Color(0xffF5A443)),
                          onPressed: () {
                            Navigator.of(context).pop(MaterialPageRoute(
                                builder: (context) => const HomePage()));
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          )),
                    ],
                  ),
                ],
              ),
              Visibility(
                visible: _isVisible,
                child: Container(
                  color: Color(0x20FF9800),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      )),
    );
  }
  void takephoto(int index) async {
    var imgFile = await _picker.pickImage(source: ImageSource.camera);
    File compressedFile = await FlutterNativeImage.compressImage(imgFile!.path,
        quality: 70, percentage: 70);
    //File wmImage = await addWaterMark(File(compressedFile.path));
    setState(() {
      int imgLength=0;
      imageList[index] = compressedFile;
      var i =0;
      for(var image in imageList){
       if(image.path.isNotEmpty){
      imgLength++;
       }
      }
      photoLength = imgLength;

      if(photoLength == 8){
        photos = true;
      }
    });
  }

  @override
  void didUpdateWidget(Permit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget == widget) {
    } else {}
  }
_sendPermit () async {
  var d = dio.Dio();
  dio.FormData formData = dio.FormData.fromMap({
    "job_id": jobDefaultId,
    "charge_area_id": chargeAreaDefaultId,
    "locality": localityController.text,
    "building": buildingController.text,
    "remarks": remarksController.text,
    "wah_permit": await dio.MultipartFile.fromFile(
        imageList[0].path,
        filename:  imageList[0].path.split('/').last,
        contentType: MediaType('image', 'jpg')),
    "fall_arrester": await dio.MultipartFile.fromFile(
        imageList[1].path,
        filename: imageList[1].path.split('/').last,
        contentType: MediaType('image', 'jpg')),
      "petzel_inspection":
    await dio.MultipartFile.fromFile(
        imageList[2].path,
        filename:
        imageList[2].path.split('/').last,
        contentType: MediaType('image', 'jpg')),
      "plumber_certificatn":
    await dio.MultipartFile.fromFile(
        imageList[3].path,
        filename:
        imageList[3].path.split('/').last,
        contentType: MediaType('image', 'jpg')),
    "emergency_electrical_equipment":
    await dio.MultipartFile.fromFile(
        imageList[4].path,
        filename:
        imageList[4].path.split('/').last,
        contentType: MediaType('image', 'jpg')),
    "site_photo1": await dio.MultipartFile.fromFile(
        imageList[5].path,
        filename: imageList[5].path.split('/').last,
        contentType: MediaType('image', 'jpg')),
    "site_photo2": await dio.MultipartFile.fromFile(
        imageList[6].path,
        filename: imageList[6].path.split('/').last,
        contentType: MediaType('image', 'jpg')),
    "site_photo3": await dio.MultipartFile.fromFile(
        imageList[7].path,
        filename: imageList[7].path.split('/').last,
        contentType: MediaType('image', 'jpg')),
    'type': 'image/jpg'
  });

  dio.Response response = await d.post(
      'http://mngl.intileo.com/api/uploadPermitDetails',
      data: formData,
      options: Options(
          sendTimeout: 10000,
          receiveTimeout: 10000,
          headers: {
            'Accept': '*/*',
            'Content-Type':
            'multipart/form-data; boundary=<calculated when request is sent>',
            'authorization': token,
          }));
  print(response.requestOptions.connectTimeout);

  setState(() {
    if (response.requestOptions.connectTimeout > 0){
      setState(() {
        _isVisible = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("Connection Timeout try again.")));
    }

    if (response.statusCode == 200) {
      try {
        var data = UpdatePermit.fromJson(response.data);
        setState(() {
          _isVisible = false;
        });

        if (data.status!) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Permit submitted")));
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(
              builder: (context) => HomePage()), (route) => false);
        }
        else {
          _isVisible = false;
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Something went wrong, try again! (1)")));
        }
      } on Exception catch (_){
        setState(() {
          _isVisible = false;
          const SnackBar(content: Text("Something went wrong, try again! (2)"));
        });
      }

    }
    else{
      setState((){
        _isVisible = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Something went wrong, try again! (3)")));
    }
    if(response.statusCode == 429){
      setState((){
        _isVisible = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Something went wrong, try again! (4)")));
    }
  }
  );
}
  _getCurrentLocation() {
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _position = position;

        _getAddressFromLatLng();
      });
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _position.latitude, _position.longitude);

      Placemark place = placemarks[0];

      setState(() {
        _currentAddress =
            "${place.name}, ${place.subLocality},\n ${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  void checkServiceStatus(
      BuildContext context, PermissionWithService permission) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text((await permission.serviceStatus).toString()),
    ));
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();

    setState(() {
      _permissionStatus = status;
    });
  }

 Future<File> addWaterMark(File file) async {
    var iByetsIMG;
    var watermarkedImgBytes = null;
    var pictureFile = file;
    if (pictureFile != null) {
      var dateTime = DateTime.now();
      var img = await pictureFile!.readAsBytes();
      var imgFile = File(pictureFile!.path);
      var orignalIMG = ui.decodeImage(imgFile.readAsBytesSync());
      iByetsIMG = Uint8List.fromList(img);
       watermarkedImgBytes = await image_watermark.addTextWatermark(
          iByetsIMG,
          dateFormater(dateTime,"dd-MM-yyyy h:mm a") + "\n" + _currentAddress,
          (orignalIMG!.width / 8).toInt() - 25,
          orignalIMG!.height - 30 - 25,
          ui.arial_14,
          color: Colors.white);

    }
    return File.fromRawPath(watermarkedImgBytes);
    //  File oImage;
    //  File waterMarkedImage;
    //  oImage = file;
    //  ui.Image? imageByte = ui.decodeImage(oImage.readAsBytesSync());
    //  ui.drawString(imageByte!, ui.arial_24, 100, 120, "string");
    //  List<int> wmImage = ui.encodePng(imageByte);
    //  return waterMarkedImage = File.fromRawPath(Uint8List.fromList(wmImage));
  }
}
