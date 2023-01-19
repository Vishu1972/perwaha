/// status : true
/// data : [{"id":1,"description":"Test1"}]

class JobDetails {
  JobDetails({
      bool? status, 
      List<JobData>? data,}){
    _status = status;
    _data = data;
}

  JobDetails.fromJson(dynamic json) {
    _status = json['status'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(JobData.fromJson(v));
      });
    }
  }
  bool? _status;
  List<JobData>? _data;
JobDetails copyWith({  bool? status,
  List<JobData>? data,
}) => JobDetails(  status: status ?? _status,
  data: data ?? _data,
);
  bool? get status => _status;
  List<JobData>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }


}

/// id : 1
/// description : "Test1"

class JobData {
  JobData({
      int? id,
      String? description,}){
    _id = id;
    _description = description;
}

  JobData.fromJson(dynamic json) {
    _id = json['id'];
    _description = json['description'];
  }
  int? _id;
  String? _description;
JobData copyWith({  int? id,
  String? description,
}) => JobData(  id: id ?? _id,
  description: description ?? _description,
);
  int? get id => _id;
  String? get description => _description;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['description'] = _description;
    return map;
  }

}