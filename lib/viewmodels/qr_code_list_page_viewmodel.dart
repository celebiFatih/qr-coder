import 'package:flutter/material.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/repository/main_qrcode_repository.dart';

class QrCodeListPageViewmodel extends ChangeNotifier {
  MainQrCodeRepository repository;
  List<String> _selectedQRCodes = [];
  final List<String> _editingQRCodes = [];
  List<QRCodeModel> qrCodes = [];
  String _errorMsg = '';
  bool _allSelected = false;
  // bool _isLoading = false;

  String get errorMsg => _errorMsg;
  bool get allSelected => _allSelected;
  // bool get isLoading => _isLoading;
  List<String> get selectedQRCodes => _selectedQRCodes;
  List<String> get editingQRCodes => _editingQRCodes;

  QrCodeListPageViewmodel({required bool isFirebaseUser, required String? uid})
      : repository =
            MainQrCodeRepository(isFirebaseUser: isFirebaseUser, uid: uid);

  void clearAll() {
    _selectedQRCodes.clear();
    _editingQRCodes.clear();
    _allSelected = false;
    _errorMsg = '';
    qrCodes.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _selectedQRCodes.clear();
    _editingQRCodes.clear();
    super.dispose();
  }

  // set allSelected(bool value) {
  //   if (_allSelected != value) {
  //     _allSelected = value;
  //     notifyListeners();
  //   }
  // }

  // set selectedQRCodes(List<String> value) {
  //   if (_selectedQRCodes != value) {
  //     _selectedQRCodes = value;
  //     notifyListeners();
  //   }
  // }

  Future<void> fetchQRCodes(BuildContext context) async {
    // _isLoading = true; // Yüklenmeye başla
    try {
      qrCodes = await repository.fetchAllQRCodes();
      qrCodes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _errorMsg = AppLocalizations.of(context)!.qrCodeList_fetchListErrorMsg;
      print(e);
    }
    notifyListeners();
    // _isLoading = false;
  }

  Future<void> updateQRCodeName(
      String id, String name, BuildContext context) async {
    try {
      await repository.updateQRCodeName(id, {'name': name});
      await fetchQRCodes(context);
    } catch (e) {
      _errorMsg =
          AppLocalizations.of(context)!.qrCodeList_updateDescriptionErrorMsg;
      print(e);
    }
  }

  Future<void> deleteQRCode(String id, BuildContext context) async {
    try {
      await repository.deleteQrCode(id);
      await fetchQRCodes(context);
    } catch (e) {
      _errorMsg = AppLocalizations.of(context)!.qrCodeList_deleteErrorMsg;
      print(e);
    }
  }

  Future<void> deleteAllQRCodes(BuildContext context) async {
    try {
      await repository.deleteAllQrCodes();
      await fetchQRCodes(context);
    } catch (e) {
      _errorMsg = AppLocalizations.of(context)!.qrCodeList_deleteAllErrorMsg;
      print(e);
    }
  }

  Future<void> deleteSelectedQRCodes(BuildContext context) async {
    for (String id in _selectedQRCodes) {
      await repository.deleteQrCode(id);
    }
    _selectedQRCodes.clear();
    await fetchQRCodes(context);
  }

  void selectQRCode(String id) {
    _selectedQRCodes.add(id);
    notifyListeners();
  }

  void deselectQRCode(String id) {
    _selectedQRCodes.remove(id);
    notifyListeners();
  }

  void toggleSelectAllQRCodes() async {
    if (_selectedQRCodes.length == qrCodes.length) {
      _selectedQRCodes.clear();
    } else {
      _selectedQRCodes = qrCodes.map((e) => e.id).toList();
    }
    notifyListeners();
    // if (_allSelected) {
    //   _selectedQRCodes.clear();
    // } else {
    //   _selectedQRCodes = await repository
    //       .fetchAllQRCodes()
    //       .then((value) => value.map((e) => e.id).toList());
    // }
    // _allSelected = !_allSelected;
    // notifyListeners();
  }

  void toggleEditingQRCode(String id) {
    if (_editingQRCodes.contains(id)) {
      _editingQRCodes.remove(id);
    } else {
      _editingQRCodes.add(id);
    }
    notifyListeners();
  }
}
