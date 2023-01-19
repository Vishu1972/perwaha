import 'User.dart';

class LoginResponse {
  LoginResponse({
      this.status, 
      this.designationId, 
      this.designation, 
      this.token, 
      this.user,
  this.msg});

  LoginResponse.fromJson(dynamic json) {
    status = json['status'];
    designationId = json['designation_id'];
    designation = json['designation'];
    token = json['token'];
    msg = json['msg'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }
  bool? status;
  String? msg;
  int? designationId;
  String? designation;
  String? token;
  User? user;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['designation_id'] = designationId;
    map['designation'] = designation;
    map['token'] = token;
    map['msg'] = msg;
    if (user != null) {
      map['user'] = user!.toJson();
    }
    return map;
  }

}