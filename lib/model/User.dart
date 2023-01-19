import 'ProjectAreaName.dart';
import 'ChargeAreaName.dart';

class User {
  User({
      this.id, 
      this.userId, 
      this.name, 
      this.email, 
      this.mobile, 
      this.designationId, 
      this.stateId, 
      this.districtId, 
      this.projectAreaId, 
      this.chargeAreaId, 
      this.contractorId, 
      this.employeeid, 
      this.permanentTemporary, 
      this.experience, 
      this.skills, 
      this.userType, 
      this.status, 
      this.emailVerifiedAt, 
      this.creationDateTime, 
      this.stateName, 
      this.districtName, 
      this.projectAreaName, 
      this.chargeAreaName,});

  User.fromJson(dynamic json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    email = json['email'];
    mobile = json['mobile'];
    designationId = json['designation_id'];
    stateId = json['state_id'];
    districtId = json['district_id'];
    projectAreaId = json['project_area_id'] != null ? json['project_area_id'].cast<String>() : [];
    chargeAreaId = json['charge_area_id'] != null ? json['charge_area_id'].cast<String>() : [];
    contractorId = json['contractor_id'];
    employeeid = json['employeeid'];
    permanentTemporary = json['permanent_temporary'];
    experience = json['experience'];
    skills = json['skills'];
    userType = json['user_type'];
    status = json['status'];
    emailVerifiedAt = json['email_verified_at'];
    creationDateTime = json['Creation_DateTime'];
    stateName = json['state_name'];
    districtName = json['district_name'];
    if (json['project_area_name'] != null) {
      projectAreaName = [];
      json['project_area_name'].forEach((v) {
        projectAreaName!.add(ProjectAreaName.fromJson(v));
      });
    }
    if (json['charge_area_name'] != null) {
      chargeAreaName = [];
      json['charge_area_name'].forEach((v) {
        chargeAreaName!.add(ChargeAreaName.fromJson(v));
      });
    }
  }
  int? id;
  String? userId;
  String? name;
  String? email;
  String? mobile;
  int? designationId;
  int? stateId;
  int? districtId;
  List<String>? projectAreaId;
  List<String>? chargeAreaId;
  dynamic contractorId;
  String? employeeid;
  String? permanentTemporary;
  dynamic experience;
  dynamic skills;
  int? userType;
  int? status;
  dynamic emailVerifiedAt;
  String? creationDateTime;
  String? stateName;
  String? districtName;
  List<ProjectAreaName>? projectAreaName;
  List<ChargeAreaName>? chargeAreaName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['user_id'] = userId;
    map['name'] = name;
    map['email'] = email;
    map['mobile'] = mobile;
    map['designation_id'] = designationId;
    map['state_id'] = stateId;
    map['district_id'] = districtId;
    map['project_area_id'] = projectAreaId;
    map['charge_area_id'] = chargeAreaId;
    map['contractor_id'] = contractorId;
    map['employeeid'] = employeeid;
    map['permanent_temporary'] = permanentTemporary;
    map['experience'] = experience;
    map['skills'] = skills;
    map['user_type'] = userType;
    map['status'] = status;
    map['email_verified_at'] = emailVerifiedAt;
    map['Creation_DateTime'] = creationDateTime;
    map['state_name'] = stateName;
    map['district_name'] = districtName;
    if (projectAreaName != null) {
      map['project_area_name'] = projectAreaName!.map((v) => v.toJson()).toList();
    }
    if (chargeAreaName != null) {
      map['charge_area_name'] = chargeAreaName!.map((v) => v.toJson()).toList();
    }
    return map;
  }

}