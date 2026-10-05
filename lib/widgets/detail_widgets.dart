import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Baris label-value yang dipakai di card informasi kendaraan, driver, dan
/// rincian perjalanan. Mengikuti tampilan dua kolom dengan titik dua.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.showColon = true,
  });

  final String label;
  final String value;
  final bool showColon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSubtle, fontSize: 9),
            ),
          ),
          if (showColon)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                ':',
                style: TextStyle(color: AppColors.textSubtle, fontSize: 9),
              ),
            ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textStrong,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Judul section di dalam card putih (Informasi Kendaraan, Driver, dll).
class InfoSectionTitle extends StatelessWidget {
  const InfoSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textStrong,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// Garis pemisah antar section di dalam card.
class InfoDivider extends StatelessWidget {
  const InfoDivider({
    super.key,
    this.margin = const EdgeInsets.symmetric(vertical: 2),
  });

  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Container(margin: margin, height: 1, color: AppColors.borderSoft);
  }
}

/// Tombol biru solid untuk aksi utama.
class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Tombol biru muda dengan teks biru untuk aksi sekunder
/// ("Lihat Detail Peminjaman").
class SoftActionButton extends StatelessWidget {
  const SoftActionButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.softButton,
          foregroundColor: AppColors.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
