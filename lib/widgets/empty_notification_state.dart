import 'package:flutter/material.dart';

import 'state_views.dart';

/// Empty state khusus halaman Notifikasi, tetap memakai style aplikasi.
class EmptyNotificationState extends StatelessWidget {
  const EmptyNotificationState({super.key, this.title, this.description});

  final String? title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return EmptyStateView(
      title: title ?? 'Tidak ada notifikasi',
      description: description ?? 'Belum ada informasi atau aktivitas terbaru.',
      icon: Icons.notifications_none,
    );
  }
}
