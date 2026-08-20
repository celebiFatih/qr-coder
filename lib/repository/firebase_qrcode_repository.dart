import 'package:firebase_database/firebase_database.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/repository/qrcode_repository.dart';

class FirebaseQrCodeRepository implements QRCodeRepository {
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  final String uid;

  FirebaseQrCodeRepository(this.uid);

  @override
  Future<void> insertQrCode(QRCodeModel qrCode) async {
    DatabaseReference userRef = database.child('users/$uid/qrcodes').push();
    await userRef.set(qrCode.toJson());
  }

  @override
  Future<void> deleteQrCode(String id) async {
    DatabaseReference userRef = database.child('users/$uid/qrcodes/$id');
    await userRef.remove();
  }

  @override
  Future<void> deleteQrCodes(List<String> ids) async {
    if (ids.isEmpty) {
      return;
    }

    final userRef = database.child('users/$uid/qrcodes');
    final updates = <String, Object?>{for (final id in ids) id: null};

    // Realtime Database update() applies this multi-location change as one
    // atomic write: either every selected QR is removed or none are.
    await userRef.update(updates);
  }

  @override
  Future<void> deleteAllQrCodes() async {
    DatabaseReference userRef = database.child('users/$uid/qrcodes');
    await userRef.remove();
  }

  @override
  Future<void> updateQRCodeName(
    String id,
    Map<String, dynamic> updatedData,
  ) async {
    DatabaseReference userRef = database.child('users/$uid/qrcodes/$id');
    await userRef.update(updatedData);
  }

  @override
  Future<List<QRCodeModel>> fetchAllQRCodes() async {
    DatabaseReference userRef = database.child('users/$uid/qrcodes');
    return await userRef.once().then((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> fetchedData =
            event.snapshot.value as Map<dynamic, dynamic>;
        List<QRCodeModel> qrCodesList = [];
        fetchedData.forEach((key, value) {
          qrCodesList.add(QRCodeModel.fromJson(key, value));
        });
        return qrCodesList;
      } else {
        return [];
      }
    });
  }
}
