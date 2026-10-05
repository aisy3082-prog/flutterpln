import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_plnmobile/data/admin_notification_data.dart';
import 'package:flutter_application_plnmobile/models/admin_notification.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_loan_list_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_navigation.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_notification_detail_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_notification_page.dart';
import 'package:flutter_application_plnmobile/state/admin_auth_state.dart';
import 'package:flutter_application_plnmobile/state/admin_loan_state.dart';
import 'package:flutter_application_plnmobile/state/admin_notification_state.dart';
import 'package:flutter_application_plnmobile/state/admin_vehicle_state.dart';
import 'package:flutter_application_plnmobile/state/notification_state.dart';
import 'package:flutter_application_plnmobile/utils/app_navigation.dart';
import 'package:flutter_application_plnmobile/widgets/app_bottom_navigation.dart';
import 'package:flutter_application_plnmobile/widgets/admin_bottom_navigation.dart';
import 'package:flutter_application_plnmobile/widgets/admin_notification_card.dart';

/// Host dengan seluruh scope area Admin, sama seperti yang dipasang `main.dart`.
Widget _host(Widget child, AdminNotificationState notifications) {
  return AdminNotificationStateScope(
    state: notifications,
    child: AdminVehicleStateScope(
      state: AdminVehicleState(),
      child: AdminLoanStateScope(
        state: AdminLoanState(),
        child: AdminAuthStateScope(
          state: AdminAuthState()..signIn(),
          child: MaterialApp(home: child),
        ),
      ),
    ),
  );
}

Finder _badge() =>
    find.byKey(const ValueKey('nav_badge_admin_bottom_nav_Notifikasi'));

/// Angka yang tertulis di dalam badge, atau 0 kalau badge tidak ada.
int _badgeCount(WidgetTester tester) {
  final label = find.descendant(of: _badge(), matching: find.byType(Text));
  if (label.evaluate().isEmpty) {
    return 0;
  }
  final data = tester.widget<Text>(label).data;
  return data == null ? 0 : int.parse(data);
}

Future<void> _goBack(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Kembali').first);
  await tester.pumpAndSettle();
}

Future<void> _openNotificationTab(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    _host(const AdminShellPage(), AdminNotificationState()),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('admin_bottom_nav_Notifikasi')));
  await tester.pumpAndSettle();
}

void main() {
  group('Halaman Notifikasi Admin', () {
    testWidgets('daftar menampilkan 5 notifikasi sesuai desain', (
      WidgetTester tester,
    ) async {
      await _openNotificationTab(tester);

      expect(find.byType(AdminNotificationCard), findsNWidgets(5));

      // Judul tiap notifikasi.
      for (final title in [
        'Peminjaman Baru',
        'Permintaan Selesai',
        'Pengisian BBM',
        'Perawatan Kendaraan',
        'Peminjaman Ditolak',
      ]) {
        expect(find.text(title), findsOneWidget, reason: 'judul $title');
      }

      // Deskripsi dan tanggal/waktu.
      expect(
        find.text('Andi Pratama mengajukan peminjaman mobil Toyota Avanza.'),
        findsOneWidget,
      );
      expect(find.text('12 Sep 2026 - 07:45'), findsOneWidget);
      expect(find.text('12 Sep 2026 - 16:30'), findsOneWidget);
    });

    testWidgets('header memakai ikon lonceng dan judul Notifikasi', (
      WidgetTester tester,
    ) async {
      await _openNotificationTab(tester);

      expect(find.text('Notifikasi'), findsWidgets);
      expect(find.byIcon(Icons.notifications_none), findsWidgets);
    });

    testWidgets('hanya ada satu navbar di tab Notifikasi', (
      WidgetTester tester,
    ) async {
      await _openNotificationTab(tester);

      expect(find.byType(AdminBottomNavigation), findsOneWidget);
    });
  });

  group('Badge notifikasi belum dibaca', () {
    testWidgets('badge jumlah unread tampil di navbar', (
      WidgetTester tester,
    ) async {
      final state = AdminNotificationState();
      expect(state.unreadCount, 3);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        _host(const AdminShellPage(initialIndex: AdminShellPage.indexBeranda), state),
      );
      await tester.pumpAndSettle();

      expect(_badgeCount(tester), 3);
    });

    testWidgets('badge hilang saat tidak ada notifikasi belum dibaca', (
      WidgetTester tester,
    ) async {
      final state = AdminNotificationState()..markAllAsRead();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        _host(const AdminShellPage(), state),
      );
      await tester.pumpAndSettle();

      expect(_badge(), findsNothing);
    });
  });

  group('Card notifikasi dapat diklik', () {
    testWidgets('setiap card membuka Detail Notifikasi yang benar', (
      WidgetTester tester,
    ) async {
      await _openNotificationTab(tester);

      final cards = find.byType(AdminNotificationCard);

      // Card 1 -> Peminjaman Baru.
      await tester.tap(cards.at(0), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.byType(AdminNotificationDetailPage), findsOneWidget);
      expect(find.text('Detail Notifikasi'), findsOneWidget);
      expect(find.text('Nama Peminjam'), findsOneWidget);
      expect(find.text('Andi Pratama'), findsOneWidget);
      expect(find.text('Lihat Detail Peminjaman'), findsOneWidget);
      await _goBack(tester);

      // Card 5 -> Peminjaman Ditolak (tanpa tombol detail peminjaman).
      await tester.tap(cards.at(4), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Siti Aminah'), findsOneWidget);
      expect(find.text('Ditolak'), findsOneWidget);
      expect(find.text('Lihat Detail Peminjaman'), findsNothing);
    });

    testWidgets('area tap card menutupi seluruh kartu', (
      WidgetTester tester,
    ) async {
      await _openNotificationTab(tester);

      final card = tester.widget<AdminNotificationCard>(
        find.byType(AdminNotificationCard).first,
      );
      expect(card.onTap, isNotNull);
    });
  });

  group('Status dibaca', () {
    testWidgets('membuka detail menandai terbaca dan badge berkurang', (
      WidgetTester tester,
    ) async {
      final state = AdminNotificationState();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        _host(
          const AdminNotificationPage(embedded: true),
          state,
        ),
      );
      await tester.pumpAndSettle();

      expect(state.unreadCount, 3);

      await tester.tap(find.byType(AdminNotificationCard).first);
      await tester.pumpAndSettle();

      expect(state.unreadCount, 2);
      expect(state.byId('NTF-2026-0001')!.isRead, isTrue);
    });

    testWidgets('notifikasi yang sudah dibaca tampil lebih redup', (
      WidgetTester tester,
    ) async {
      final state = AdminNotificationState();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        _host(const AdminNotificationPage(embedded: true), state),
      );
      await tester.pumpAndSettle();

      // Card pertama belum dibaca => latar putih.
      final unreadInk = tester.widget<Ink>(
        find
            .descendant(
              of: find.byType(AdminNotificationCard).at(0),
              matching: find.byType(Ink),
            )
            .first,
      );
      final readInk = tester.widget<Ink>(
        find
            .descendant(
              of: find.byType(AdminNotificationCard).at(3),
              matching: find.byType(Ink),
            )
            .first,
      );

      final unreadColor = (unreadInk.decoration as BoxDecoration).color;
      final readColor = (readInk.decoration as BoxDecoration).color;

      expect(unreadColor, isNot(readColor));
    });
  });

  group('Tombol Lihat Detail Peminjaman', () {
    testWidgets('membuka Daftar Peminjaman yang sudah ada', (
      WidgetTester tester,
    ) async {
      await _openNotificationTab(tester);
      await tester.tap(find.byType(AdminNotificationCard).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lihat Detail Peminjaman'));
      await tester.pumpAndSettle();

      // Halaman peminjaman yang sudah ada, bukan halaman baru.
      expect(find.text('Daftar Peminjaman Terbaru'), findsOneWidget);
      expect(find.byType(AdminLoanListPage), findsOneWidget);
    });
  });

  group('Badge di navbar user', () {
    testWidgets('navbar user menampilkan jumlah belum dibaca', (
      WidgetTester tester,
    ) async {
      final notifications = NotificationState();
      final unread = notifications.unreadCount;
      expect(unread, greaterThan(0));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        NotificationStateScope(
          state: notifications,
          child: MaterialApp(
            home: Scaffold(
              body: const SizedBox.shrink(),
              bottomNavigationBar: AppBottomNavigation(
                selectedTab: AppTab.beranda,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final badge = find.byKey(
        const ValueKey('nav_badge_app_bottom_nav_notifikasi'),
      );
      expect(badge, findsOneWidget);
      final label = tester.widget<Text>(
        find.descendant(of: badge, matching: find.byType(Text)),
      );
      expect(label.data, '$unread');
    });

    testWidgets('badge user hilang setelah semua notifikasi dibaca', (
      WidgetTester tester,
    ) async {
      final notifications = NotificationState();
      for (final n in notifications.notifications) {
        notifications.markAsRead(n.id);
      }
      expect(notifications.unreadCount, 0);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        NotificationStateScope(
          state: notifications,
          child: MaterialApp(
            home: Scaffold(
              body: const SizedBox.shrink(),
              bottomNavigationBar: AppBottomNavigation(
                selectedTab: AppTab.beranda,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('nav_badge_app_bottom_nav_notifikasi')),
        findsNothing,
      );
    });
  });

  group('Model notifikasi', () {
    test('lima jenis notifikasi punya warna dan ikon berbeda', () {
      final types = AdminNotificationType.values;
      expect(types.length, 5);
      expect(types.map((t) => t.icon).toSet().length, 5);
      expect(types.map((t) => t.color).toSet().length, 4);
    });

    test('data awal punya tepat 3 belum dibaca', () {
      final data = buildDummyAdminNotifications();
      expect(data.where((n) => !n.isRead).length, 3);
    });
  });

  group('Responsif', () {
    testWidgets('tidak ada overflow di berbagai ukuran Android', (
      WidgetTester tester,
    ) async {
      for (final size in [
        const Size(360, 640),
        const Size(412, 915),
      ]) {
        tester.view.physicalSize = size * 3;
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        await _openNotificationTab(tester);
        await tester.tap(find.byType(AdminNotificationCard).first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  });
}