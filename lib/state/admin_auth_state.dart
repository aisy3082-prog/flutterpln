import 'package:flutter/material.dart';

import '../models/admin_profile.dart';

/// Status login Admin.
///
/// Sengaja terpisah dari `AuthState` milik user supaya role Admin tidak
/// pernah tercampur dengan user biasa. Nanti tinggal ganti dengan session dari
/// backend tanpa mengubah halaman.
class AdminAuthState extends ChangeNotifier {
  AdminAuthState({AdminProfile? profile}) : _profile = profile;

  bool _isSignedIn = false;
  AdminProfile? _profile;

  bool get isSignedIn => _isSignedIn;

  /// Profil Admin yang sedang login; null kalau belum login.
  AdminProfile? get profile => _profile;

  void signIn({AdminProfile? profile}) {
    _isSignedIn = true;
    _profile = profile ?? dummyAdminProfile;
    notifyListeners();
  }

  /// Perbarui data profil yang sedang login.
  ///
  /// Dipakai halaman Data Diri Admin. Karena profil disimpan di state ini,
  /// halaman Profil otomatis ikut berubah setelah disimpan.
  void updateProfile(AdminProfile profile) {
    if (!identical(_profile, profile)) {
      _profile = profile;
    }
    notifyListeners();
  }

  /// Hapus session Admin. Dipakai tombol "Keluar" di halaman Profil Admin.
  void signOut() {
    _isSignedIn = false;
    _profile = null;
    notifyListeners();
  }
}

class AdminAuthStateScope extends InheritedNotifier<AdminAuthState> {
  const AdminAuthStateScope({
    super.key,
    required AdminAuthState state,
    required super.child,
  }) : super(notifier: state);

  static AdminAuthState of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AdminAuthStateScope>();
    assert(scope != null, 'AdminAuthStateScope tidak ditemukan pada context.');
    return scope!.notifier!;
  }

  /// Versi nullable supaya halaman tetap bisa dibuka tanpa scope
  /// (misalnya saat test atau pratinjau).
  static AdminAuthState? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AdminAuthStateScope>()?.notifier;
}
