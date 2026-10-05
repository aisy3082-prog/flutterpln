import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_plnmobile/main.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_home_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_loan_list_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_navigation.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_notification_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_profile_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_vehicle_page.dart';
import 'package:flutter_application_plnmobile/pages/login_page.dart';
import 'package:flutter_application_plnmobile/state/admin_auth_state.dart';
import 'package:flutter_application_plnmobile/state/admin_loan_state.dart';
import 'package:flutter_application_plnmobile/state/admin_notification_state.dart';
import 'package:flutter_application_plnmobile/state/admin_vehicle_state.dart';
import 'package:flutter_application_plnmobile/utils/app_navigation.dart';
import 'package:flutter_application_plnmobile/widgets/admin_bottom_navigation.dart';
import 'package:flutter_application_plnmobile/widgets/app_bottom_navigation.dart';
import 'package:flutter_application_plnmobile/widgets/app_nav_bar.dart';

Finder _adminNav(String label) =>
    find.byKey(ValueKey('admin_bottom_nav_$label'));
Finder _userNav(String label) =>
    find.byKey(ValueKey('app_bottom_nav_$label'));

int _adminIndex(WidgetTester tester) => tester
    .widget<AdminBottomNavigation>(find.byType(AdminBottomNavigation))
    .selectedIndex;

/// Structure navbar Admin sesuai UI/UX: 4 menu.
const _adminLabels = ['Beranda', 'Kendaraan', 'Notifikasi', 'Profil'];

const _adminPages = <int, Type>{
  0: AdminHomePage,
  1: AdminVehiclePage,
  2: AdminNotificationPage,
  3: AdminProfilePage,
};

Widget _host(Widget child) => AdminNotificationStateScope(
  state: AdminNotificationState(),
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

Future<void> bootAdmin(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(_host(const AdminShellPage()));
  await tester.pumpAndSettle();
}

void main() {
  group('TEST 1: Beranda -> Profil', () {
    testWidgets('TEST 1a: navbar Profil dari Beranda membuka Profil', (
      WidgetTester tester,
    ) async {
      await bootAdmin(tester);
      _expectOnAdminTab(tester, AdminShellPage.indexBeranda);

      await tester.tap(_adminNav('Profil'));
      await tester.pumpAndSettle();

      _expectOnAdminTab(tester, AdminShellPage.indexProfil);
      expect(find.text('Administrator'), findsWidgets);
      expect(tester.takeException(), isNull);
      expect(find.byType(ErrorWidget), findsNothing);
    });

    testWidgets('TEST 1b: cluster "Admin >" di header membuka Profil', (
      WidgetTester tester,
    ) async {
      await bootAdmin(tester);

      // Sebelumnya nama dan chevron tidak punya handler sama sekali.
      await tester.tap(find.byKey(const ValueKey('admin_header_profile_entry')));
      await tester.pumpAndSettle();

      _expectOnAdminTab(tester, AdminShellPage.indexProfil);
      expect(find.byType(AdminProfilePage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('TEST 1c: area header bisa diketuk di coordinate nyata', (
      WidgetTester tester,
    ) async {
      await bootAdmin(tester);

      final box = tester.getRect(
        find.byKey(const ValueKey('admin_header_profile_entry')),
      );
      expect(box.width, greaterThan(30), reason: 'area tap harus lega');
      await tester.tapAt(box.center);
      await tester.pumpAndSettle();

      _expectOnAdminTab(tester, AdminShellPage.indexProfil);
    });
  });

  group('TEST 2-5: semua menu navbar membuka halaman yang benar', () {
    testWidgets('TEST 2-5: Beranda -> tiap menu', (
      WidgetTester tester,
    ) async {
      for (final target in const [3, 0, 1, 2]) {
        await bootAdmin(tester);

        await tester.tap(_adminNav(_adminLabels[target]));
        await tester.pumpAndSettle();

        _expectOnAdminTab(tester, target);
      }
    });
  });

  group('TEST 6: hanya satu navbar', () {
    testWidgets('TEST 6: satu navbar di tiap tab', (WidgetTester tester) async {
      for (var i = 0; i < _adminLabels.length; i++) {
        await bootAdmin(tester);
        await tester.tap(_adminNav(_adminLabels[i]));
        await tester.pumpAndSettle();

        // Halaman di dalam shell memakai `embedded: true` sehingga tidak
        // membuat navbar sendiri; jadi di layar hanya ada satu navbar.
        expect(
          find.byType(AdminBottomNavigation),
          findsOneWidget,
          reason: 'navbar tidak boleh ganda di ${_adminLabels[i]}',
        );
        expect(
          find.byType(AppNavBar),
          findsOneWidget,
          reason: 'navbar harus dari satu komponen yang sama',
        );
      }
    });

    testWidgets('TEST 6: navbar user juga satu komponen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.byType(OnboardingFirstPage));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), dummyEmail);
      await tester.enterText(find.byType(TextFormField).at(1), dummyPassword);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.byType(AppBottomNavigation), findsOneWidget);
      expect(find.byType(AppNavBar), findsOneWidget);
    });
  });

  group('TEST 7: menu aktif selalu sesuai halaman', () {
    testWidgets('TEST 7: hanya satu menu aktif, warnanya benar', (
      WidgetTester tester,
    ) async {
      const active = Color(0xFF0B75D1);
      const inactive = Color(0xFF8A949E);

      for (var activeIndex = 0;
          activeIndex < _adminLabels.length;
          activeIndex++) {
        await bootAdmin(tester);
        if (activeIndex != 0) {
          await tester.tap(_adminNav(_adminLabels[activeIndex]));
          await tester.pumpAndSettle();
        }

        for (var i = 0; i < _adminLabels.length; i++) {
          final style = tester
              .widget<Text>(
                find.descendant(
                  of: _adminNav(_adminLabels[i]),
                  matching: find.text(_adminLabels[i]),
                ),
              )
              .style!;
          expect(
            style.color,
            i == activeIndex ? active : inactive,
            reason: '${_adminLabels[i]} saat ${_adminLabels[activeIndex]} aktif',
          );
          expect(
            style.fontWeight,
            i == activeIndex ? FontWeight.w600 : FontWeight.w400,
            reason: 'ketebalan ${_adminLabels[i]}',
          );
        }
      }
    });
  });

  group('TEST 8: Profil dari halaman lain', () {
    testWidgets('TEST 8: dari Kendaraan dan Notifikasi ke Profil', (
      WidgetTester tester,
    ) async {
      for (final origin in const [1, 3, 2]) {
        await bootAdmin(tester);
        await tester.tap(_adminNav(_adminLabels[origin]));
        await tester.pumpAndSettle();
        _expectOnAdminTab(tester, origin);

        await tester.tap(_adminNav('Profil'));
        await tester.pumpAndSettle();
        _expectOnAdminTab(tester, AdminShellPage.indexProfil);
      }
    });

    testWidgets('TEST 8: dari halaman ter Dorongan (Daftar Peminjaman) ke Profil', (
      WidgetTester tester,
    ) async {
      // Daftar Peminjaman yang dibuka dari Beranda punya navbar sendiri.
      await bootAdmin(tester);
      final link = find.text('Lihat Semua');
      await tester.ensureVisible(link);
      await tester.pumpAndSettle();
      await tester.tap(link);
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoanListPage), findsOneWidget);

      await tester.tap(_adminNav('Profil'));
      await tester.pumpAndSettle();

      expect(find.byType(AdminProfilePage), findsOneWidget);
      _expectOnAdminTab(tester, AdminShellPage.indexProfil);
    });
  });

  group('Struktur navbar', () {
    testWidgets('navbar Admin punya 5 menu sesuai UI/UX', (
      WidgetTester tester,
    ) async {
      await bootAdmin(tester);

      for (final label in _adminLabels) {
        expect(
          find.text(label),
          findsOneWidget,
          reason: 'menu $label harus ada',
        );
      }
      expect(
        find.byType(AdminBottomNavigation),
        findsOneWidget,
      );
      expect(AdminBottomNavigation.items.length, 4);
      // Menu Peminjaman dihapus karena isinya sama dengan "Peminjaman
      // Terbaru" yang sudah punya link "Lihat Semua" di Beranda.
      expect(find.text('Peminjaman'), findsNothing);
    });

    testWidgets('navbar user tetap 4 menu (tidak ditambah menu baru)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.byType(OnboardingFirstPage));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), dummyEmail);
      await tester.enterText(find.byType(TextFormField).at(1), dummyPassword);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(AppTab.values.length, 4);
      for (final tab in AppTab.values) {
        expect(find.text(tab.label), findsOneWidget, reason: tab.label);
      }
      expect(find.text('Peminjaman'), findsNothing);
    });

    testWidgets('navbar user: semua menu membuka halaman yang benar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.byType(OnboardingFirstPage));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), dummyEmail);
      await tester.enterText(find.byType(TextFormField).at(1), dummyPassword);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      for (final tab in AppTab.values) {
        await tester.tap(_userNav(tab.name));
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<AppBottomNavigation>(find.byType(AppBottomNavigation))
              .selectedTab,
          tab,
          reason: 'harus di ${tab.label}',
        );
        // Hanya satu navbar, tidak menumpuk.
        expect(find.byType(AppNavBar), findsOneWidget);
        expect(find.byType(ErrorWidget), findsNothing);
      }
    });

    testWidgets('user dan admin memakai satu komponen yang sama', (
      WidgetTester tester,
    ) async {
      // Komponen yang sama, metrik identik.
      expect(AppNavBar.kNavHeight, 62);
      expect(AppNavBar.kIconSize, 21);
      expect(AppNavBar.kLabelSize, 8);

      // Tampilan per-area dipertahankan lewat style.
      await bootAdmin(tester);
      final adminBox = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(AppNavBar),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(
        (adminBox.decoration! as BoxDecoration).boxShadow,
        isNotEmpty,
        reason: 'navbar Admin tetap kartu melayang',
      );
    });
  });

  group('Responsive & error', () {
    testWidgets('navbar konsisten dan tanpa overflow di berbagai ukuran', (
      WidgetTester tester,
    ) async {
      for (final size in const [
        Size(320, 480),
        Size(360, 640),
        Size(393, 852),
        Size(412, 915),
      ]) {
        await tester.binding.setSurfaceSize(size);
        await bootAdmin(tester);

        for (final label in _adminLabels) {
          await tester.tap(_adminNav(label));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '$label di $size');
        }

        // Navbar selalu di bagian bawah; tinggi barisnya tetap sama di semua
        // halaman dan ukuran layar.
        final box = tester.getRect(find.byType(AppNavBar));
        expect(box.bottom, closeTo(size.height, 0.5));
        final rowBox = tester.getRect(
          find
              .descendant(
                of: find.byType(AppNavBar),
                matching: find.byType(SizedBox),
              )
              .first,
        );
        expect(rowBox.height, AppNavBar.kNavHeight);

        // Label di dalam navbar tidak boleh keluar layar.
        for (final label in _adminLabels) {
          expect(
            tester.getRect(find.text(label).last).right,
            lessThanOrEqualTo(size.width),
            reason: '$label tidak boleh keluar layar di $size',
          );
        }
      }
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('seluruh baris navbar dapat diketuk di coordinate nyata', (
      WidgetTester tester,
    ) async {
      const size = Size(393, 852);
      tester.view.physicalSize = size * 3;
      tester.view.devicePixelRatio = 3;
      tester.view.padding = const FakeViewPadding(top: 72, bottom: 144);
      addTearDown(tester.view.reset);

      await bootAdmin(tester);

      for (var i = 0; i < _adminLabels.length; i++) {
        final box = tester.renderObject<RenderBox>(find.byType(AppNavBar));
        final origin = box.localToGlobal(Offset.zero);
        final cell = box.size.width / _adminLabels.length;
        await tester.tapAt(
          Offset(origin.dx + cell * (i + 0.5), origin.dy + box.size.height / 2),
        );
        await tester.pumpAndSettle();
        expect(_adminIndex(tester), i, reason: 'harus di ${_adminLabels[i]}');
      }
    });
  });
}

/// Memastikan tab yang tampil benar-benar tab tersebut, tanpa error.
void _expectOnAdminTab(WidgetTester tester, int index) {
  expect(_adminIndex(tester), index, reason: 'harus di ${_adminLabels[index]}');
  expect(
    find.byType(_adminPages[index]!, skipOffstage: true),
    findsOneWidget,
    reason: 'halaman ${_adminLabels[index]} harus terlihat',
  );
  expect(find.byType(ErrorWidget), findsNothing);
  expect(find.byType(AdminBottomNavigation), findsOneWidget);
}