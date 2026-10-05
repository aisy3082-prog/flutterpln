import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/admin_notification_state.dart';
import '../../utils/constants.dart';
import '../../widgets/admin_bottom_navigation.dart';
import '../../widgets/admin_notification_card.dart';
import 'admin_navigation.dart';
import 'admin_notification_detail_page.dart';

/// Halaman "Notifikasi" milik Admin.
///
/// Daftar notifikasi berupa card yang dapat ditekan untuk membuka Detail
/// Notifikasi. Membuka detail menandai notifikasi sebagai sudah dibaca,
/// sehingga badge pada bottom nav ikut berkurang.
class AdminNotificationPage extends StatelessWidget {
  const AdminNotificationPage({super.key, this.embedded = false});

  /// Kalau true, navbar tidak ditampilkan karena host shell yang menanganinya.
  /// Sama seperti halaman Admin lain agar tidak terjadi navbar ganda.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final state = AdminNotificationStateScope.of(context);
    final notifications = state.notifications;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const _NotificationAppBar(),
        body: SafeArea(
          top: false,
          child: notifications.isEmpty
              ? const _EmptyNotificationState()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.xl),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return AdminNotificationCard(
                      notification: notification,
                      onTap: () => _openDetail(context, notification.id),
                    );
                  },
                ),
        ),
        bottomNavigationBar: embedded
            ? null
            : AdminBottomNavigation(
                selectedIndex: AdminShellPage.indexNotifikasi,
                onSelected: (index) => openAdminTab(context, index: index),
                unreadNotificationCount: true,
              ),
      ),
    );
  }

  void _openDetail(BuildContext context, String id) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdminNotificationDetailPage(notificationId: id),
      ),
    );
  }
}

/// Header "Notifikasi": ikon lonceng di kiri judul.
///
/// Berbeda dari halaman Admin lain yang memakai tombol kembali, karena
/// Notifikasi diakses lewat tab dan tidak punya halaman sebelumnya.
class _NotificationAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _NotificationAppBar();

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
      leadingWidth: 40,
      leading: const Padding(
        padding: EdgeInsets.only(left: 12),
        child: Icon(Icons.notifications_none, size: 21),
      ),
      title: const Text(
        'Notifikasi',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.textStrong,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyNotificationState extends StatelessWidget {
  const _EmptyNotificationState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none,
              size: 40,
              color: Color(0xFFB4BCC4),
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              'Belum ada notifikasi',
              style: TextStyle(
                color: Color(0xFF77818B),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Pemberitahuan terbaru akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF9AA3AB), fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}
