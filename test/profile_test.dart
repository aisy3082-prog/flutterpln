import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_plnmobile/main.dart';
import 'package:flutter_application_plnmobile/models/user_profile.dart';
import 'package:flutter_application_plnmobile/pages/about_page.dart';
import 'package:flutter_application_plnmobile/pages/app_shell_page.dart';
import 'package:flutter_application_plnmobile/pages/help_page.dart';
import 'package:flutter_application_plnmobile/pages/home_page.dart';
import 'package:flutter_application_plnmobile/pages/login_page.dart';
import 'package:flutter_application_plnmobile/pages/notification_page.dart';
import 'package:flutter_application_plnmobile/pages/personal_data_page.dart';
import 'package:flutter_application_plnmobile/pages/profile_page.dart';
import 'package:flutter_application_plnmobile/pages/settings_page.dart';
import 'package:flutter_application_plnmobile/pages/vehicle_list_page.dart';
import 'package:flutter_application_plnmobile/state/auth_state.dart';
import 'package:flutter_application_plnmobile/state/loan_state.dart';
import 'package:flutter_application_plnmobile/state/notification_state.dart';
import 'package:flutter_application_plnmobile/widgets/profile_group_row.dart';
import 'package:flutter_application_plnmobile/widgets/profile_menu_row.dart';

Widget _host(Widget child, {AuthState? auth}) {
  // Tanda kurung wajib: tanpa itu cascade `..signIn()` akan menempel ke
  // seluruh ekspresi `auth ?? AuthState()` dan selalu memanggil signIn().
  final authState = auth ?? (AuthState()..signIn());
  return AuthStateScope(
    state: authState,
    child: LoanStateScope(
      state: LoanState(),
      child: NotificationStateScope(
        state: NotificationState(),
        child: MaterialApp(home: child),
      ),
    ),
  );
}

/// Scroll ke item sebelum ditekan supaya tidak tertutup bottom navigation.
Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  group('Halaman Profil', () {
    testWidgets('menggunakan grouped list seperti halaman Profil Admin', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const ProfilePage()));
      await tester.pumpAndSettle();

      // Dua kartu: kartu data diri (4 baris) dan kartu menu (3 baris).
      expect(find.byType(ProfileGroupCard), findsNWidgets(2));
      expect(find.byType(ProfileGroupRow), findsNWidgets(7));

      // Baris dipisah garis tipis, bukan kotak sendiri-sendiri.
      expect(find.byType(Divider), findsNWidgets(5));

      // Widget lama tidak lagi dipakai di halaman ini.
      expect(find.byType(ProfileMenuCard), findsNothing);
      expect(find.byType(ProfileMenuRow), findsNothing);
    });

    testWidgets('label dan nilai tidak tumpang tindih', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const ProfilePage()));
      await tester.pumpAndSettle();

      Finder row(String label) => find.widgetWithText(ProfileGroupRow, label);

      // Lebar label tetap sehingga kolom nilai selalu rata kanan.
      expect(tester.getRect(row('Nomor HP')).left, tester.getRect(row('Email')).left);
      expect(
        tester.getRect(row('Nomor HP')).width,
        tester.getRect(row('Email')).width,
      );
    });

    testWidgets('hanya Data Diri yang bisa diketuk', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const ProfilePage()));
      await tester.pumpAndSettle();

      Finder row(String label) => find.widgetWithText(ProfileGroupRow, label);

      // Hanya Data Diri yang punya onTap.
      final dataDiri = tester.widget<ProfileGroupRow>(row('Data Diri'));
      expect(dataDiri.onTap, isNotNull);

      for (final label in ['Unit Kerja', 'Nomor HP', 'Email']) {
        final widget = tester.widget<ProfileGroupRow>(row(label));
        expect(widget.onTap, isNull, reason: '$label hanya keterangan');

        // Tidak ada chevron di baris yang tidak bisa diklik.
        expect(
          find.descendant(
            of: row(label),
            matching: find.byIcon(Icons.chevron_right_rounded),
          ),
          findsNothing,
          reason: '$label tidak boleh menampilkan chevron',
        );
      }

      // Data Diri tetap punya chevron.
      expect(
        find.descendant(
          of: row('Data Diri'),
          matching: find.byIcon(Icons.chevron_right_rounded),
        ),
        findsOne,
      );
    });

    testWidgets('menyetel Unit Kerja, Nomor HP, Email tidak navigasi', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const ProfilePage()));
      await tester.pumpAndSettle();

      for (final label in ['Unit Kerja', 'Nomor HP', 'Email']) {
        await tester.tap(
          find.widgetWithText(ProfileGroupRow, label),
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();

        expect(find.byType(PersonalDataPage), findsNothing, reason: label);
        expect(find.byType(ProfilePage), findsOneWidget, reason: label);
      }
    });

    testWidgets('Data Diri tetap bisa diketuk dan membuka halamannya', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const ProfilePage()));
      await tester.pumpAndSettle();

      await scrollAndTap(tester, find.text('Data Diri'));
      expect(find.byType(PersonalDataPage), findsOneWidget);
    });

    testWidgets('halaman Data Diri tidak berubah: masih kotak terpisah', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(PersonalDataPage(user: dummyUserProfile)),
      );
      await tester.pumpAndSettle();

      // Permintaan: tampilan di dalam Data Diri tidak diubah.
      expect(find.byType(ProfileMenuCard), findsWidgets);
      expect(find.byType(ProfileGroupCard), findsNothing);
      expect(find.byType(ProfileGroupRow), findsNothing);
    });

    testWidgets('tidak ada overflow di berbagai ukuran Android', (
      WidgetTester tester,
    ) async {
      for (final size in [
        const Size(360, 640),
        const Size(393, 852),
        const Size(412, 915),
      ]) {
        tester.view.physicalSize = size * 3;
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_host(const ProfilePage()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Profil $size');
      }
    });
    testWidgets('menampilkan data pengguna sesuai desain', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const ProfilePage()));
      await tester.pumpAndSettle();

      // "Profil" hanya muncul sebagai judul halaman; navbar dipegang shell.
      expect(find.text('Profil'), findsOneWidget);
      expect(find.text('Andi Pratama'), findsOneWidget);
      expect(find.text('Pegawai'), findsOneWidget);
      expect(find.text('NIP. 1908125456709010'), findsOneWidget);
      expect(find.text('UP3 Magelang'), findsWidgets);

      expect(find.text('Data Diri'), findsOneWidget);
      expect(find.text('Unit Kerja'), findsOneWidget);
      expect(find.text('Nomor HP'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('0881 2345 6789'), findsOneWidget);
      expect(find.text('andi.pratama@pln.co.id'), findsOneWidget);

      expect(find.text('Pengaturan'), findsOneWidget);
      expect(find.text('Bantuan'), findsOneWidget);
      expect(find.text('Tentang Aplikasi'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Keluar'), findsOneWidget);
    });

    testWidgets('navigasi menuju empat halaman turunan', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const ProfilePage()));
      await tester.pumpAndSettle();

      await scrollAndTap(tester, find.text('Data Diri'));
      expect(find.byType(PersonalDataPage), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      await scrollAndTap(tester, find.text('Pengaturan'));
      expect(find.byType(SettingsPage), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      await scrollAndTap(tester, find.text('Bantuan'));
      expect(find.byType(HelpPage), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      await scrollAndTap(tester, find.text('Tentang Aplikasi'));
      expect(find.byType(AboutPage), findsOneWidget);
    });

    testWidgets('shell membuka Profil, Kendaraan, dan Notifikasi', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const AppShellPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('app_bottom_nav_profil')));
      await tester.pumpAndSettle();
      expect(find.byType(ProfilePage, skipOffstage: true), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('app_bottom_nav_kendaraan')));
      await tester.pumpAndSettle();
      expect(find.byType(VehicleListPage, skipOffstage: true), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('app_bottom_nav_notifikasi')));
      await tester.pumpAndSettle();
      expect(find.byType(NotificationPage, skipOffstage: true), findsOneWidget);
    });
  });

  group('Halaman Data Diri', () {
    testWidgets('menampilkan seluruh data pengguna', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(PersonalDataPage(user: dummyUserProfile)));
      await tester.pumpAndSettle();

      expect(find.text('Data Diri'), findsOneWidget);
      expect(find.text('Nama Lengkap'), findsOneWidget);
      expect(find.text('Andi Pratama'), findsWidgets);
      expect(find.text('NIP'), findsOneWidget);
      expect(find.text('1908125456709010'), findsOneWidget);
      expect(find.text('Jabatan'), findsOneWidget);
      expect(find.text('Pegawai'), findsOneWidget);
      expect(find.text('Unit Kerja'), findsOneWidget);
      expect(find.text('Nomor HP'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Edit Data'), findsOneWidget);
    });

    testWidgets('Edit Data menampilkan input lalu menyimpan nilai baru', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(PersonalDataPage(user: dummyUserProfile)));
      await tester.pumpAndSettle();

      await scrollAndTap(
        tester,
        find.widgetWithText(ElevatedButton, 'Edit Data'),
      );
      expect(
        find.widgetWithText(ElevatedButton, 'Simpan Perubahan'),
        findsOneWidget,
      );

      final inputs = find.byType(TextField);
      // Nama, unit kerja, nomor HP, email.
      expect(inputs, findsNWidgets(4));
      await tester.enterText(inputs.at(0), 'Andi Pratama Wijaya');
      await tester.enterText(inputs.at(1), 'UP3 Semarang');
      await tester.enterText(inputs.at(2), '0812 3456 6789');
      await tester.enterText(inputs.at(3), 'andi.wijaya@pln.co.id');
      await scrollAndTap(
        tester,
        find.widgetWithText(ElevatedButton, 'Simpan Perubahan'),
      );

      expect(find.widgetWithText(ElevatedButton, 'Edit Data'), findsOneWidget);
      expect(find.text('Andi Pratama Wijaya'), findsWidgets);
      expect(find.text('UP3 Semarang'), findsWidgets);
      expect(find.text('0812 3456 6789'), findsOneWidget);
      expect(find.text('andi.wijaya@pln.co.id'), findsOneWidget);
    });

    testWidgets('NIP dan Jabatan tidak bisa diedit', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(PersonalDataPage(user: dummyUserProfile)));
      await tester.pumpAndSettle();

      await scrollAndTap(
        tester,
        find.widgetWithText(ElevatedButton, 'Edit Data'),
      );

      // Hanya 4 field yang bisa diedit: nama, unit kerja, nomor HP, email.
      expect(find.byType(TextField), findsNWidgets(4));
    });

    testWidgets('perubahan tersimpan dan halaman Profil ikut berubah', (
      WidgetTester tester,
    ) async {
      final auth = AuthState()..signIn();
      await tester.pumpWidget(
        _host(PersonalDataPage(user: dummyUserProfile), auth: auth),
      );
      await tester.pumpAndSettle();

      await scrollAndTap(
        tester,
        find.widgetWithText(ElevatedButton, 'Edit Data'),
      );
      await tester.enterText(find.byType(TextField).at(1), 'UP3 Semarang');
      await tester.enterText(find.byType(TextField).at(2), '0812 3456 6789');
      await scrollAndTap(
        tester,
        find.widgetWithText(ElevatedButton, 'Simpan Perubahan'),
      );

      // Tersimpan di state, bukan hanya tampil di halaman ini.
      expect(auth.user!.unit, 'UP3 Semarang');
      expect(auth.user!.phone, '0812 3456 6789');

      // Kembali ke Profil, nilai baru ikut tampil.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.pumpWidget(_host(const ProfilePage(), auth: auth));
      await tester.pumpAndSettle();

      // Muncul di baris Unit Kerja dan juga di header profil.
      expect(find.text('UP3 Semarang'), findsNWidgets(2));
      expect(find.text('0812 3456 6789'), findsOneWidget);
      expect(find.text('UP3 Magelang'), findsNothing);
    });
  });

  group('Halaman Pengaturan', () {
    testWidgets('menampilkan kelompok pengaturan yang relevan', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const SettingsPage()));
      await tester.pumpAndSettle();

      expect(find.text('Pengaturan'), findsOneWidget);
      expect(find.text('Akun'), findsOneWidget);
      expect(find.text('Edit Profil'), findsOneWidget);
      expect(find.text('Ubah Password'), findsOneWidget);
      expect(find.text('Notifikasi Peminjaman'), findsOneWidget);
      expect(find.text('Notifikasi Persetujuan'), findsOneWidget);
      expect(find.text('Aplikasi'), findsOneWidget);
      expect(find.text('Bahasa'), findsOneWidget);
      expect(find.text('Tema Gelap'), findsOneWidget);
      expect(find.text('Tentang Aplikasi'), findsOneWidget);
    });

    testWidgets('toggle dapat dinyalakan dan dimatikan', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const SettingsPage()));
      await tester.pumpAndSettle();

      final toggles = find.byType(Switch);
      expect(toggles, findsNWidgets(4));

      expect(tester.widget<Switch>(toggles.at(0)).value, isTrue);
      await tester.ensureVisible(toggles.at(0));
      await tester.pumpAndSettle();
      await tester.tap(toggles.at(0));
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(toggles.at(0)).value, isFalse);
    });

    testWidgets('Edit Profil dan Tentang Aplikasi bisa dibuka', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const SettingsPage()));
      await tester.pumpAndSettle();

      await scrollAndTap(tester, find.text('Edit Profil'));
      expect(find.byType(PersonalDataPage), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      await scrollAndTap(tester, find.text('Tentang Aplikasi'));
      expect(find.byType(AboutPage), findsOneWidget);
    });
  });

  group('Halaman Bantuan', () {
    testWidgets('menampilkan daftar kategori bantuan', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const HelpPage()));
      await tester.pumpAndSettle();

      expect(find.text('Bantuan'), findsOneWidget);
      expect(find.text('Cara Mengajukan Peminjaman'), findsOneWidget);
      expect(find.text('Cara Melihat Status Peminjaman'), findsOneWidget);
      expect(find.text('Cara Menghubungi Driver'), findsOneWidget);
      expect(find.text('Cara Menyelesaikan Perjalanan'), findsOneWidget);
      expect(find.text('Cara Mengisi Data BBM'), findsOneWidget);
    });

    testWidgets('membuka halaman detail bantuan', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const HelpPage()));
      await tester.pumpAndSettle();

      await scrollAndTap(tester, find.text('Cara Mengajukan Peminjaman'));

      expect(find.byType(HelpArticlePage), findsOneWidget);
      expect(
        find.text(
          'Buka menu Kendaraan lalu pilih kendaraan yang berstatus Tersedia.',
        ),
        findsOneWidget,
      );
    });
  });

  group('Halaman Tentang Aplikasi', () {
    testWidgets('menampilkan logo, nama, versi, dan deskripsi', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const AboutPage()));
      await tester.pumpAndSettle();

      expect(find.text('Tentang Aplikasi'), findsOneWidget);
      expect(find.text('PLN UP3 Magelang'), findsWidgets);
      expect(find.text('Aplikasi Peminjaman Kendaraan Dinas'), findsOneWidget);
      expect(find.text('Versi 1.0.0'), findsOneWidget);
      expect(find.text('Pengembang'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('Login dan Logout', () {
    testWidgets('login dengan credential benar masuk ke Beranda', (
      WidgetTester tester,
    ) async {
      final auth = AuthState();
      await tester.pumpWidget(_host(const LoginPage(), auth: auth));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), dummyEmail);
      await tester.enterText(fields.at(1), dummyPassword);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(auth.isSignedIn, isTrue);
      expect(auth.user, dummyUserProfile);
    });

    testWidgets('login dengan credential salah tetap di Login', (
      WidgetTester tester,
    ) async {
      final auth = AuthState();
      await tester.pumpWidget(_host(const LoginPage(), auth: auth));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), dummyEmail);
      await tester.enterText(fields.at(1), 'salah');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Email atau password salah.'), findsOneWidget);
      expect(auth.isSignedIn, isFalse);
    });

    testWidgets('tombol Keluar menghapus session dan kembali ke Login', (
      WidgetTester tester,
    ) async {
      final auth = AuthState()..signIn();
      await tester.pumpWidget(_host(const ProfilePage(), auth: auth));
      await tester.pumpAndSettle();

      await scrollAndTap(tester, find.widgetWithText(ElevatedButton, 'Keluar'));

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(ProfilePage), findsNothing);
      expect(auth.isSignedIn, isFalse);
      expect(auth.user, isNull);
    });

    testWidgets('keluar dari Beranda lalu login lagi', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.byType(OnboardingFirstPage));
      await tester.pumpAndSettle();

      // Slide kedua menampilkan tombol Login, baru formulirnya muncul.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), dummyEmail);
      await tester.enterText(fields.at(1), dummyPassword);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      expect(find.byType(AppShellPage), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('app_bottom_nav_profil')));
      await tester.pumpAndSettle();
      expect(find.byType(ProfilePage, skipOffstage: true), findsOneWidget);

      await scrollAndTap(tester, find.widgetWithText(ElevatedButton, 'Keluar'));
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('shell bisa membuka halaman Profil dari Beranda', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const AppShellPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('app_bottom_nav_profil')));
      await tester.pumpAndSettle();

      expect(find.byType(ProfilePage, skipOffstage: true), findsOneWidget);
    });
  });

  testWidgets('halaman profil dan turunannya responsif di Android', (
    WidgetTester tester,
  ) async {
    const sizes = [Size(320, 480), Size(360, 640), Size(393, 852)];

    for (final size in sizes) {
      await tester.binding.setSurfaceSize(size);

      for (final page in <Widget>[
        const ProfilePage(),
        PersonalDataPage(user: dummyUserProfile),
        const SettingsPage(),
        const HelpPage(),
        const AboutPage(),
      ]) {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(_host(page));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${page.runtimeType} should fit at $size',
        );
      }

      await tester.binding.setSurfaceSize(null);
    }
  });
}
