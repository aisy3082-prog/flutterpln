import 'package:flutter/material.dart';

import '../models/admin_profile.dart';
import '../state/admin_auth_state.dart';
import '../utils/constants.dart';
import '../pages/admin/admin_navigation.dart';

/// Bagian kanan header halaman Admin: ikon notifikasi, avatar + nama + chevron.
///
/// Semua cluster profil bisa ditekan untuk membuka Profil — bukan hanya
/// avatar-nya. Dipakai bersama oleh Beranda Admin, Detail Peminjaman,
/// Konfirmasi Driver, Detail Kendaraan, dan Edit Kendaraan supaya tidak
/// ada implementasi header yang berbeda-beda.
class AdminHeaderActions extends StatelessWidget {
  const AdminHeaderActions({super.key});

  @override
  Widget build(BuildContext context) {
    final profile =
        AdminAuthStateScope.maybeOf(context)?.profile ?? dummyAdminProfile;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => openAdminTab(
                  context,
                  index: AdminShellPage.indexNotifikasi,
                ),
                child: Tooltip(
                  message: 'Notifikasi',
                  child: const Icon(Icons.notifications_none, size: 18),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Material(
            color: Colors.transparent,
            child: InkWell(
              key: const ValueKey('admin_header_profile_entry'),
              onTap: () =>
                  openAdminTab(context, index: AdminShellPage.indexProfil),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 2,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7B3FE4),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        profile.initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        profile.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 15,
                      color: Color(0xFF9AA3AB),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// AppBar standart halaman Admin: tombol kembali, judul rata kiri, dan
/// [AdminHeaderActions] di kanan.
class AdminPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdminPageAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions = const [],
    this.leading = true,
  });

  final String title;
  final VoidCallback? onBack;
  final List<Widget> actions;

  /// Kalau false, tombol kembali disembunyikan (halaman sudah root).
  final bool leading;

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textStrong,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      toolbarHeight: 44,
      leading: leading
          ? IconButton(
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.chevron_left, size: 22),
              tooltip: 'Kembali',
            )
          : null,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textStrong,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: actions.isEmpty
          ? const [AdminHeaderActions()]
          : [...actions, const AdminHeaderActions()],
    );
  }
}
