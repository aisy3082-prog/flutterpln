import 'dart:io';

import 'package:flutter/material.dart';

import '../models/vehicle.dart';

/// Menampilkan foto kendaraan dari perangkat atau dari assets.
///
/// Dibuat sebagai satu komponen supaya semua tempat yang menampilkan foto
/// kendaraan (daftar, form, dan kartu peminjaman) konsisten dan tidak salah
/// memakai [Image.asset] untuk file hasil unggahan.
class VehiclePhoto extends StatelessWidget {
  const VehiclePhoto({
    super.key,
    required this.vehicle,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.fallbackIcon = Icons.directions_car,
    this.backgroundColor,
    this.borderRadius,
  });

  final Vehicle vehicle;
  final BoxFit fit;
  final double? width;
  final double? height;
  final IconData fallbackIcon;

  /// Latar di belakang foto.
  ///
  /// Foto kendaraan bawaan (`mobil.png`, `motor.jpeg`) berlatar putih, jadi
  /// kalau diletakkan di atas kartu putih mobilnya nyaris tak terlihat dan
  /// terlihat seperti foto hilang. Memberi latar tipis membuat siluet mobil
  /// tetap terbaca.
  final Color? backgroundColor;

  /// Sudut untuk latar, dipakai bersama [backgroundColor].
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final path = vehicle.photoPath;
    final image = path != null && path.isNotEmpty
        ? Image.file(
            File(path),
            fit: fit,
            errorBuilder: (context, _, _) => _fallback(),
          )
        : Image.asset(
            vehicle.imageAsset,
            fit: fit,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, _, _) => _fallback(),
          );

    final content = SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: image,
      ),
    );

    final background = backgroundColor;
    if (background == null) {
      return content;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: background,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: content,
    );
  }

  Widget _fallback() => Icon(
    fallbackIcon,
    size: 26,
    color: const Color(0xFFB4BCC4),
  );
}
