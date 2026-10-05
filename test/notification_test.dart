import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_plnmobile/data/notification_data.dart';
import 'package:flutter_application_plnmobile/models/app_notification.dart';
import 'package:flutter_application_plnmobile/pages/driver_confirm_page.dart';
import 'package:flutter_application_plnmobile/pages/home_page.dart';
import 'package:flutter_application_plnmobile/pages/notification_detail_page.dart';
import 'package:flutter_application_plnmobile/pages/notification_page.dart';
import 'package:flutter_application_plnmobile/pages/app_shell_page.dart';
import 'package:flutter_application_plnmobile/pages/queue_page.dart';
import 'package:flutter_application_plnmobile/pages/trip_completed_page.dart';
import 'package:flutter_application_plnmobile/services/data_result.dart';
import 'package:flutter_application_plnmobile/services/notification_service.dart';
import 'package:flutter_application_plnmobile/state/loan_state.dart';
import 'package:flutter_application_plnmobile/state/notification_state.dart';
import 'package:flutter_application_plnmobile/widgets/notification_card.dart';
import 'package:flutter_application_plnmobile/widgets/state_views.dart';

class _FakeNotificationService implements NotificationService {
  _FakeNotificationService(this.items);

  final List<AppNotification> items;

  @override
  Future<DataResult<List<AppNotification>>> loadNotifications() async {
    if (items.isEmpty) {
      return const DataResult.empty();
    }
    return DataResult.success(items);
  }
}

class _PendingNotificationService implements NotificationService {
  final Completer<void> _pending = Completer<void>();

  void release() => _pending.complete();

  @override
  Future<DataResult<List<AppNotification>>> loadNotifications() async {
    await _pending.future;
    return DataResult.success(dummyNotifications);
  }
}

Widget _host(Widget child, {NotificationState? state}) {
  return LoanStateScope(
    state: LoanState(),
    child: NotificationStateScope(
      state: state ?? NotificationState(),
      child: MaterialApp(home: child),
    ),
  );
}

void main() {
  group('Halaman Notifikasi', () {
    testWidgets('menampilkan header, filter, dan daftar notifikasi', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const NotificationPage()));
      await tester.pumpAndSettle();

      // Halaman Notifikasi tidak lagi punya navbar sendiri; navbar dipegang
      // AppShellPage.
      expect(find.text('Notifikasi'), findsOneWidget);
      expect(
        find.text(
          'Informasi terbaru tentang peminjaman kendaraan dan aktivitas lainnya.',
        ),
        findsOneWidget,
      );
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Belum dibaca'), findsOneWidget);
      expect(find.text('Dibaca'), findsOneWidget);

      expect(find.text('Perjalanan Selesai'), findsOneWidget);
      expect(find.text('Pengajuan disetujui'), findsOneWidget);
      expect(find.text('Driver telah ditugaskan'), findsOneWidget);
      expect(find.byType(NotificationCard), findsNWidgets(3));
    });

    testWidgets('menampilkan loading sebelum data arrived', (
      WidgetTester tester,
    ) async {
      final service = _PendingNotificationService();
      await tester.pumpWidget(_host(NotificationPage(service: service)));

      await tester.pump();
      expect(find.byType(LoadingStateView), findsOneWidget);

      service.release();
      await tester.pumpAndSettle();
      expect(find.byType(LoadingStateView), findsNothing);
      expect(find.byType(NotificationCard), findsNWidgets(3));
    });

    testWidgets('menampilkan empty state saat tidak ada notifikasi', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(NotificationPage(service: _FakeNotificationService([]))),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tidak ada notifikasi'), findsOneWidget);
      expect(
        find.text('Belum ada informasi atau aktivitas terbaru.'),
        findsOneWidget,
      );
    });
  });

  group('Filter read / unread', () {
    testWidgets('filter Belum dibaca hanya menampilkan yang belum dibaca', (
      WidgetTester tester,
    ) async {
      final state = NotificationState();
      await tester.pumpWidget(_host(const NotificationPage(), state: state));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Belum dibaca'));
      await tester.pumpAndSettle();

      expect(state.filter, NotificationFilter.belumDibaca);
      expect(find.text('Perjalanan Selesai'), findsNothing);
      expect(find.text('Pengajuan disetujui'), findsOneWidget);
      expect(find.text('Driver telah ditugaskan'), findsOneWidget);
    });

    testWidgets('filter Dibaca hanya menampilkan yang sudah dibaca', (
      WidgetTester tester,
    ) async {
      final state = NotificationState();
      await tester.pumpWidget(_host(const NotificationPage(), state: state));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dibaca'));
      await tester.pumpAndSettle();

      expect(state.filter, NotificationFilter.dibaca);
      expect(find.text('Perjalanan Selesai'), findsOneWidget);
      expect(find.text('Pengajuan disetujui'), findsNothing);
      expect(find.text('Driver telah ditugaskan'), findsNothing);
    });

    testWidgets('membuka notifikasi menandainya sebagai sudah dibaca', (
      WidgetTester tester,
    ) async {
      final state = NotificationState();
      await tester.pumpWidget(_host(const NotificationPage(), state: state));
      await tester.pumpAndSettle();

      expect(state.unreadCount, 2);

      await tester.tap(find.text('Driver telah ditugaskan'));
      await tester.pumpAndSettle();

      expect(state.unreadCount, 1);
      expect(
        state.notifications.firstWhere((n) => n.id == 'notif-003').isRead,
        isTrue,
      );
    });

    testWidgets('indikator titik muncul pada notifikasi yang belum dibaca', (
      WidgetTester tester,
    ) async {
      final state = NotificationState();
      await tester.pumpWidget(_host(const NotificationPage(), state: state));
      await tester.pumpAndSettle();

      // Dua notifikasi belum dibaca -> dua titik indikator.
      expect(state.unreadCount, 2);

      // Setelah satu dibuka, hanya tersisa satu notifikasi belum dibaca.
      await tester.tap(find.text('Pengajuan disetujui'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(state.unreadCount, 1);
      expect(find.byType(NotificationCard), findsNWidgets(3));
    });
  });

  group('Navigasi detail notifikasi', () {
    testWidgets('Perjalanan Selesai membuka halaman Perjalanan Selesai', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const NotificationPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Perjalanan Selesai'));
      await tester.pumpAndSettle();

      expect(find.byType(TripCompletedPage), findsOneWidget);
      expect(find.text('Informasi Kendaraan'), findsOneWidget);
      expect(find.text('Rincian Perjalanan'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('186 km'), findsOneWidget);
    });

    testWidgets('Pengajuan disetujui membuka Detail Notifikasi', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const NotificationPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pengajuan disetujui'));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationDetailPage), findsOneWidget);
      expect(find.text('Kegiatan di Yogyakarta'), findsOneWidget);
      expect(find.text('14 April 2026 - 15 April 2026'), findsOneWidget);
    });

    testWidgets('Driver ditugaskan membuka Konfirmasi Driver', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const NotificationPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Driver telah ditugaskan'));
      await tester.pumpAndSettle();

      expect(find.byType(DriverConfirmPage), findsOneWidget);
      expect(find.text('Tersedia'), findsOneWidget);
      expect(find.text('B 1234 XX'), findsOneWidget);
    });

    testWidgets('Lihat Detail Peminjaman membuka halaman detail peminjaman', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const NotificationPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Driver telah ditugaskan'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lihat Detail Peminjaman'));
      await tester.pumpAndSettle();

      expect(find.byType(QueuePage), findsOneWidget);
    });

    testWidgets('tombol back pada halaman detail kembali ke daftar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const NotificationPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pengajuan disetujui'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(NotificationPage), findsOneWidget);
      expect(find.byType(NotificationDetailPage), findsNothing);
    });
  });

  testWidgets('shell bisa membuka halaman Notifikasi dari Beranda', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(const AppShellPage()));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('app_bottom_nav_notifikasi')));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationPage, skipOffstage: true), findsOneWidget);
  });

  testWidgets('halaman notifikasi responsif dan tidak overflow', (
    WidgetTester tester,
  ) async {
    for (final size in const [Size(320, 480), Size(393, 852)]) {
      await tester.binding.setSurfaceSize(size);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(_host(const NotificationPage()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'list at $size');

      // Targetkan card di daftar, bukan judul halaman detail.
      await tester.tap(
        find.descendant(
          of: find.byType(NotificationCard),
          matching: find.text('Perjalanan Selesai'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TripCompletedPage), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'trip detail at $size');

      await tester.binding.setSurfaceSize(null);
    }
  });
}
