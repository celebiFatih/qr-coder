import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/repository/main_qrcode_repository.dart';

class QrCodeListPageViewmodel extends ChangeNotifier {
  static final DateFormat _createdAtFormat = DateFormat('dd.MM.yyyy HH:mm');

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
    : repository = MainQrCodeRepository(
        isFirebaseUser: isFirebaseUser,
        uid: uid,
      );

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

  Future<void> fetchQRCodes(AppLocalizations l10n) async {
    final fetchErrorMsg = l10n.qrCodeList_fetchListErrorMsg;
    try {
      qrCodes = await repository.fetchAllQRCodes();
      sortByCreatedAtDescending(qrCodes);
    } catch (e) {
      _errorMsg = fetchErrorMsg;
      debugPrint('QR code list fetch failed: $e');
    }
    notifyListeners();
  }

  static void sortByCreatedAtDescending(List<QRCodeModel> qrCodes) {
    qrCodes.sort((a, b) {
      final aDate = _tryParseCreatedAt(a.createdAt);
      final bDate = _tryParseCreatedAt(b.createdAt);

      if (aDate != null && bDate != null) {
        return bDate.compareTo(aDate);
      }

      // Eski/bozuk bir kayit tarihi tum listeyi bozmasin. Gecerli tarihli
      // kayitlari once, parse edilemeyen kayitlari listenin sonunda tut.
      if (aDate != null) {
        return -1;
      }
      if (bDate != null) {
        return 1;
      }

      // Iki tarih de parse edilemiyorsa siralamayi deterministik tut.
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  static DateTime? _tryParseCreatedAt(String value) {
    try {
      return _createdAtFormat.parseStrict(value);
    } on FormatException {
      return null;
    }
  }

  Future<void> updateQRCodeName(
    String id,
    String name,
    AppLocalizations l10n,
  ) async {
    final updateErrorMsg = l10n.qrCodeList_updateDescriptionErrorMsg;
    try {
      await repository.updateQRCodeName(id, {'name': name});
      await fetchQRCodes(l10n);
    } catch (e) {
      _errorMsg = updateErrorMsg;
      debugPrint('QR code name update failed: $e');
    }
  }

  Future<void> deleteQRCode(String id, AppLocalizations l10n) async {
    final deleteErrorMsg = l10n.qrCodeList_deleteErrorMsg;
    try {
      await repository.deleteQrCode(id);
      await fetchQRCodes(l10n);
    } catch (e) {
      _errorMsg = deleteErrorMsg;
      debugPrint('QR code delete failed: $e');
    }
  }

  Future<void> deleteAllQRCodes(AppLocalizations l10n) async {
    final deleteAllErrorMsg = l10n.qrCodeList_deleteAllErrorMsg;
    try {
      await repository.deleteAllQrCodes();
      await fetchQRCodes(l10n);
    } catch (e) {
      _errorMsg = deleteAllErrorMsg;
      debugPrint('Delete all QR codes failed: $e');
    }
  }

  Future<void> deleteSelectedQRCodes(AppLocalizations l10n) async {
    for (String id in _selectedQRCodes) {
      await repository.deleteQrCode(id);
    }
    _selectedQRCodes.clear();
    await fetchQRCodes(l10n);
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
