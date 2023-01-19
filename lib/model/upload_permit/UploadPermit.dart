import 'Data.dart';

class UploadPermit {
  UploadPermit({
      this.status, 
      this.data,
  this.msg});

  UploadPermit.fromJson(dynamic json) {
    status = json['status'];
    status = json['msg'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  bool? status;
  Data? data;
  String? msg;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['status'] = msg;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }

}