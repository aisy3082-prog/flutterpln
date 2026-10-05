import 'package:flutter/material.dart';

import '../data/admin_notification_data.dart';
import '../models/admin_notification.dart';

/// Sumber data notifikasi Admin.
///
/// Menyimpan daftar notifikasi beserta status read/unread. Badge bottom nav
/// dan halaman Notifikasi membaca dari state yang sama, sehingga jumlah
/// unread selalu sinkron di mana pun.
///
/// Berpola sama dengan [AdminLoanState] supaya konsisten di area Admin.
/// Nanti cukup ganti daftar awal dengan data dari backend.
class AdminNotificationState extends ChangeNotifier {
  AdminNotificationState({List<AdminNotification>? notifications})
    : _notifications = List<AdminNotification>.of(
        notifications ?? buildDummyAdminNotifications(),
      );

  final List<AdminNotification> _notifications;

  List<AdminNotification> get notifications =>
      List<AdminNotification>.unmodifiable(_notifications);

  /// Jumlah notifikasi belum dibaca; sumber untuk badge bottom nav.
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  AdminNotification? byId(String id) {
    for (final notification in _notifications) {
      if (notification.id == id) {
        return notification;
      }
    }
    return null;
  }

  /// Tandai notifikasi sudah dibaca. Idempoten: memanggil dua kali tidak
  /// memicu rebuild kedua.
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1 || _notifications[index].isRead) {
      return;
    }
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();
  }

  /// Tandai semua notifikasi sudah dibaca.
  void markAllAsRead() {
    var changed = false;
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  /// Kembalikan ke kondisi awal (untuk simulasi/test).
  void reset() {
    _notifications
      ..clear()
      ..addAll(buildDummyAdminNotifications());
    notifyListeners();
  }
}

class AdminNotificationStateScope
    extends InheritedNotifier<AdminNotificationState> {
  const AdminNotificationStateScope({
    super.key,
    required AdminNotificationState state,
    required super.child,
  }) : super(notifier: state);

  static AdminNotificationState of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AdminNotificationStateScope>();
    assert(scope != null, 'AdminNotificationStateScope tidak ditemukan.');
    return scope!.notifier!;
  }

  static AdminNotificationState? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<AdminNotificationStateScope>()
      ?.notifier;
}
