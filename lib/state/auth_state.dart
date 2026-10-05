import 'package:flutter/material.dart';

import '../models/user_profile.dart';

/// Status login sementara. Nanti tinggal ganti dengan session dari backend
/// tanpa mengubah halaman.
class AuthState extends ChangeNotifier {
  AuthState({UserProfile? user}) : _user = user;

  bool _isSignedIn = false;
  UserProfile? _user;

  bool get isSignedIn => _isSignedIn;

  /// Pengguna yang sedang login; null kalau belum login.
  UserProfile? get user => _user;

  void signIn({UserProfile? user}) {
    _isSignedIn = true;
    _user = user ?? dummyUserProfile;
    notifyListeners();
  }

  /// Perbarui data pengguna yang sedang login.
  ///
  /// Dipakai halaman Data Diri. Karena profil disimpan di state ini, halaman
  /// Profil otomatis ikut berubah setelah perubahan disimpan.
  void updateUser(UserProfile user) {
    if (!identical(_user, user)) {
      _user = user;
    }
    notifyListeners();
  }

  /// Hapus session lokal. Dipakai tombol "Keluar" di halaman Profil.
  void signOut() {
    _isSignedIn = false;
    _user = null;
    notifyListeners();
  }
}

class AuthStateScope extends InheritedNotifier<AuthState> {
  const AuthStateScope({
    super.key,
    required AuthState state,
    required super.child,
  }) : super(notifier: state);

  static AuthState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthStateScope>();
    assert(scope != null, 'AuthStateScope tidak ditemukan pada context.');
    return scope!.notifier!;
  }

  /// Versi nullable supaya halaman tetap bisa dibuka tanpa scope
  /// (misalnya saat test atau preview).
  static AuthState? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthStateScope>()?.notifier;
}
