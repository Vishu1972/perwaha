class ChargeAreaDetails {
  ChargeArea({
      bool? status, 
      List<Data>? data,}){
    _status = status;
    _data = data;
}

  ChargeAreaDetails.fromJson(dynamic json) {
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
ChargeAreaDetails copyWith({  bool? status,
  List<Data>? data,
}) => ChargeArea(  status: status ?? _status,
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


class Data {
  Data({
      int? id,
      String? description,}){
    _id = id;
    _description = description;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _description = json['description'];
  }
  int? _id;
  String? _description;
Data copyWith({  int? id,
  String? description,
}) => Data(  id: id ?? _id,
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