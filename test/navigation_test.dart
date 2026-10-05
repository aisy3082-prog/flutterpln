import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_plnmobile/main.dart';
import 'package:flutter_application_plnmobile/pages/app_shell_page.dart';
import 'package:flutter_application_plnmobile/pages/home_page.dart';
import 'package:flutter_application_plnmobile/pages/login_page.dart';
import 'package:flutter_application_plnmobile/pages/notification_page.dart';
import 'package:flutter_application_plnmobile/pages/profile_page.dart';
import 'package:flutter_application_plnmobile/pages/queue_page.dart';
import 'package:flutter_application_plnmobile/pages/vehicle_list_page.dart';
import 'package:flutter_application_plnmobile/utils/app_navigation.dart';
import 'package:flutter_application_plnmobile/widgets/app_bottom_navigation.dart';

/// Index tetap sesuai permintaan.
const _indexBeranda = 0;
const _indexKendaraan = 1;
const _indexNotifikasi = 2;
const _indexProfil = 3;

Finder _tab(AppTab tab) => find.byKey(ValueKey('app_bottom_nav_${tab.name}'));

const _pagesByTab = <AppTab, Type>{
  AppTab.beranda: HomePage,
  AppTab.kendaraan: VehicleListPage,
  AppTab.notifikasi: NotificationPage,
  AppTab.profil: ProfilePage,
};

/// Alur nyata: onboarding -> login -> shell di Beranda.
Future<void> _login(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(const MyApp());
  await tester.tap(find.byType(OnboardingFirstPage));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();

  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), dummyEmail);
  await tester.enterText(fields.at(1), dummyPassword);
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();

  expect(find.byType(AppShellPage), findsOneWidget);
}

int _selectedIndex(WidgetTester tester) => AppTab.values.indexOf(
  tester
      .widget<AppBottomNavigation>(find.byType(AppBottomNavigation))
      .selectedTab,
);

void _expectOnTab(WidgetTester tester, AppTab tab) {
  expect(
    _selectedIndex(tester),
    AppTab.values.indexOf(tab),
    reason: 'Harus aktif di ${tab.label}',
  );
  expect(
    find.byType(_pagesByTab[tab]!, skipOffstage: true),
    findsOneWidget,
    reason: 'Halaman ${tab.label} harus terlihat',
  );
  expect(find.byType(AppBottomNavigation), findsOneWidget);
  expect(tester.takeException(), isNull);
}

void main() {
  group('Indeks tab tetap', () {
    test(
      'urutan AppTab sesuai 0=Beranda 1=Kendaraan 2=Notifikasi 3=Profil',
      () {
        expect(AppTab.values.indexOf(AppTab.beranda), _indexBeranda);
        expect(AppTab.values.indexOf(AppTab.kendaraan), _indexKendaraan);
        expect(AppTab.values.indexOf(AppTab.notifikasi), _indexNotifikasi);
        expect(AppTab.values.indexOf(AppTab.profil), _indexProfil);
        expect(AppTab.values.length, 4);
      },
    );
  });

  group('Klik dari Beranda', () {
    testWidgets('klik Kendaraan membuka Kendaraan', (
      WidgetTester tester,
    ) async {
      await _login(tester);
      _expectOnTab(tester, AppTab.beranda);

      await tester.tap(_tab(AppTab.kendaraan));
      await tester.pumpAndSettle();

      _expectOnTab(tester, AppTab.kendaraan);
    });

    testWidgets('klik Notifikasi membuka Notifikasi', (
      WidgetTester tester,
    ) async {
      await _login(tester);

      await tester.tap(_tab(AppTab.notifikasi));
      await tester.pumpAndSettle();

      _expectOnTab(tester, AppTab.notifikasi);
    });

    testWidgets('klik Profil membuka Profil', (WidgetTester tester) async {
      await _login(tester);

      await tester.tap(_tab(AppTab.profil));
      await tester.pumpAndSettle();

      _expectOnTab(tester, AppTab.profil);
      expect(find.text('Andi Pratama'), findsWidgets);
    });
  });

  group('Klik dari Notifikasi', () {
    testWidgets('klik Beranda benar-benar membuka Beranda', (
      WidgetTester tester,
    ) async {
      // Ini kasus yang dulu salah: dari Notifikasi, klik Beranda kembali lagi
      // ke Notifikasi.
      await _login(tester);
      await tester.tap(_tab(AppTab.notifikasi));
      await tester.pumpAndSettle();
      _expectOnTab(tester, AppTab.notifikasi);

      await tester.tap(_tab(AppTab.beranda));
      await tester.pumpAndSettle();

      _expectOnTab(tester, AppTab.beranda);
      expect(find.text('Ringkasan Kendaraan'), findsOneWidget);
      expect(find.byType(AppShellPage), findsOneWidget);
    });

    testWidgets('klik Kendaraan dan Profil juga benar', (
      WidgetTester tester,
    ) async {
      await _login(tester);
      await tester.tap(_tab(AppTab.notifikasi));
      await tester.pumpAndSettle();

      await tester.tap(_tab(AppTab.kendaraan));
      await tester.pumpAndSettle();
      _expectOnTab(tester, AppTab.kendaraan);

      await tester.tap(_tab(AppTab.profil));
      await tester.pumpAndSettle();
      _expectOnTab(tester, AppTab.profil);
    });
  });

  group('Matriks penuh 4x4', () {
    testWidgets('semua kombinasi asal -> tujuan benar', (
      WidgetTester tester,
    ) async {
      for (final origin in _pagesByTab.entries) {
        for (final target in _pagesByTab.entries) {
          await _login(tester);

          // Pindah ke halaman asal.
          if (origin.key != AppTab.beranda) {
            await tester.tap(_tab(origin.key));
            await tester.pumpAndSettle();
            _expectOnTab(tester, origin.key);
          }

          // Pindah ke halaman tujuan.
          await tester.tap(_tab(target.key));
          await tester.pumpAndSettle();

          _expectOnTab(tester, target.key);
          expect(
            find.byType(OnboardingFirstPage),
            findsNothing,
            reason:
                '${origin.key.label} -> ${target.key.label} tidak boleh '
                'kembali ke onboarding',
          );
        }
      }
    });
  });

  group('Perjalanan bolak-balik wajib benar', () {
    testWidgets('Beranda -> Kendaraan -> Beranda', (WidgetTester tester) async {
      await _login(tester);
      await tester.tap(_tab(AppTab.kendaraan));
      await tester.pumpAndSettle();
      await tester.tap(_tab(AppTab.beranda));
      await tester.pumpAndSettle();

      _expectOnTab(tester, AppTab.beranda);
    });

    testWidgets('Beranda -> Notifikasi -> Beranda', (
      WidgetTester tester,
    ) async {
      await _login(tester);
      await tester.tap(_tab(AppTab.notifikasi));
      await tester.pumpAndSettle();
      await tester.tap(_tab(AppTab.beranda));
      await tester.pumpAndSettle();

      _expectOnTab(tester, AppTab.beranda);
    });

    testWidgets('Beranda -> Profil -> Beranda', (WidgetTester tester) async {
      await _login(tester);
      await tester.tap(_tab(AppTab.profil));
      await tester.pumpAndSettle();
      await tester.tap(_tab(AppTab.beranda));
      await tester.pumpAndSettle();

      _expectOnTab(tester, AppTab.beranda);
    });

    testWidgets('Kendaraan -> Notifikasi -> Beranda', (
      WidgetTester tester,
    ) async {
      await _login(tester);
      await tester.tap(_tab(AppTab.kendaraan));
      await tester.pumpAndSettle();
      await tester.tap(_tab(AppTab.notifikasi));
      await tester.pumpAndSettle();
      await tester.tap(_tab(AppTab.beranda));
      await tester.pumpAndSettle();

      _expectOnTab(tester, AppTab.beranda);
    });

    testWidgets('Notifikasi -> Kendaraan -> Beranda', (
      WidgetTester tester,
    ) async {
      await _login(tester);
      await tester.tap(_tab(AppTab.notifikasi));
      await tester.pumpAndSettle();
      await tester.tap(_tab(AppTab.kendaraan));
      await tester.pumpAndSettle();
      await tester.tap(_tab(AppTab.beranda));
      await tester.pumpAndSettle();

      _expectOnTab(tester, AppTab.beranda);
    });

    testWidgets('Profil -> Kendaraan -> Notifikasi -> Beranda', (
      WidgetTester tester,
    ) async {
      await _login(tester);
      await tester.tap(_tab(AppTab.profil));
      await tester.pumpAndSettle();
      await tester.tap(_tab(AppTab.kendaraan));
      await tester.pumpAndSettle();
      await tester.tap(_tab(AppTab.notifikasi));
      await tester.pumpAndSettle();
      await tester.tap(_tab(AppTab.beranda));
      await tester.pumpAndSettle();

      _expectOnTab(tester, AppTab.beranda);
    });

    testWidgets('berpindah banyak kali tanpa nyangkut', (
      WidgetTester tester,
    ) async {
      await _login(tester);
      for (final tab in [
        AppTab.kendaraan,
        AppTab.profil,
        AppTab.notifikasi,
        AppTab.beranda,
        AppTab.notifikasi,
        AppTab.kendaraan,
        AppTab.beranda,
      ]) {
        await tester.tap(_tab(tab));
        await tester.pumpAndSettle();
        _expectOnTab(tester, tab);
      }
    });
  });

  group('Halaman turunan', () {
    testWidgets('dari Antrean Saya, klik tab membuka tab yang benar', (
      WidgetTester tester,
    ) async {
      await _login(tester);

      // Antrean Saya dibuka dari baris aktivitas di Beranda.
      await tester.tap(find.text('Mobil - Avanza'));
      await tester.pumpAndSettle();
      expect(find.byType(QueuePage), findsOneWidget);
      expect(find.byType(AppBottomNavigation), findsOneWidget);

      await tester.tap(_tab(AppTab.kendaraan));
      await tester.pumpAndSettle();

      expect(find.byType(QueuePage), findsNothing);
      _expectOnTab(tester, AppTab.kendaraan);
    });

    testWidgets('halaman utama tidak lagi punya navbar sendiri', (
      WidgetTester tester,
    ) async {
      await _login(tester);

      // Di dalam shell hanya boleh ada SATU navbar.
      expect(find.byType(AppBottomNavigation), findsOneWidget);
      expect(find.byType(AppShellPage), findsOneWidget);

      for (final tab in AppTab.values) {
        await tester.tap(_tab(tab));
        await tester.pumpAndSettle();
        expect(
          find.byType(AppBottomNavigation),
          findsOneWidget,
          reason: 'Tidak boleh ada navbar ganda di ${tab.label}',
        );
      }
    });
  });

  group('Logout', () {
    testWidgets('Profil -> Keluar kembali ke Login', (
      WidgetTester tester,
    ) async {
      await _login(tester);
      await tester.tap(_tab(AppTab.profil));
      await tester.pumpAndSettle();

      final signOut = find.widgetWithText(ElevatedButton, 'Keluar');
      await tester.ensureVisible(signOut);
      await tester.pumpAndSettle();
      await tester.tap(signOut);
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(AppShellPage), findsNothing);
    });
  });

  group('Area tap navbar', () {
    testWidgets('seluruh baris navbar menerima tap di perangkat nyata', (
      WidgetTester tester,
    ) async {
      const size = Size(393, 852);
      tester.view.physicalSize = size * 3;
      tester.view.devicePixelRatio = 3;
      tester.view.padding = const FakeViewPadding(top: 24 * 3, bottom: 48 * 3);
      addTearDown(tester.view.reset);

      await _login(tester);

      final navBox = tester.renderObject<RenderBox>(
        find.byType(AppBottomNavigation),
      );
      final top = navBox.localToGlobal(Offset.zero);
      final cellWidth = navBox.size.width / AppTab.values.length;

      var blocked = <String>[];
      for (var i = 0; i < AppTab.values.length; i++) {
        final x = top.dx + cellWidth * (i + 0.5);
        for (var y = top.dy + 2; y <= top.dy + 60; y += 4) {
          final result = HitTestResult();
          WidgetsBinding.instance.hitTestInView(
            result,
            Offset(x, y),
            tester.view.viewId,
          );
          final hasTarget = result.path.any(
            (entry) =>
                entry.target is RenderPointerListener ||
                entry.target is RenderSemanticsGestureHandler ||
                entry.target.runtimeType.toString().contains('InkFeatures'),
          );
          if (!hasTarget) {
            blocked.add('${AppTab.values[i].name}@${y.toStringAsFixed(0)}');
          }
        }
      }

      expect(
        blocked,
        isEmpty,
        reason: 'Titik navbar yang tidak menerima tap: $blocked',
      );
    });

    testWidgets('ketuk koordinat nyata untuk tiap tombol', (
      WidgetTester tester,
    ) async {
      const size = Size(393, 852);
      tester.view.physicalSize = size * 3;
      tester.view.devicePixelRatio = 3;
      tester.view.padding = const FakeViewPadding(top: 24 * 3, bottom: 48 * 3);
      addTearDown(tester.view.reset);

      await _login(tester);

      for (final tab in AppTab.values) {
        final navBox = tester.renderObject<RenderBox>(
          find.byType(AppBottomNavigation),
        );
        final top = navBox.localToGlobal(Offset.zero);
        final cellWidth = navBox.size.width / AppTab.values.length;
        final index = AppTab.values.indexOf(tab);

        await tester.tapAt(
          Offset(top.dx + cellWidth * (index + 0.5), top.dy + 31),
        );
        await tester.pumpAndSettle();

        _expectOnTab(tester, tab);
      }
    });
  });

  testWidgets('shell responsif di berbagai ukuran Android', (
    WidgetTester tester,
  ) async {
    for (final size in const [Size(320, 480), Size(360, 640), Size(393, 852)]) {
      await tester.binding.setSurfaceSize(size);
      await _login(tester);

      for (final tab in AppTab.values) {
        await tester.tap(_tab(tab));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${tab.label} should fit at $size',
        );
      }
    }
    await tester.binding.setSurfaceSize(null);
  });
}
