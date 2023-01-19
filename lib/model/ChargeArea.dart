class ChargeArea {
  ChargeArea({
      this.id, 
      this.description,});

  ChargeArea.fromJson(dynamic json) {
    id = json['id'];
    description = json['description'];
  }
  int? id;
  String? description;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['description'] = description;
    return map;
  }
}