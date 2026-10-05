import 'package:flutter/material.dart';

import '../data/driver_data.dart';
import '../data/vehicle_loan_data.dart';
import '../models/admin_dashboard.dart';
import '../models/driver.dart';
import '../models/vehicle_loan.dart';

/// Sumber data tunggal untuk halaman peminjaman Admin.
///
/// Beranda Admin, Daftar Peminjaman, halaman Detail, dan Konfirmasi Driver
/// semuanya membaca dan menulis lewat state ini berdasarkan `id` peminjaman,
/// jadi perubahan status atau driver langsung terlihat di semua halaman dan
/// tidak hilang saat berpindah halaman.
///
/// Nanti tinggal ganti daftar awal dengan data dari backend.
class AdminLoanState extends ChangeNotifier {
  AdminLoanState({List<VehicleLoan>? loans})
    : _loans = List<VehicleLoan>.of(loans ?? dummyVehicleLoans);

  final List<VehicleLoan> _loans;

  List<VehicleLoan> get loans => List<VehicleLoan>.unmodifiable(_loans);

  /// Mencari peminjaman berdasarkan id; dipakai halaman detail agar selalu
  /// menampilkan data terbaru dari state.
  VehicleLoan? byId(String id) {
    for (final loan in _loans) {
      if (loan.id == id) {
        return loan;
      }
    }
    return null;
  }

  void _replace(String id, VehicleLoan Function(VehicleLoan) update) {
    final index = _loans.indexWhere((loan) => loan.id == id);
    if (index == -1) {
      return;
    }
    _loans[index] = update(_loans[index]);
    notifyListeners();
  }

  /// Menetapkan driver untuk sebuah peminjaman mobil.
  void setDriver(String loanId, String driverId) =>
      _replace(loanId, (loan) => loan.copyWith(driverId: driverId));

  /// Menyetujui peminjaman. Untuk mobil, [driverId] wajib diisi.
  void approve(String loanId, {String? driverId}) => _replace(
    loanId,
    (loan) => loan.copyWith(
      status: AdminLoanStatus.disetujui,
      driverId: driverId,
    ),
  );

  /// Menolak peminjaman.
  void reject(String loanId) => _replace(
    loanId,
    (loan) => loan.copyWith(status: AdminLoanStatus.ditolak),
  );

  /// Mengembalikan ke daftar awal (dipakai test dan tombol batal).
  void reset() {
    _loans
      ..clear()
      ..addAll(dummyVehicleLoans);
    notifyListeners();
  }
}

class AdminLoanStateScope extends InheritedNotifier<AdminLoanState> {
  const AdminLoanStateScope({
    super.key,
    required AdminLoanState state,
    required super.child,
  }) : super(notifier: state);

  static AdminLoanState of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AdminLoanStateScope>();
    assert(scope != null, 'AdminLoanStateScope tidak ditemukan pada context.');
    return scope!.notifier!;
  }

  /// Versi nullable supaya halaman tetap bisa dibuka tanpa scope
  /// (misalnya saat test atau pratinjau).
  static AdminLoanState? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<AdminLoanStateScope>()
      ?.notifier;
}

/// Driver default untuk [loan], kalau mobil sudah punya driver yang ditentukan.
Driver? defaultDriverOf(AdminLoanState state, VehicleLoan loan) {
  if (loan.driverId != null) {
    for (final driver in dummyDrivers) {
      if (driver.id == loan.driverId) {
        return driver;
      }
    }
  }
  return defaultDriverFor(loan.vehicle, drivers: dummyDrivers);
}
