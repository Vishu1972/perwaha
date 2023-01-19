class Data {
  Data({
      this.jobId, 
      this.building, 
      this.locality, 
      this.remarks, 
      this.wahPermit, 
      this.fallArrester, 
      this.petzelInspection, 
      this.plumberCertificatn, 
      this.emergencyElectricalEquipment, 
      this.sitePhoto1, 
      this.sitePhoto2, 
      this.sitePhoto3,});

  Data.fromJson(dynamic json) {
    jobId = json['job_id'] != null ? json['job_id'].cast<String>() : [];
    building = json['building'] != null ? json['building'].cast<String>() : [];
    locality = json['locality'] != null ? json['locality'].cast<String>() : [];
    remarks = json['remarks'] != null ? json['remarks'].cast<String>() : [];
    wahPermit = json['wah_permit'] != null ? json['wah_permit'].cast<String>() : [];
    fallArrester = json['fall_arrester'] != null ? json['fall_arrester'].cast<String>() : [];
    petzelInspection = json['petzel_inspection'] != null ? json['petzel_inspection'].cast<String>() : [];
    plumberCertificatn = json['plumber_certificatn'] != null ? json['plumber_certificatn'].cast<String>() : [];
    emergencyElectricalEquipment = json['emergency_electrical_equipment'] != null ? json['emergency_electrical_equipment'].cast<String>() : [];
    sitePhoto1 = json['site_photo1'] != null ? json['site_photo1'].cast<String>() : [];
    sitePhoto2 = json['site_photo2'] != null ? json['site_photo2'].cast<String>() : [];
    sitePhoto3 = json['site_photo3'] != null ? json['site_photo3'].cast<String>() : [];
  }
  List<String>? jobId;
  List<String>? building;
  List<String>? locality;
  List<String>? remarks;
  List<String>? wahPermit;
  List<String>? fallArrester;
  List<String>? petzelInspection;
  List<String>? plumberCertificatn;
  List<String>? emergencyElectricalEquipment;
  List<String>? sitePhoto1;
  List<String>? sitePhoto2;
  List<String>? sitePhoto3;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['job_id'] = jobId;
    map['building'] = building;
    map['locality'] = locality;
    map['remarks'] = remarks;
    map['wah_permit'] = wahPermit;
    map['fall_arrester'] = fallArrester;
    map['petzel_inspection'] = petzelInspection;
    map['plumber_certificatn'] = plumberCertificatn;
    map['emergency_electrical_equipment'] = emergencyElectricalEquipment;
    map['site_photo1'] = sitePhoto1;
    map['site_photo2'] = sitePhoto2;
    map['site_photo3'] = sitePhoto3;
    return map;
  }

}