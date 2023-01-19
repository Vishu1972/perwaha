import 'ProjectArea.dart';
import 'ChargeArea.dart';

class Data {
  Data({
      this.id, 
      this.name, 
      this.email, 
      this.mobile, 
      this.userid,
      this.designation,
      this.state, 
      this.geoArea, 
      this.projectArea, 
      this.chargeArea, 
      this.profilePhoto,});

  Data.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    mobile = json['mobile'];
    userid = json['user_id'];
    designation = json['designation'];
    state = json['state'];
    geoArea = json['geo_area'];
    if (json['project_area'] != null) {
      projectArea = [];
      json['project_area'].forEach((v) {
        projectArea!.add(ProjectArea.fromJson(v));
      });
    }
    if (json['charge_area'] != null) {
      chargeArea = [];
      json['charge_area'].forEach((v) {
        chargeArea!.add(ChargeArea.fromJson(v));
      });
    }
    profilePhoto = json['profile_photo'];
  }
  int? id;
  String? name;
  String? email;
  String? mobile;
  String? userid;
  String? designation;
  String? state;
  String? geoArea;
  List<ProjectArea>? projectArea;
  List<ChargeArea>? chargeArea;
  String? profilePhoto;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['email'] = email;
    map['mobile'] = mobile;
    map['user_id'] = userid;
    map['designation'] = designation;
    map['state'] = state;
    map['geo_area'] = geoArea;
    if (projectArea != null) {
      map['project_area'] = projectArea!.map((v) => v.toJson()).toList();
    }
    if (chargeArea != null) {
      map['charge_area'] = chargeArea!.map((v) => v.toJson()).toList();
    }
    map['profile_photo'] = profilePhoto;
    return map;
  }

}