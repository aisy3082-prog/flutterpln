import 'package:flutter/material.dart';

/// Jenis notifikasi untuk Admin.
///
/// Berbeda dari notifikasi milik user: pesan di sini untuk aktivitas
/// peminjaman (pengajuan, pengembalian, BBM, perawatan, penolakan).
enum AdminNotificationType {
  peminjamanBaru,
  permintaanSelesai,
  pengisianBbm,
  perawatanKendaraan,
  peminjamanDitolak,
}

extension AdminNotificationTypeStyle on AdminNotificationType {
  String get label => switch (this) {
    AdminNotificationType.peminjamanBaru => 'Peminjaman Baru',
    AdminNotificationType.permintaanSelesai => 'Permintaan Selesai',
    AdminNotificationType.pengisianBbm => 'Pengisian BBM',
    AdminNotificationType.perawatanKendaraan => 'Perawatan Kendaraan',
    AdminNotificationType.peminjamanDitolak => 'Peminjaman Ditolak',
  };

  /// Warna lingkaran ikon, mengikuti desain.
  Color get color => switch (this) {
    AdminNotificationType.peminjamanBaru => const Color(0xFF1B74D1),
    AdminNotificationType.permintaanSelesai => const Color(0xFFC0A03C),
    AdminNotificationType.pengisianBbm => const Color(0xFF6BBF63),
    AdminNotificationType.perawatanKendaraan => const Color(0xFF1B74D1),
    AdminNotificationType.peminjamanDitolak => const Color(0xFFD93A2B),
  };

  IconData get icon => switch (this) {
    AdminNotificationType.peminjamanBaru => Icons.directions_car_rounded,
    AdminNotificationType.permintaanSelesai => Icons.check_rounded,
    AdminNotificationType.pengisianBbm => Icons.local_gas_station_rounded,
    AdminNotificationType.perawatanKendaraan => Icons.handyman_outlined,
    AdminNotificationType.peminjamanDitolak => Icons.close_rounded,
  };
}

/// Satu baris label/nilai pada blok informasi di halaman detail.
class AdminNotificationField {
  const AdminNotificationField(this.label, this.value, {this.isStatus = false});

  final String label;
  final String value;

  /// Kalau true, nilai ditampilkan sebagai badge status berwarna.
  final bool isStatus;
}

/// Model notifikasi Admin.
///
/// Field wajibnya (id, type, title, description, date, time, isRead) mengikuti
/// kontrak API. Sisa field hanya dipakai halaman detail sehingga model tetap
/// aman kalau backend hanya mengirim field dasar.
class AdminNotification {
  AdminNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    this.isRead = false,
    this.detailTitle,
    this.detailFields = const [],
    this.showLoanButton = false,
  });

  final String id;
  final AdminNotificationType type;
  final String title;
  final String description;
  final String date;
  final String time;

  /// `isRead` sengaja `bool` (bukan `final`) supaya bisa diubah lokal saat
  /// notifikasi dibuka; nanti nilainya datang dari server.
  bool isRead;

  /// Judul blok informasi di halaman detail, mis. "Detail Peminjaman".
  final String? detailTitle;

  /// Baris informasi sesuai jenis notifikasi.
  final List<AdminNotificationField> detailFields;

  /// Kalau true, halaman detail menampilkan tombol "Lihat Detail Peminjaman".
  final bool showLoanButton;

  /// Gabungan tanggal dan waktu untuk ditampilkan di card.
  String get dateTimeLabel => '$date - $time';

  AdminNotification copyWith({bool? isRead}) => AdminNotification(
    id: id,
    type: type,
    title: title,
    description: description,
    date: date,
    time: time,
    isRead: isRead ?? this.isRead,
    detailTitle: detailTitle,
    detailFields: detailFields,
    showLoanButton: showLoanButton,
  );
}
