import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_plnmobile/data/admin_dashboard_data.dart';
import 'package:flutter_application_plnmobile/main.dart';
import 'package:flutter_application_plnmobile/pages/login_page.dart';
import 'package:flutter_application_plnmobile/data/admin_vehicle_data.dart';
import 'package:flutter_application_plnmobile/models/admin_dashboard.dart';
import 'package:flutter_application_plnmobile/models/admin_profile.dart';
import 'package:flutter_application_plnmobile/models/vehicle.dart';
import 'package:flutter_application_plnmobile/state/admin_auth_state.dart';
import 'package:flutter_application_plnmobile/state/auth_state.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_home_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_login_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_loan_list_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_navigation.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_notification_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_profile_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_vehicle_page.dart';
import 'package:flutter_application_plnmobile/state/admin_loan_state.dart';
import 'package:flutter_application_plnmobile/state/admin_notification_state.dart';
import 'package:flutter_application_plnmobile/state/admin_vehicle_state.dart';
import 'package:flutter_application_plnmobile/widgets/admin_bottom_navigation.dart';

Finder _nav(String label) =>
    find.byKey(ValueKey('admin_bottom_nav_$label'));

/// Membungkus widget dengan scope yang dipakai area Admin.
Widget _adminHost(Widget child, {AdminAuthState? auth, AdminLoanState? loans}) {
  return AdminNotificationStateScope(
    state: AdminNotificationState(),
    child: AdminVehicleStateScope(
    state: AdminVehicleState(vehicles: dummyAdminVehicles),
    child: AdminLoanStateScope(
      state: loans ?? AdminLoanState(),
      child: AdminAuthStateScope(
        state: auth ?? AdminAuthState(),
        child: MaterialApp(home: child),
      ),
    ),
  ),
  );
}

Future<void> _boot(WidgetTester tester) async {
  // Di-reset dulu supaya state shell tidak terbawa dari iterasi sebelumnya.
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(_adminHost(const AdminShellPage()));
  await tester.pumpAndSettle();
}

/// Shell Admin dengan session login, seperti kondisi setelah login berhasil.
Future<void> _bootSignedIn(
  WidgetTester tester,
  AdminAuthState state,
) async {
  await tester.pumpWidget(const SizedBox.shrink());
  state.signIn();
  await tester.pumpWidget(
    _adminHost(const AdminShellPage(), auth: state),
  );
  await tester.pumpAndSettle();
}

int _selected(WidgetTester tester) => tester
    .widget<AdminBottomNavigation>(find.byType(AdminBottomNavigation))
    .selectedIndex;

void main() {
  late AdminAuthState adminAuth;

  setUp(() {
    adminAuth = AdminAuthState();
  });

  group('Beranda Admin', () {
    testWidgets('menampilkan header, sapaan, dan statistik', (
      WidgetTester tester,
    ) async {
      await _boot(tester);

      // "Admin" muncul di judul header dan di sebelah avatar.
      expect(find.text('Admin'), findsNWidgets(2));
      expect(find.text('Halo, Admin'), findsOneWidget);
      expect(find.text('Kelola semua peminjaman kendaraan di sini'), findsOneWidget);

      // Keempat kartu statistik beserta angkanya.
      expect(find.text('Peminjaman Mobil'), findsOneWidget);
      expect(find.text('Peminjaman Motor'), findsOneWidget);
      expect(find.text('Menunggu Driver'), findsOneWidget);
      expect(find.text('Disetujui Hari Ini'), findsOneWidget);
      // Angka kartu statistik dicari hanya di dalam Beranda, supaya tidak
      // bentrok dengan angka pada badge notifikasi di navbar.
      final home = find.byType(AdminHomePage);
      Finder stat(String text) =>
          find.descendant(of: home, matching: find.text(text));
      expect(stat('5'), findsOneWidget);
      expect(stat('3'), findsOneWidget);
      expect(stat('2'), findsOneWidget);
      expect(stat('6'), findsOneWidget);
    });

    testWidgets('menampilkan Peminjaman Terbaru dan Lihat Semua', (
      WidgetTester tester,
    ) async {
      await _boot(tester);

      expect(find.text('Peminjaman Terbaru'), findsOneWidget);
      expect(find.text('Lihat Semua'), findsOneWidget);

      expect(find.text('Mobil - Avanza'), findsOneWidget);
      expect(find.text('12 Sep 2026, 08:15'), findsOneWidget);
      expect(find.text('Motor - Honda Beat'), findsOneWidget);
      expect(find.text('Mobil - Toyota Inova'), findsOneWidget);
      expect(find.text('11 Sep 2026, 09:20'), findsOneWidget);
      expect(find.text('Menunggu'), findsNWidgets(2));
      expect(find.text('Disetujui'), findsOneWidget);
    });

    testWidgets('Lihat Semua membuka Daftar Peminjaman Terbaru', (
      WidgetTester tester,
    ) async {
      await _boot(tester);
      await tester.tap(find.text('Lihat Semua'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AdminLoanListPage), findsOneWidget);
      expect(find.text('Daftar Peminjaman Terbaru'), findsOneWidget);
    });

    testWidgets('ikon notifikasi dan avatar membuka tab yang benar', (
      WidgetTester tester,
    ) async {
      await _boot(tester);

      await tester.tap(find.byTooltip('Notifikasi'));
      await tester.pumpAndSettle();
      expect(_selected(tester), AdminShellPage.indexNotifikasi);

      await tester.tap(_nav('Beranda'));
      await tester.pumpAndSettle();
      // Avatar kecil di header leading ke Profil.
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      expect(_selected(tester), AdminShellPage.indexProfil);
    });
  });

  group('Profil Admin', () {
    testWidgets('header biru, avatar, dan data diri', (
      WidgetTester tester,
    ) async {
      await _boot(tester);
      await tester.tap(_nav('Profil'));
      await tester.pumpAndSettle();

      expect(find.byType(AdminProfilePage), findsOneWidget);
      // "Profil" muncul dua kali: judul header dan label navbar.
      expect(find.text('Profil'), findsNWidgets(2));
      expect(find.text('Administrator'), findsWidgets);
      expect(find.text('Data Diri'), findsOneWidget);
      expect(find.text('Akses'), findsOneWidget);
      expect(find.text('Nomor HP'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('0881 2345 6789'), findsOneWidget);
      expect(find.text('admin@pln.co.id'), findsOneWidget);
    });

    testWidgets('menu Pengaturan, Bantuan, Tentang Aplikasi, dan Keluar', (
      WidgetTester tester,
    ) async {
      await _boot(tester);
      await tester.tap(_nav('Profil'));
      await tester.pumpAndSettle();

      expect(find.text('Pengaturan'), findsOneWidget);
      expect(find.text('Bantuan'), findsOneWidget);
      expect(find.text('Tentang Aplikasi'), findsOneWidget);
      expect(find.text('Keluar'), findsOneWidget);
    });

    testWidgets('tombol Keluar menghapus session dan kembali ke Login Admin', (
      WidgetTester tester,
    ) async {
      await _bootSignedIn(tester, adminAuth);

      await tester.tap(_nav('Profil'));
      await tester.pumpAndSettle();

      final signOut = find.widgetWithText(ElevatedButton, 'Keluar');
      await tester.ensureVisible(signOut);
      await tester.pumpAndSettle();
      await tester.tap(signOut);
      await tester.pumpAndSettle();

      expect(adminAuth.isSignedIn, isFalse, reason: 'session harus dihapus');
      expect(adminAuth.profile, isNull);
      expect(find.byType(AdminLoginPage), findsOneWidget);
      expect(find.byType(AdminShellPage), findsNothing);
    });

    testWidgets('avatar memakai asset yang tersedia', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: AdminProfilePage()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Bottom Navigation Admin', () {
    testWidgets('hanya ada satu navbar', (WidgetTester tester) async {
      await _boot(tester);
      expect(find.byType(AdminBottomNavigation), findsOneWidget);
      expect(find.byType(AdminShellPage), findsOneWidget);
    });

    testWidgets('matriks penuh 4x4', (WidgetTester tester) async {
      const pages = <int, Type>{
        AdminShellPage.indexBeranda: AdminHomePage,
        AdminShellPage.indexKendaraan: AdminVehiclePage,
        AdminShellPage.indexNotifikasi: AdminNotificationPage,
        AdminShellPage.indexProfil: AdminProfilePage,
      };
      const labels = [
        'Beranda',
        'Kendaraan',
        'Notifikasi',
        'Profil',
      ];

      for (final origin in pages.keys) {
        for (final target in pages.keys) {
          await _boot(tester);
          if (origin != 0) {
            await tester.tap(_nav(labels[origin]));
            await tester.pumpAndSettle();
          }
          expect(_selected(tester), origin);

          await tester.tap(_nav(labels[target]));
          await tester.pumpAndSettle();

          expect(
            _selected(tester),
            target,
            reason: '$origin -> $target harus aktif',
          );
          expect(
            find.byType(pages[target]!, skipOffstage: true),
            findsOneWidget,
            reason: '$origin -> $target harus menampilkan halaman yang tepat',
          );
        }
      }
    });

    testWidgets('warna label aktif dan nonaktif benar', (
      WidgetTester tester,
    ) async {
      const active = Color(0xFF0B75D1);
      const inactive = Color(0xFF8A949E);

      await _boot(tester);
      for (final (index, label) in const [
        (0, 'Beranda'),
        (1, 'Kendaraan'),
        (2, 'Notifikasi'),
        (3, 'Profil'),
      ]) {
        if (index != 0) {
          await tester.tap(_nav(label));
          await tester.pumpAndSettle();
        }
        for (final candidate in const [
          'Beranda',
          'Kendaraan',
          'Notifikasi',
          'Profil',
        ]) {
          final style = tester
              .widget<Text>(
                find.descendant(
                  of: _nav(candidate),
                  matching: find.text(candidate),
                ),
              )
              .style!;
          expect(
            style.color,
            candidate == label ? active : inactive,
            reason: '$candidate saat tab $label aktif',
          );
        }
      }
    });

    testWidgets('seluruh baris navbar bisa diketuk di koordinat nyata', (
      WidgetTester tester,
    ) async {
      const size = Size(393, 852);
      tester.view.physicalSize = size * 3;
      tester.view.devicePixelRatio = 3;
      tester.view.padding = const FakeViewPadding(top: 72, bottom: 144);
      addTearDown(tester.view.reset);

      await _boot(tester);

      const labels = [
        'Beranda',
        'Kendaraan',
        'Notifikasi',
        'Profil',
      ];
      for (var i = 0; i < labels.length; i++) {
        final box = tester.renderObject<RenderBox>(
          find.byType(AdminBottomNavigation),
        );
        final origin = box.localToGlobal(Offset.zero);
        final cell = box.size.width / labels.length;
        await tester.tapAt(
          Offset(origin.dx + cell * (i + 0.5), origin.dy + box.size.height / 2),
        );
        await tester.pumpAndSettle();
        expect(_selected(tester), i);
      }
    });
  });

  group('Login Admin', () {
    testWidgets('kredensial benar membuka Beranda Admin', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _adminHost(const AdminLoginPage(), auth: adminAuth),
      );
      await tester.pumpAndSettle();

      expect(find.text('Login Admin'), findsOneWidget);
      expect(find.byType(AdminLoginPage), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), dummyAdminEmail);
      await tester.enterText(
        find.byType(TextFormField).at(1),
        dummyAdminPassword,
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      // Tunggu proses login + animasi route selesai.
      await tester.pumpAndSettle(const Duration(milliseconds: 400));

      expect(adminAuth.isSignedIn, isTrue);
      expect(find.byType(AdminShellPage), findsOneWidget);
      expect(find.byType(AdminLoginPage), findsNothing);
      expect(find.text('Halo, Admin'), findsOneWidget);
    });

    testWidgets('kredensial salah ditolak dan tetap di halaman login', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _adminHost(const AdminLoginPage(), auth: adminAuth),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        dummyAdminEmail,
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'salah');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle(const Duration(milliseconds: 400));

      expect(adminAuth.isSignedIn, isFalse);
      expect(find.byType(AdminLoginPage), findsOneWidget);
      expect(find.text('Email atau password Admin salah.'), findsOneWidget);
    });

    testWidgets('email kosong dan format salah divalidasi', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _adminHost(const AdminLoginPage(), auth: adminAuth),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      expect(find.text('Email wajib diisi'), findsOneWidget);
      expect(find.text('Password wajib diisi'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'bukan-email');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      expect(find.text('Format email tidak valid'), findsOneWidget);
      expect(adminAuth.isSignedIn, isFalse);
    });

    testWidgets('session terpisah dari session user', (
      WidgetTester tester,
    ) async {
      final userAuth = AuthState();
      await tester.pumpWidget(
        AdminNotificationStateScope(
          state: AdminNotificationState(),
          child: AdminVehicleStateScope(
            state: AdminVehicleState(vehicles: dummyAdminVehicles),
            child: AdminLoanStateScope(
              state: AdminLoanState(),
              child: AdminAuthStateScope(
                state: adminAuth,
                child: AuthStateScope(
                  state: userAuth,
                  child: const MaterialApp(home: AdminLoginPage()),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), dummyAdminEmail);
      await tester.enterText(
        find.byType(TextFormField).at(1),
        dummyAdminPassword,
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle(const Duration(milliseconds: 400));

      expect(adminAuth.isSignedIn, isTrue);
      expect(userAuth.isSignedIn, isFalse, reason: 'user tidak ikut login');
      expect(userAuth.user, isNull);
    });

    testWidgets('Profil Admin memakai data dari session', (
      WidgetTester tester,
    ) async {
      const custom = AdminProfile(
        name: 'Operator',
        role: 'Administrator',
        phone: '0899 1111 2222',
        email: 'operator@pln.co.id',
      );
      final state = AdminAuthState();
      await tester.pumpWidget(const SizedBox.shrink());
      state.signIn(profile: custom);
      await tester.pumpWidget(
        _adminHost(const AdminShellPage(), auth: state),
      );
      await tester.pumpAndSettle();

      await tester.tap(_nav('Profil'));
      await tester.pumpAndSettle();

      expect(find.text('Operator'), findsWidgets);
      expect(find.text('0899 1111 2222'), findsOneWidget);
      expect(find.text('operator@pln.co.id'), findsOneWidget);
    });
  });

  group('Integrasi dari login user', () {
    testWidgets('tombol "Masuk sebagai Admin" membuka Login Admin', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.byType(OnboardingFirstPage));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Login user terbuka normal, tanpa perubahan tampilan.
      expect(find.byType(LoginPage), findsOneWidget);

      final entry = find.text('Masuk sebagai Admin');
      await tester.ensureVisible(entry);
      await tester.pumpAndSettle();
      await tester.tap(entry);
      await tester.pumpAndSettle();

      expect(find.byType(AdminLoginPage), findsOneWidget);
      expect(find.text('Login Admin'), findsOneWidget);
    });

    testWidgets('alur penuh: user -> Login Admin -> Beranda Admin', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.byType(OnboardingFirstPage));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      final entry = find.text('Masuk sebagai Admin');
      await tester.ensureVisible(entry);
      await tester.pumpAndSettle();
      await tester.tap(entry);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), dummyAdminEmail);
      await tester.enterText(
        find.byType(TextFormField).at(1),
        dummyAdminPassword,
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle(const Duration(milliseconds: 400));

      expect(find.byType(AdminShellPage), findsOneWidget);
      expect(find.text('Halo, Admin'), findsOneWidget);

      // Navigasi Admin tetap berfungsi setelah login.
      await tester.tap(_nav('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('Administrator'), findsWidgets);

      await tester.tap(_nav('Beranda'));
      await tester.pumpAndSettle();
      expect(find.text('Peminjaman Terbaru'), findsOneWidget);
    });
  });

  group('Data dummy Admin', () {
    test('sesuai permintaan', () {
      expect(dummyAdminProfile.name, 'Admin');
      expect(dummyAdminProfile.role, 'Administrator');
      expect(dummyAdminProfile.email, 'admin@pln.co.id');
      expect(dummyAdminProfile.phone, '0881 2345 6789');

      expect(dummyAdminStats.length, 4);
      expect(dummyAdminLoans.length, 3);
      expect(
        dummyAdminLoans.first.status,
        AdminLoanStatus.menunggu,
      );
      expect(
        dummyAdminLoans.first.vehicleType,
        VehicleType.mobil,
      );
    });
  });

  group('Responsif', () {
    testWidgets('tidak ada overflow di berbagai ukuran Android', (
      WidgetTester tester,
    ) async {
      for (final size in const [
        Size(320, 480),
        Size(360, 640),
        Size(393, 852),
        Size(412, 915),
      ]) {
        await tester.binding.setSurfaceSize(size);
        await _boot(tester);
        for (final label in const [
          'Beranda',
          'Kendaraan',
          'Notifikasi',
          'Profil',
        ]) {
          await tester.tap(_nav(label));
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '$label harus muat di $size',
          );
        }
      }
      await tester.binding.setSurfaceSize(null);
    });
  });
}