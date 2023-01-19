/// status : true
/// data : [{"id":1,"description":"WAH Permit"},{"id":2,"description":"Fall arrester"},{"id":3,"description":"Petzel Inspection"},{"id":4,"description":"Plumber certificate"},{"id":5,"description":"Emergency electrical equipment"},{"id":6,"description":"Site Photo"}]

class PhotographDetail {
  PhotographDetail({
      bool? status, 
      List<Data>? data,}){
    _status = status;
    _data = data;
}

  PhotographDetail.fromJson(dynamic json) {
    _status = json['status'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  bool? _status;
  List<Data>? _data;
PhotographDetail copyWith({  bool? status,
  List<Data>? data,
}) => PhotographDetail(  status: status ?? _status,
  data: data ?? _data,
);
  bool? get status => _status;
  List<Data>? get data => _data;

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
/// description : "WAH Permit"

class Data {
  Data({
      num? id, 
      String? description,}){
    _id = id;
    _description = description;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _description = json['description'];
  }
  num? _id;
  String? _description;
Data copyWith({  num? id,
  String? description,
}) => Data(  id: id ?? _id,
  description: description ?? _description,
);
  num? get id => _id;
  String? get description => _description;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['description'] = _description;
    return map;
  }

}