import 'package:flutter/material.dart';

import 'vehicle.dart';

/// Status peminjaman pada daftar "Peminjaman Terbaru" milik Admin.
///
/// Menunggu -> Disetujui atau Ditolak. Sesudah itu statusnya tidak berubah lagi.
enum AdminLoanStatus { menunggu, disetujui, ditolak }

extension AdminLoanStatusLabel on AdminLoanStatus {
  String get label => switch (this) {
    AdminLoanStatus.menunggu => 'Menunggu',
    AdminLoanStatus.disetujui => 'Disetujui',
    AdminLoanStatus.ditolak => 'Ditolak',
  };

  /// Label panjang yang dipakai pada halaman detail.
  String get detailLabel => switch (this) {
    AdminLoanStatus.menunggu => 'Menunggu Persetujuan',
    AdminLoanStatus.disetujui => 'Disetujui',
    AdminLoanStatus.ditolak => 'Ditolak',
  };
}

/// Warna kartu statistik pada dashboard Beranda Admin.
enum AdminStatTint { biru, hijau, merah, kuning }

extension AdminStatTintPalette on AdminStatTint {
  Color get foreground => switch (this) {
    AdminStatTint.biru => const Color(0xFF0B75D1),
    AdminStatTint.hijau => const Color(0xFF35A744),
    AdminStatTint.merah => const Color(0xFFC0392B),
    AdminStatTint.kuning => const Color(0xFFD4A017),
  };

  /// Warna latar lingkaran ikon, dibuat sangat lembut agar tidak mencolok.
  Color get background => switch (this) {
    AdminStatTint.biru => const Color(0xFFE4F0FF),
    AdminStatTint.hijau => const Color(0xFFE7F6EA),
    AdminStatTint.merah => const Color(0xFFFBE7E5),
    AdminStatTint.kuning => const Color(0xFFFBF1DC),
  };
}

/// Satu kartu statistik pada dashboard Beranda Admin.
class AdminStat {
  const AdminStat({
    required this.icon,
    required this.title,
    required this.value,
    required this.caption,
    required this.tint,
  });

  final IconData icon;
  final String title;
  final int value;
  final String caption;
  final AdminStatTint tint;
}

/// Satu baris peminjaman terbaru pada Beranda Admin.
class AdminLoan {
  const AdminLoan({
    required this.vehicleName,
    required this.vehicleType,
    required this.dateTime,
    required this.status,
  });

  final String vehicleName;
  final VehicleType vehicleType;
  final String dateTime;
  final AdminLoanStatus status;
}
