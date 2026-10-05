import 'package:flutter/material.dart';

import '../state/notification_state.dart';
import '../utils/app_navigation.dart';
import 'app_nav_bar.dart';

/// Bottom Navigation milik area user (4 menu).
///
/// Hanya pembungkus [AppNavBar] supaya seluruh aplikasi memakai satu
/// komponen navbar dengan metrik yang sama. Tampilan user tetap datar.
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.selectedTab,
    this.onSelected,
  });

  final AppTab selectedTab;
  final ValueChanged<AppTab>? onSelected;

  /// Posisi menu Notifikasi pada [AppTab].
  static final int _notifikasiIndex = AppTab.notifikasi.index;

  @override
  Widget build(BuildContext context) {
    // Badge hanya menempel pada menu Notifikasi. Nilainya diambil dari scope
    // yang ada di halaman supaya ikut berubah begitu notifikasi dibaca.
    final unread = NotificationStateScope.maybeOf(context)?.unreadCount ?? 0;

    return AppNavBar(
      selectedIndex: AppTab.values.indexOf(selectedTab),
      onSelected: (index) {
        final handler = onSelected;
        if (handler != null) {
          handler(AppTab.values[index]);
          return;
        }
        navigateToAppTab(context, target: AppTab.values[index]);
      },
      items: [
        for (var i = 0; i < AppTab.values.length; i++)
          AppNavItem(
            key: 'app_bottom_nav_${AppTab.values[i].name}',
            label: AppTab.values[i].label,
            icon: AppTab.values[i].icon,
            badge: i == _notifikasiIndex ? unread : 0,
          ),
      ],
    );
  }
}
