class PermitImgData {
  PermitImgData({
      this.image, 
      this.description,});

  PermitImgData.fromJson(dynamic json) {
    image = json['image'];
    description = json['description'];
  }
  String? image;
  String? description;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['image'] = image;
    map['description'] = description;
    return map;
  }

}