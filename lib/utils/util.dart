import 'dart:core';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';

String dateFormater(DateTime date, String dateFormat){
  var formatedDate =  DateFormat(dateFormat).format(date);
  return formatedDate;
}
String dateFormater2(String date, String dateFormat){
  var formatedDate =  DateFormat(dateFormat).parse(date);
  return formatedDate.toString();
}
String getPermitIdFromNotification(RemoteMessage message){
  var permit_id;
  RemoteNotification? notification = message.notification;
  var notificationBody = notification!.body!;
  var splitMSG =notificationBody.split("/").last;
  permit_id = splitMSG.substring(0,2);
  return permit_id;
}