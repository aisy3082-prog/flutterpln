import 'package:flutter/material.dart';

import '../data/notification_data.dart';
import '../models/app_notification.dart';

/// Filter tab pada halaman Notifikasi.
enum NotificationFilter { semua, belumDibaca, dibaca }

extension NotificationFilterLabel on NotificationFilter {
  String get label => switch (this) {
    NotificationFilter.semua => 'Semua',
    NotificationFilter.belumDibaca => 'Belum dibaca',
    NotificationFilter.dibaca => 'Dibaca',
  };
}

/// Menyimpan daftar notifikasi, filter aktif, dan status read/unread.
///
/// Berpola sama dengan [LoanStateScope] supaya konsisten di seluruh app.
class NotificationState extends ChangeNotifier {
  NotificationState() : _notifications = buildDummyNotifications();

  final List<AppNotification> _notifications;
  NotificationFilter _filter = NotificationFilter.semua;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  NotificationFilter get filter => _filter;

  /// Jumlah notifikasi yang belum dibaca; dipakai untuk badge bottom nav.
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Notifikasi sesuai filter aktif.
  List<AppNotification> get visibleNotifications => switch (_filter) {
    NotificationFilter.semua => notifications,
    NotificationFilter.belumDibaca =>
      notifications.where((n) => !n.isRead).toList(growable: false),
    NotificationFilter.dibaca =>
      notifications.where((n) => n.isRead).toList(growable: false),
  };

  void setFilter(NotificationFilter filter) {
    if (_filter == filter) {
      return;
    }
    _filter = filter;
    notifyListeners();
  }

  /// Tandai notifikasi sebagai sudah dibaca.
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1 || _notifications[index].isRead) {
      return;
    }
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();
  }

  /// Kembalikan seluruh notifikasi ke kondisi belum dibaca (untuk simulasi).
  void resetToDummy() {
    _notifications
      ..clear()
      ..addAll(buildDummyNotifications());
    _filter = NotificationFilter.semua;
    notifyListeners();
  }
}

class NotificationStateScope extends InheritedNotifier<NotificationState> {
  const NotificationStateScope({
    super.key,
    required NotificationState state,
    required super.child,
  }) : super(notifier: state);

  static NotificationState of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<NotificationStateScope>();
    assert(scope != null, 'NotificationStateScope tidak ditemukan.');
    return scope!.notifier!;
  }

  /// Versi nullable untuk halaman yang bisa dibuka tanpa scope.
  static NotificationState? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<NotificationStateScope>()
      ?.notifier;
}
