class PermitDetails {
  PermitDetails({
      this.id, 
      this.locality, 
      this.building, 
      this.status, 
      this.chargerArea, 
      this.permitNumber, 
      this.senderName, 
      this.chargeAreaId, 
      this.jobDecs, 
      this.statusTime, 
      this.createTime,});

  PermitDetails.fromJson(dynamic json) {
    id = json['id'];
    locality = json['locality'];
    building = json['building'];
    status = json['status'];
    chargerArea = json['charger_area'];
    permitNumber = json['permit_number'];
    senderName = json['sender_name'];
    chargeAreaId = json['charge_area_id'];
    jobDecs = json['job_decs'];
    statusTime = json['status_time'];
    createTime = json['create_time'];
  }
  int? id;
  String? locality;
  String? building;
  String? status;
  String? chargerArea;
  String? permitNumber;
  String? senderName;
  String? chargeAreaId;
  String? jobDecs;
  String? statusTime;
  String? createTime;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['locality'] = locality;
    map['building'] = building;
    map['status'] = status;
    map['charger_area'] = chargerArea;
    map['permit_number'] = permitNumber;
    map['sender_name'] = senderName;
    map['charge_area_id'] = chargeAreaId;
    map['job_decs'] = jobDecs;
    map['status_time'] = statusTime;
    map['create_time'] = createTime;
    return map;
  }

}