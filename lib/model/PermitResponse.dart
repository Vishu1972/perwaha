import 'PermitDetails.dart';

class PermitResponse {
  PermitResponse({
      this.status, 
      this.approved, 
      this.pending, 
      this.rejected, 
      this.live, 
      this.closureApplied, 
      this.closed, 
      this.suspended, 
      this.recommendedForSuspension, 
      this.total, 
      this.count, 
      this.permitDetails,});

  PermitResponse.fromJson(dynamic json) {
    status = json['status'];
    approved = json['approved'];
    pending = json['pending'];
    rejected = json['rejected'];
    live = json['live'];
    closureApplied = json['closure_applied'];
    closed = json['closed'];
    suspended = json['suspended'];
    recommendedForSuspension = json['recommended_for_Suspension'];
    total = json['total'];
    count = json['count'];
    if (json['permitDetails'] != null) {
      permitDetails = [];
      json['permitDetails'].forEach((v) {
        permitDetails!.add(PermitDetails.fromJson(v));
      });
    }
  }
  bool? status;
  int? approved;
  int? pending;
  int? rejected;
  int? live;
  int? closureApplied;
  int? closed;
  int? suspended;
  int? recommendedForSuspension;
  int? total;
  int? count;
  List<PermitDetails>? permitDetails;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['approved'] = approved;
    map['pending'] = pending;
    map['rejected'] = rejected;
    map['live'] = live;
    map['closure_applied'] = closureApplied;
    map['closed'] = closed;
    map['suspended'] = suspended;
    map['recommended_for_Suspension'] = recommendedForSuspension;
    map['total'] = total;
    map['count'] = count;
    if (permitDetails != null) {
      map['permitDetails'] = permitDetails!.map((v) => v.toJson()).toList();
    }
    return map;
  }

}