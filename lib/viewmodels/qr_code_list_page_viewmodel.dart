import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/repository/main_qrcode_repository.dart';
import 'package:qr_coder/repository/qrcode_repository.dart';

class QrCodeListPageViewmodel extends ChangeNotifier {
  static final DateFormat _createdAtFormat = DateFormat('dd.MM.yyyy HH:mm');

  QRCodeRepository repository;
  List<String> _selectedQRCodes = [];
  final List<String> _editingQRCodes = [];
  List<QRCodeModel> qrCodes = [];
  String _errorMsg = '';
  String _actionErrorMsg = '';
  bool _allSelected = false;
  // bool _isLoading = false;

  String get errorMsg => _errorMsg;
  String get actionErrorMsg => _actionErrorMsg;
  bool get allSelected => _allSelected;
  // bool get isLoading => _isLoading;
  List<String> get selectedQRCodes => _selectedQRCodes;
  List<String> get editingQRCodes => _editingQRCodes;

  QrCodeListPageViewmodel({
    required bool isFirebaseUser,
    required String? uid,
    QRCodeRepository? repository,
  }) : repository =
           repository ??
           MainQrCodeRepository(isFirebaseUser: isFirebaseUser, uid: uid);

  void clearAll() {
    resetTransientState(notify: false);
    _errorMsg = '';
    _actionErrorMsg = '';
    qrCodes.clear();
    notifyListeners();
  }

  void resetTransientState({bool notify = true}) {
    _selectedQRCodes.clear();
    _editingQRCodes.clear();
    _allSelected = false;

    if (notify) {
      notifyListeners();
    }
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
    _errorMsg = '';

    try {
      qrCodes = await repository.fetchAllQRCodes();
      sortByCreatedAtDescending(qrCodes);
    } catch (e) {
      qrCodes = [];
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

  Future<bool> updateQRCodeName(
    String id,
    String name,
    AppLocalizations l10n,
  ) async {
    _actionErrorMsg = '';

    try {
      await repository.updateQRCodeName(id, {'name': name});
      await fetchQRCodes(l10n);
      return true;
    } catch (e) {
      _actionErrorMsg = l10n.qrCodeList_updateDescriptionErrorMsg;
      debugPrint('QR code name update failed: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteQRCode(String id, AppLocalizations l10n) async {
    _actionErrorMsg = '';

    try {
      await repository.deleteQrCode(id);
      _selectedQRCodes.remove(id);
      _editingQRCodes.remove(id);
      await fetchQRCodes(l10n);
      return true;
    } catch (e) {
      _actionErrorMsg = l10n.qrCodeList_deleteErrorMsg;
      debugPrint('QR code delete failed: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAllQRCodes(AppLocalizations l10n) async {
    _actionErrorMsg = '';

    try {
      await repository.deleteAllQrCodes();
      resetTransientState(notify: false);
      await fetchQRCodes(l10n);
      return true;
    } catch (e) {
      _actionErrorMsg = l10n.qrCodeList_deleteAllErrorMsg;
      debugPrint('Delete all QR codes failed: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSelectedQRCodes(AppLocalizations l10n) async {
    if (_selectedQRCodes.isEmpty) {
      return true;
    }

    _actionErrorMsg = '';
    final selectedIds = List<String>.unmodifiable(_selectedQRCodes);

    try {
      // Production repositories implement this as one atomic backend
      // operation. A failure therefore does not leave a half-deleted
      // selection.
      await repository.deleteQrCodes(selectedIds);

      _selectedQRCodes.clear();
      _editingQRCodes.removeWhere(selectedIds.contains);
      await fetchQRCodes(l10n);
      return true;
    } catch (e) {
      _actionErrorMsg = l10n.qrCodeList_deleteSelectedErrorMsg;
      debugPrint('Delete selected QR codes failed: $e');
      notifyListeners();
      return false;
    }
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
