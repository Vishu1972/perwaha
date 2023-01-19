import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_watermark/image_watermark.dart';
import 'package:image/image.dart' as ui;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart' as dd;
import 'package:permission_handler/permission_handler.dart';
import 'package:perwha/pages/homepage.dart';
import 'package:perwha/utils/util.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription>? cameras;

  const CameraPage({this.cameras, Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late Permission _permission;
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  late CameraController controller;
  XFile? pictureFile;
  var iByetsIMG;
  var watermarkedImgBytes;
  bool isLoading = false;
  String watermarkText = "", imgname = "image not selected";

  late Position _position;
  String _currentAddress = "";

  @override
  void initState() {
    super.initState();
    _permission = Permission.location;
    checkServiceStatus(context,_permission as PermissionWithService);
    requestPermission(_permission);
    controller = CameraController(
      widget.cameras![0],
      ResolutionPreset.medium,
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return SizedBox(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _getCurrentLocation();

            pictureFile = await controller.takePicture();
            if (pictureFile != null) {
              var dateTime = DateTime.now();
              var img = await pictureFile!.readAsBytes();
              var imgFile = File(pictureFile!.path);
              var orignalIMG = ui.decodeImage(imgFile.readAsBytesSync());
              iByetsIMG = Uint8List.fromList(img);
              watermarkedImgBytes = await image_watermark.addTextWatermark(
                  iByetsIMG,
                  dateFormater(dateTime,"") + "\n" + _currentAddress,
                  (orignalIMG!.width / 8).toInt() - 25,
                  orignalIMG.height - 30 - 25,
                  ui.arial_14,
                  color: Colors.white);
            }
            setState(() {});
          },
          child: Icon(Icons.camera),
        ),
        body: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: CameraPreview(controller),
            ),
            if (pictureFile != null) Stack(

              children: [
              Image.network(pictureFile!.path,height: 200,),
                Image.memory(watermarkedImgBytes),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        style:
                        ElevatedButton.styleFrom(primary: Color(0xffF5A443)),
                        onPressed: () {
                          Navigator.of(context).pop(MaterialPageRoute(
                              builder: (context) => const CameraPage()));
                        },
                        child: Text(
                          'Retake',
                          style: TextStyle(color: Colors.white),
                        )),
                    ElevatedButton(
                        style:
                        ElevatedButton.styleFrom(primary: Color(0xffF5A443)),
                        onPressed: () {
                          Navigator.of(context).pop(MaterialPageRoute(
                              builder: (context) => const HomePage()));
                        },
                        child: Text(
                          'submit',
                          style: TextStyle(color: Colors.white),
                        )),
                  ],
                ),
              ],
            )
            // Image.file(File(pictureFile!.path), height: 200,)
            //Android/iOS
            // Image.file(File(pictureFile!.path)))
          ],
        ),
      ),
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
      print(status);
      _permissionStatus = status;
      print(_permissionStatus);
    });
  }
}
