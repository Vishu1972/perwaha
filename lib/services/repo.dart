import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:perwha/model/ChargeAreaDetails.dart';
import 'package:perwha/model/JobDetails.dart';
import 'package:perwha/model/PermitDocuments.dart';
import 'package:perwha/model/PhotographDetail.dart';
import 'package:perwha/model/ProfileDetails.dart';
import 'package:perwha/model/TpeList.dart';
import 'package:perwha/model/UpdatePermit.dart';
import 'package:perwha/utils/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/LoginResponse.dart';
import '../model/PermitResponse.dart';

Future<LoginResponse> loginRequest(
    String url, String username, String password) async {
  final loginResponse = await http.post(Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, String>{'username': username, 'password': password}));

  if (loginResponse.statusCode == 200) {

    return LoginResponse.fromJson(jsonDecode(loginResponse.body));
  } else {
    throw Exception('Failed to post user.');
  }
}

Future<PermitResponse> getPermitDetails(String token, String fromDate, String toDate, String jobId, String tpeId) async {

  if(toDate==""){
    toDate = dateFormater(DateTime.now(), "dd-MM-yyyy");
  }
  if(fromDate ==""){
    fromDate = "01-10-2022";
  }

  final permitResponse = await http
      .post(Uri.parse('http://mngl.intileo.com/api/getPermitdetail'), headers: {
    'authorization': "${token}",
    'Content-Type': 'application/json; charset=UTF-8',
  },
    body: jsonEncode(<String, String>{
    "from_date" : fromDate,
    "to_date" : toDate,
    "job_id" : jobId,
    "tpe_id" : tpeId,
    })
  );

  print(jsonEncode(<String, String?>{
    "from_date" : fromDate,
    "to_date" : toDate,
    "job_id" : jobId,
    "tpe_id" : tpeId,
  }));

  if (permitResponse.statusCode == 200) {
   
    return PermitResponse.fromJson(jsonDecode(permitResponse.body));
  } else {
    throw Exception('Failed to get Permits');
  }
}

Future<ProfileDetails> getProfileDetails(String token) async {
  final permitResponse = await http
      .get(Uri.parse('http://mngl.intileo.com/api/profile'), headers: {
    'authorization': token,
    'Content-Type': 'application/json; charset=UTF-8',
  });
  if (permitResponse.statusCode == 200) {
    print(jsonDecode(permitResponse.body));
    return ProfileDetails.fromJson(jsonDecode(permitResponse.body));
  } else {
    throw permitResponse.statusCode;
  }
}

Future<JobDetails> getJobDecsList(String token) async {
  final permitResponse = await http
      .get(Uri.parse('http://mngl.intileo.com/api/joblist'), headers: {
    'authorization': token,
    'Content-Type': 'application/json; charset=UTF-8',
  });
  if (permitResponse.statusCode == 200) {
    return JobDetails.fromJson(jsonDecode(permitResponse.body));
  } else {
    throw Exception('Failed to get Permits');
  }
}

Future<TpeList> getTpeList(String token) async {
  final permitResponse = await http
      .post(Uri.parse('http://mngl.intileo.com/api/tpelist'), headers: {
    'authorization': token,
    'Content-Type': 'application/json; charset=UTF-8',
  });
  print(permitResponse.body);
  if (permitResponse.statusCode == 200) {

    return TpeList.fromJson(jsonDecode(permitResponse.body));
  } else {
    throw Exception('Failed to get Permits');
  }
}

Future<PhotographDetail> getPhotoGraphDetails(String token) async {
  final permitResponse = await http
      .get(Uri.parse('http://mngl.intileo.com/api/getphotographs'), headers: {
    'authorization': token,
    'Content-Type': 'application/json; charset=UTF-8',
  });
  if (permitResponse.statusCode == 200) {
    return PhotographDetail.fromJson(jsonDecode(permitResponse.body));
  } else {
    throw Exception('Failed to get Permits');
  }
}

Future<ChargeAreaDetails> getChargeAreaList(String token, String id) async {
  final permitResponse = await http.post(
      Uri.parse('http://mngl.intileo.com/api/getChargeareabyPAId'),
      headers: {
        'authorization': token,
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{"project_area_id": id}));
  if (permitResponse.statusCode == 200) {
    return ChargeAreaDetails.fromJson(jsonDecode(permitResponse.body));
  } else {
    throw Exception('Failed to get Permits');
  }
}

Future<String> UploadPermitDetails(String token) async {
  final permitResponse = await http.get(
      Uri.parse("http://mngl.intileo.com/api/uploadPermitDetails"),
      headers: {
        'authorization': token,
        'Content-Type': 'application/json; charset=UTF-8',
      });
  if (permitResponse.statusCode == 200) {
    var data = jsonDecode(permitResponse.body);
    print(data);
    return "null";
  } else {
    throw Exception('Failed to get Permits');
  }
}

Future<PermitDocuments> getdocumentbypermitid(String id, String token) async {
  final Uploaddocuments = await http.post(
      Uri.parse("http://mngl.intileo.com/api/documentbypermitid"),
      headers: {
        'authorization': token,
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'permit_id': id}));
  print(id);
  if (Uploaddocuments.statusCode == 200) {
    var data = jsonDecode(Uploaddocuments.body);

    return PermitDocuments.fromJson(
        jsonDecode(Uploaddocuments.body));
  } else {
    throw Exception('Failed to post user.');
  }
}

Future<UpdatePermit> setPermitStatus(
    String id, String token, String remarks, String status) async {
  final Uploaddocuments = await http.post(
      Uri.parse("http://mngl.intileo.com/api/updatepermitstatus"),
      headers: {
        'authorization': token,
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'permit_id': id,
        "remark": remarks,
        "status_id": status
      }));
  print(id);
  if (Uploaddocuments.statusCode == 200) {
    var data = jsonDecode(Uploaddocuments.body);
    print(data);
    return UpdatePermit.fromJson(jsonDecode(Uploaddocuments.body));
  } else {
    throw Exception('Failed to post user.');
  }
}

uploadPermit(String job_id, String chargeArea_id, String locality,
    String building, String remarks, List<File> imageList, String token) async {
  var dio = Dio();
  FormData formData = FormData.fromMap({
    "job_id": job_id,
    "charge_area_id": chargeArea_id,
    "locality": locality,
    "building": building,
    "remarks": remarks,
    "wah_permit": await MultipartFile.fromFile(imageList[0].path,
        filename: imageList[0].path.split('/').last,
        contentType: MediaType('image', 'jpg')),
    "fall_arrester": await MultipartFile.fromFile(imageList[1].path,
        filename: imageList[1].path.split('/').last,
        contentType: MediaType('image', 'jpg')),
    "petzel_inspection": await MultipartFile.fromFile(imageList[2].path,
        filename: imageList[2].path.split('/').last,
        contentType: MediaType('image', 'jpg')),
    "plumber_certificatn": await MultipartFile.fromFile(imageList[3].path,
        filename: imageList[3].path.split('/').last,
        contentType: MediaType('image', 'jpg')),
    "emergency_electrical_equipment": await MultipartFile.fromFile(
        imageList[4].path,
        filename: imageList[4].path.split('/').last,
        contentType: MediaType('image', 'jpg')),
    "site_photo1": await MultipartFile.fromFile(imageList[5].path,
        filename: imageList[5].path.split('/').last,
        contentType: MediaType('image', 'jpg')),
    "site_photo2": await MultipartFile.fromFile(imageList[6].path,
        filename: imageList[6].path.split('/').last,
        contentType: MediaType('image', 'jpg')),
    "site_photo3": await MultipartFile.fromFile(imageList[7].path,
        filename: imageList[7].path.split('/').last,
        contentType: MediaType('image', 'jpg')),
    'type': 'image/jpg'
  });

  Response response =
      await dio.post('http://mngl.intileo.com/api/uploadPermitDetails',
          data: formData,
          options: Options(headers: {
            'Accept': '*/*',
            'Content-Type':
                'multipart/form-data; boundary=<calculated when request is sent>',
            'authorization': token,
          }));
  print(response.data);
  return response;
}

uploadclosePermit(String job_id, String chargeArea_id, String locality,
    String building, String remarks, List<File> imageList, String token) async {
  var dio = Dio();
  FormData formData = FormData.fromMap({
    "job_id": job_id,
    "charge_area_id": chargeArea_id,
    "locality": locality,
    "building": building,
    "remarks": remarks,
    "wah_permit": await MultipartFile.fromFile(imageList[0].path,
        filename: imageList[0].path.split('/').last,
        contentType: MediaType('image', 'jpg')),
    "fall_arrester": await MultipartFile.fromFile(imageList[1].path,
        filename: imageList[1].path.split('/').last,
        contentType: MediaType('image', 'jpg')),
    "petzel_inspection": await MultipartFile.fromFile(imageList[2].path,
        filename: imageList[2].path.split('/').last,
        contentType: MediaType('image', 'jpg')),
    "plumber_certificatn": await MultipartFile.fromFile(imageList[3].path,
        filename: imageList[3].path.split('/').last,
        contentType: MediaType('image', 'jpg')),
    "emergency_electrical_equipment": await MultipartFile.fromFile(
        imageList[4].path,
        filename: imageList[4].path.split('/').last,
        contentType: MediaType('image', 'jpg')),
    "site_photo1": await MultipartFile.fromFile(imageList[5].path,
        filename: imageList[5].path.split('/').last,
        contentType: MediaType('image', 'jpg')),
    "site_photo2": await MultipartFile.fromFile(imageList[6].path,
        filename: imageList[6].path.split('/').last,
        contentType: MediaType('image', 'jpg')),
    "site_photo3": await MultipartFile.fromFile(imageList[7].path,
        filename: imageList[7].path.split('/').last,
        contentType: MediaType('image', 'jpg')),
    'type': 'image/jpg'
  });

  Response response =
      await dio.post('http://mngl.intileo.com/api/uploadPermitDetails',
          data: formData,
          options: Options(headers: {
            'Accept': '*/*',
            'Content-Type':
                'multipart/form-data; boundary=<calculated when request is sent>',
            'authorization': token,
          }));
  print(response.data);
  return response;
}
