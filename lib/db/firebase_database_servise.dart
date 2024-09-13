import 'package:firebase_database/firebase_database.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/services/auth_service.dart';

class DatabaseService {
  final DatabaseReference database = FirebaseDatabase.instance.ref();

  Future<void> insertQrCode(QRCodeModel qrCode) async {
    final user = Auth().currentUser;
    if (user != null) {
      String uid = user.uid;
      DatabaseReference userRef = database.child('users/$uid/qrcodes').push();
      await userRef.set(qrCode.toJson());
    }
  }

  Future<void> deleteQrCode(String id) async {
    final user = Auth().currentUser;
    if (user != null) {
      String uid = user.uid;
      DatabaseReference userRef = database.child('users/$uid/qrcodes/$id');
      await userRef.remove();
    }
  }

  Future<void> deleteAllQrCode() async {
    final user = Auth().currentUser;
    if (user != null) {
      String uid = user.uid;
      DatabaseReference userRef = database.child('users/$uid/qrcodes');
      await userRef.remove();
    }
  }

  Future<void> updateQRCodeName(
      String id, Map<String, dynamic> updatedData) async {
    final user = Auth().currentUser;
    if (user != null) {
      String uid = user.uid;
      DatabaseReference userRef = database.child('users/$uid/qrcodes/$id');
      await userRef.update(updatedData);
    }
  }

  Future<List<QRCodeModel>> fetchAllQRCodes() async {
    final user = Auth().currentUser;
    if (user != null) {
      String uid = user.uid;
      DatabaseReference userRef = database.child('users/$uid/qrcodes');
      return await userRef.once().then(
        (event) {
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
        },
      );
    } else {
      return [];
    }
  }

  Stream<DatabaseEvent> qrCodeStream() {
    final user = Auth().currentUser;
    if (user != null) {
      String uid = user.uid;
      DatabaseReference userRef = database.child('users/$uid/qrcodes');
      return userRef.onValue;
    } else {
      return const Stream.empty();
    }
  }
}
