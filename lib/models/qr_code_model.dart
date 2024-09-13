class QRCodeModel {
  String id;
  String data;
  String name;
  String createdAt;

  QRCodeModel({
    required this.id,
    required this.data,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'data': data,
      'created_at': createdAt,
    };
  }

  factory QRCodeModel.fromJson(String key, Map<dynamic, dynamic> json) {
    return QRCodeModel(
      id: key,
      data: json['data'] as String,
      name: json['name'] as String,
      createdAt: json['created_at'] as String,
    );
  }
}
