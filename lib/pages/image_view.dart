import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:perwha/pages/permitdetailspage.dart';
import 'package:photo_view/photo_view.dart';

import '../main.dart';
import '../model/ClosureImgData.dart';
import '../model/PermitImgData.dart';
import '../utils/util.dart';

class ImageView extends StatefulWidget {
  ImageView(this.tittle, {this.permitImgData, this.closureImgData, Key? key}) : super(key: key);
  List<PermitImgData>? permitImgData;
  List<ClosureImgData>? closureImgData;
  String tittle;


  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  PageController controller = PageController();
  List<Widget> pager = <Widget>[];

  @override
  initState(){
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

  }

  addImage(){
    if(widget.permitImgData != null){
      for (var permidImg in widget.permitImgData!) {
        if (!pager.contains(SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child:
          CachedNetworkImage(
            imageUrl: permidImg.image!,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                SizedBox(height:30, width: 30, child: Center(child: CircularProgressIndicator(value: downloadProgress.progress))),
            errorWidget: (context, url, error) =>
                Icon(Icons.error),
            fit: BoxFit.cover,
          ),
        ))) {
          pager.add(
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height:MediaQuery.of(context).size.height,
              child:  CachedNetworkImage(
                imageUrl: permidImg.image!,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    SizedBox(height:30, width: 30, child: Center(child: CircularProgressIndicator(value: downloadProgress.progress))),
                errorWidget: (context, url, error) =>
                    Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            ),
          );
        }
      }
    }

    if(widget.closureImgData != null){
      for (var closureIdImg
      in widget.closureImgData!) {
        if (!pager.contains(SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 320,
          child: CachedNetworkImage(
            imageUrl: closureIdImg.image!,
            fit: BoxFit.fill,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                SizedBox(height:30, width: 30, child: Center(child: CircularProgressIndicator(value: downloadProgress.progress))),
            errorWidget: (context, url, error) =>
                Icon(Icons.error),
          ),
        ))) {
          pager.add(
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 320,
              child: CachedNetworkImage(
                  fit: BoxFit.fill,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      SizedBox(height:30, width: 30, child: Center(child: CircularProgressIndicator(value: downloadProgress.progress))),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.error),
                  imageUrl: closureIdImg.image!),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    addImage();
    return Scaffold(appBar: AppBar(
      leading: IconButton(icon: Icon(Icons.arrow_back),color: Colors.white, onPressed: () {
        Navigator.of(context).pop();
      },),
      title: Text(widget.tittle, style: TextStyle(color: Colors.white),),
    ),
      body: SafeArea(
        child: Container(
          child: PageView(
            children: pager,
            scrollDirection: Axis.horizontal,
            controller: controller,
          ),
        )
      ),
    );
  }
}
