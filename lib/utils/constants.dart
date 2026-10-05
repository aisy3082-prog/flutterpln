import 'package:flutter/material.dart';

/// Token warna, radius, dan spacing yang dipakai halaman baru.
/// Nilai-nilai ini sengaja disamakan dengan tema yang sudah dipakai
/// halaman existing agar tidak ada desain yang berbeda antar halaman.
class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF0B75D1);
  static const Color primarySoft = Color(0xFFEAF3FF);
  static const Color textStrong = Color(0xFF20252B);
  static const Color textMuted = Color(0xFF65707A);
  static const Color textSubtle = Color(0xFF77818B);
  static const Color border = Color(0xFFDCE1E6);
  static const Color borderSoft = Color(0xFFE1E5E8);
  static const Color borderBlue = Color(0xFFDCE5EF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surfaceMuted = Color(0xFFF8FAFC);
  static const Color segmentedTrack = Color(0xFFE6E8EB);
  static const Color danger = Color(0xFFD9534F);
  static const Color emptyAccent = Color(0xFFFF5B5B);

  // Status sukses dipakai pada notifikasi Perjalanan Selesai & Pengajuan.
  static const Color success = Color(0xFF1DB954);
  static const Color successSoft = Color(0xFFE9F8EE);
  static const Color successBorder = Color(0xFFCDEEDB);
  static const Color successText = Color(0xFF14803C);

  // Tombol sekunder (Lihat Detail Peminjaman) dan ikon netral.
  static const Color softButton = Color(0xFFDDE9FB);
  static const Color softButtonPressed = Color(0xFFC7DAF7);
  static const Color neutralIcon = Color(0xFFEFF1F3);
}

class AppRadius {
  const AppRadius._();

  static const double small = 6;
  static const double medium = 7;
  static const double card = 9;
  static const double large = 10;
  static const double pill = 8;
}

class AppSpacing {
  const AppSpacing._();

  static const double xs = 2;
  static const double sm = 3;
  static const double md = 8;
  static const double lg = 10;
  static const double xl = 12;
  static const double xxl = 16;

  static const double pageHorizontal = 16;
  static const double pageBottom = 18;
}

class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x12000000), blurRadius: 3, offset: Offset(0, 2)),
  ];
}
