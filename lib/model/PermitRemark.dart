class PermitRemark {
  PermitRemark({
      this.designationId, 
      this.senderBy, 
      this.remark, 
      this.date, 
      this.status, 
      this.permitStatus, 
      this.currentPermitStatus, 
      this.suspendPermitStatus,});

  PermitRemark.fromJson(dynamic json) {
    designationId = json['designation_id'];
    senderBy = json['sender_by'];
    remark = json['remark'];
    date = json['date'];
    status = json['status'];
    permitStatus = json['permit_status'];
    currentPermitStatus = json['current_permit_status'];
    suspendPermitStatus = json['suspend_permit_status'];
  }
  String? designationId;
  String? senderBy;
  String? remark;
  String? date;
  String? status;
  String? permitStatus;
  String? currentPermitStatus;
  String? suspendPermitStatus;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['designation_id'] = designationId;
    map['sender_by'] = senderBy;
    map['remark'] = remark;
    map['date'] = date;
    map['status'] = status;
    map['permit_status'] = permitStatus;
    map['current_permit_status'] = currentPermitStatus;
    map['suspend_permit_status'] = suspendPermitStatus;
    return map;
  }

}