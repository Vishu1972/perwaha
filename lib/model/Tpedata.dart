class Tpedata {
  Tpedata({
      this.id, 
      this.tpeUserId, 
      this.name, 
      this.email, 
      this.mobile,});

  Tpedata.fromJson(dynamic json) {
    id = json['id'];
    tpeUserId = json['tpe_user_id'];
    name = json['name'];
    email = json['email'];
    mobile = json['mobile'];
  }
  int? id;
  String? tpeUserId;
  String? name;
  String? email;
  String? mobile;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['tpe_user_id'] = tpeUserId;
    map['name'] = name;
    map['email'] = email;
    map['mobile'] = mobile;
    return map;
  }

}