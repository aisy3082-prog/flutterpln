import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/admin_notification.dart';
import '../../models/vehicle.dart';
import '../../state/admin_notification_state.dart';
import '../../utils/constants.dart';
import '../../widgets/admin_header_actions.dart';
import 'admin_loan_list_page.dart';

/// Halaman "Detail Notifikasi" untuk Admin.
///
/// Menampilkan isi lengkap notifikasi: ikon besar, judul, waktu, deskripsi,
/// dan informasi tambahan sesuai jenis notifikasi. Membuka halaman ini juga
/// menandai notifikasi sebagai sudah dibaca sehingga badge berkurang.
class AdminNotificationDetailPage extends StatelessWidget {
  const AdminNotificationDetailPage({super.key, required this.notificationId});

  final String notificationId;

  @override
  Widget build(BuildContext context) {
    final state = AdminNotificationStateScope.of(context);
    final notification = state.byId(notificationId);

    if (notification == null) {
      return const _MissingNotificationScaffold();
    }

    // Notifikasi dianggap sudah dibaca begitu detailnya dibuka. Pemanggilan
    // ditunda ke frame berikutnya supaya tidak memicu rebuild scope di tengah
    // proses build halaman ini.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => state.markAsRead(notification.id),
    );

    final type = notification.type;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const AdminPageAppBar(title: 'Detail Notifikasi'),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: type.color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(type.icon, color: Colors.white, size: 32),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Text(
                  notification.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textStrong,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Center(
                child: Text(
                  notification.dateTimeLabel,
                  style: const TextStyle(
                    color: AppColors.textSubtle,
                    fontSize: 9,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                notification.description,
                style: const TextStyle(
                  color: AppColors.textStrong,
                  fontSize: 10,
                  height: 1.5,
                ),
              ),
              if (notification.detailFields.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxl),
                _DetailBlock(notification: notification),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Blok informasi tambahan sesuai jenis notifikasi.
class _DetailBlock extends StatelessWidget {
  const _DetailBlock({required this.notification});

  final AdminNotification notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            notification.detailTitle ?? 'Detail',
            style: const TextStyle(
              color: AppColors.textStrong,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < notification.detailFields.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            _FieldRow(field: notification.detailFields[i]),
          ],
          if (notification.showLoanButton) ...[
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () => _openLoanDetail(context),
                icon: const Icon(Icons.directions_car_outlined, size: 15),
                label: const Text('Lihat Detail Peminjaman'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Membuka Daftar Peminjaman yang sudah ada, dengan filter sesuai jenis
  /// kendaraan agar Admin langsung melihat data yang relevan.
  void _openLoanDetail(BuildContext context) {
    final text = notification.description.toLowerCase();
    // Kalau jenis kendaraan tidak disebut, buka daftar tanpa filter.
    final filter = text.contains('motor')
        ? VehicleType.motor
        : (text.contains('mobil') ? VehicleType.mobil : null);

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdminLoanListPage(initialFilter: filter),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.field});

  final AdminNotificationField field;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 116,
          child: Text(
            field.label,
            style: const TextStyle(color: AppColors.textSubtle, fontSize: 9),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: field.isStatus
                ? _StatusBadge(value: field.value)
                : Text(
                    field.value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: AppColors.textStrong,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

/// Badge untuk nilai status pada halaman detail.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final color = switch (value) {
      'Disetujui' || 'Selesai' => const Color(0xFF16813B),
      'Ditolak' => const Color(0xFFD64B4B),
      _ => const Color(0xFF0B75D1),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MissingNotificationScaffold extends StatelessWidget {
  const _MissingNotificationScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminPageAppBar(title: 'Detail Notifikasi'),
      body: const Center(
        child: Text(
          'Data notifikasi tidak ditemukan',
          style: TextStyle(color: AppColors.textSubtle, fontSize: 10),
        ),
      ),
    );
  }
}
