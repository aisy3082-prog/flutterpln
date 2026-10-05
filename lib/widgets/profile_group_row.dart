import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Kartu berisi sekumpulan baris profil dengan gaya *grouped list*.
///
/// Berbeda dengan [ProfileMenuCard] yang memberi setiap baris border sendiri,
/// di sini semua baris berada dalam satu kartu dengan satu border luar dan
/// pemisah berupa garis tipis, supaya tidak terlihat seperti tumpukan
/// kotak-kotak terpisah. Dipakai bersama oleh halaman Profil user dan Admin.
class ProfileGroupCard extends StatelessWidget {
  const ProfileGroupCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSoft),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                thickness: 1,
                indent: 54,
                color: AppColors.borderSoft,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Baris data di dalam [ProfileGroupCard]: ikon, label, nilai, dan chevron.
///
/// Area ketukannya menutupi seluruh baris, dan chevron hanya muncul kalau
/// [onTap] diisi supaya baris yang hanya keterangan tidak memberi kesan keliru.
class ProfileGroupRow extends StatelessWidget {
  const ProfileGroupRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
    this.showChevron = true,
    this.controller,
    this.editable = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;

  /// Kalau false, chevron sengaja dimatikan walau baris bisa ditekan.
  final bool showChevron;

  /// Isi input saat baris berada dalam mode edit.
  final TextEditingController? controller;

  /// Kalau true, nilai diganti menjadi input yang bisa diisi.
  final bool editable;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      child: Row(
        children: [
          _ProfileIconBadge(icon: icon),
          const SizedBox(width: AppSpacing.xl),
          // Label memakai lebar tetap supaya kolom nilai selalu sejajar
          // antar baris dan tidak terlihat berantakan.
          SizedBox(
            width: 86,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textStrong,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            // Di mode edit nilai menjadi input, supaya Akses, Nomor HP, dan
            // Email bisa diisi langsung di halaman Data Diri.
            child: editable
                ? TextField(
                    controller: controller,
                    textAlign: TextAlign.right,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(
                      color: AppColors.textStrong,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  )
                : Text(
                    value ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
          ),
          if (showChevron && onTap != null) ...[
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: Color(0xFF9AA3AB),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return row;
    }

    return Material(
      color: Colors.white,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

class _ProfileIconBadge extends StatelessWidget {
  const _ProfileIconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: const BoxDecoration(
        color: AppColors.primarySoft,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 14, color: AppColors.primary),
    );
  }
}