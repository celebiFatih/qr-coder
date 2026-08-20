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
    return {'name': name, 'data': data, 'created_at': createdAt};
  }

  factory QRCodeModel.fromJson(String key, Map<dynamic, dynamic> json) {
    final model = QRCodeModel.tryFromJson(key, json);
    if (model == null) {
      throw const FormatException('Malformed QR code record');
    }

    return model;
  }

  /// Parses persisted QR records without letting a single malformed legacy
  /// entry break an entire QR-code list.
  ///
  /// `data` is the only field required to represent an actual QR payload.
  /// Older/malformed optional `name` and `created_at` values fall back to an
  /// empty string so the record can still be shown and deleted safely.
  static QRCodeModel? tryFromJson(String key, Map<dynamic, dynamic> json) {
    if (key.isEmpty) {
      return null;
    }

    final rawData = json['data'];
    if (rawData is! String || rawData.isEmpty) {
      return null;
    }

    final rawName = json['name'];
    final rawCreatedAt = json['created_at'];

    return QRCodeModel(
      id: key,
      data: rawData,
      name: rawName is String ? rawName : '',
      createdAt: rawCreatedAt is String ? rawCreatedAt : '',
    );
  }
}
