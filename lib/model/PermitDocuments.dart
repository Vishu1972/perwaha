import 'PermitImgData.dart';
import 'ClosureImgData.dart';
import 'PermitRemark.dart';

class PermitDocuments {
  PermitDocuments({
      this.status, 
      this.id, 
      this.permitNo, 
      this.jobDescription, 
      this.locality, 
      this.building, 
      this.submittedDate, 
      this.actionDate, 
      this.permitStatus, 
      this.currentPermitStatus, 
      this.suspendPermitStatus, 
      this.permitImgData, 
      this.closureImgData, 
      this.permitRemark,});

  PermitDocuments.fromJson(dynamic json) {
    status = json['status'];
    id = json['id'];
    permitNo = json['permit_no'];
    name = json['name'];
    jobDescription = json['job_description'];
    locality = json['locality'];
    building = json['building'];
    submittedDate = json['submitted_date'];
    actionDate = json['action_date'];
    charge_area = json['charge_area'];
    permitStatus = json['permit_status'];
    currentPermitStatus = json['current_permit_status'];
    suspendPermitStatus = json['suspend_permit_status'];
    if (json['permit_img_data'] != null) {
      permitImgData = [];
      json['permit_img_data'].forEach((v) {
        permitImgData!.add(PermitImgData.fromJson(v));
      });
    }
    if (json['closure_img_data'] != null) {
      closureImgData = [];
      json['closure_img_data'].forEach((v) {
        closureImgData!.add(ClosureImgData.fromJson(v));
      });
    }
    if (json['permit_remark'] != null) {
      permitRemark = [];
      json['permit_remark'].forEach((v) {
        permitRemark!.add(PermitRemark.fromJson(v));
      });
    }
  }
  bool? status;
  int? id;
  String? permitNo;
  String? name;
  String? jobDescription;
  String? locality;
  String? building;
  String? submittedDate;
  String? actionDate;
  String? charge_area;
  String? permitStatus;
  String? currentPermitStatus;
  String? suspendPermitStatus;
  List<PermitImgData>? permitImgData;
  List<ClosureImgData>? closureImgData;
  List<PermitRemark>? permitRemark;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['id'] = id;
    map['permit_no'] = permitNo;
    map['name'] = name;
    map['job_description'] = jobDescription;
    map['locality'] = locality;
    map['building'] = building;
    map['submitted_date'] = submittedDate;
    map['action_date'] = actionDate;
    map['charge_area'] = charge_area;
    map['permit_status'] = permitStatus;
    map['current_permit_status'] = currentPermitStatus;
    map['suspend_permit_status'] = suspendPermitStatus;
    if (permitImgData != null) {
      map['permit_img_data'] = permitImgData!.map((v) => v.toJson()).toList();
    }
    if (closureImgData != null) {
      map['closure_img_data'] = closureImgData!.map((v) => v.toJson()).toList();
    }
    if (permitRemark != null) {
      map['permit_remark'] = permitRemark!.map((v) => v.toJson()).toList();
    }
    return map;
  }

}