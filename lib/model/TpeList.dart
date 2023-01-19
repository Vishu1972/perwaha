import 'Tpedata.dart';

class TpeList {
  TpeList({
      this.status, 
      this.tpedata,});

  TpeList.fromJson(dynamic json) {
    status = json['status'];
    if (json['data'] != null) {
      tpedata = [];
      json['data'].forEach((v) {
        tpedata!.add(Tpedata.fromJson(v));
      });
    }
  }
  bool? status;
  List<Tpedata>? tpedata;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    if (tpedata != null) {
      map['data'] = tpedata!.map((v) => v.toJson()).toList();
    }
    return map;
  }

}