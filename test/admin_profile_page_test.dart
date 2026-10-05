import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_plnmobile/models/admin_profile.dart';
import 'package:flutter_application_plnmobile/pages/about_page.dart';
import 'package:flutter_application_plnmobile/pages/help_page.dart';
import 'package:flutter_application_plnmobile/pages/personal_data_page.dart';
import 'package:flutter_application_plnmobile/pages/settings_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_personal_data_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_profile_page.dart';
import 'package:flutter_application_plnmobile/state/admin_auth_state.dart';
import 'package:flutter_application_plnmobile/state/admin_loan_state.dart';
import 'package:flutter_application_plnmobile/state/admin_notification_state.dart';
import 'package:flutter_application_plnmobile/state/admin_vehicle_state.dart';
import 'package:flutter_application_plnmobile/widgets/admin_bottom_navigation.dart';
import 'package:flutter_application_plnmobile/widgets/app_bottom_navigation.dart';
import 'package:flutter_application_plnmobile/widgets/profile_group_row.dart';

Widget _host(Widget child) {
  return AdminNotificationStateScope(
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
}

Future<void> _openProfile(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(_host(const AdminProfilePage()));
  await tester.pumpAndSettle();
}

/// Baris profil yang bisa ditekan, sesuai urutannya di halaman.
Finder _row(String label) => find.widgetWithText(ProfileGroupRow, label);

void main() {
  group('Baris profil Admin bisa diklik', () {
    testWidgets('hanya Data Diri yang membuka halaman Data Diri', (
      WidgetTester tester,
    ) async {
      await _openProfile(tester);

      final dataDiri = tester.widget<ProfileGroupRow>(_row('Data Diri'));
      expect(dataDiri.onTap, isNotNull, reason: 'Data Diri harus bisa diklik');

      await tester.tap(_row('Data Diri'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.byType(AdminPersonalDataPage), findsOneWidget);

      await tester.tap(find.byTooltip('Kembali').first);
      await tester.pumpAndSettle();
      expect(find.byType(AdminProfilePage), findsOneWidget);
    });

    // Akses, Nomor HP, dan Email hanya keterangan, jadi tidak boleh punya
    // onTap dan tidak boleh menampilkan chevron.
    for (final label in ['Akses', 'Nomor HP', 'Email']) {
      testWidgets('$label hanya keterangan dan tidak punya chevron', (
        WidgetTester tester,
      ) async {
        await _openProfile(tester);

        final row = tester.widget<ProfileGroupRow>(_row(label));
        expect(row.onTap, isNull, reason: '$label tidak boleh bisa diklik');

        // Menyetel baris tidak membuka halaman apa pun.
        await tester.tap(_row(label), warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.byType(AdminPersonalDataPage), findsNothing);
        expect(find.byType(AdminProfilePage), findsOneWidget);

        // Tidak ada chevron di baris yang tidak bisa diklik.
        expect(
          find.descendant(of: _row(label), matching: find.byIcon(Icons.chevron_right_rounded)),
          findsNothing,
          reason: '$label tidak boleh menampilkan chevron',
        );
      });
    }

    testWidgets('Data Diri tetap punya chevron', (WidgetTester tester) async {
      await _openProfile(tester);

      expect(
        find.descendant(
          of: _row('Data Diri'),
          matching: find.byIcon(Icons.chevron_right_rounded),
        ),
        findsOne,
      );
    });

    testWidgets('area ketuk baris menutupi seluruh lebar baris', (
      WidgetTester tester,
    ) async {
      await _openProfile(tester);

      final row = _row('Nomor HP');
      final size = tester.getSize(row);
      final screen = tester.getSize(find.byType(Scaffold));

      // Baris harus melebar mengikuti kartu, bukan cuma sebesar teksnya.
      expect(size.width, greaterThan(screen.width * 0.8));
    });

    testWidgets('baris tanpa onTap tidak menampilkan chevron', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        _host(const AdminPersonalDataPage(profile: dummyAdminProfile)),
      );
      await tester.pumpAndSettle();

      // Di halaman Data Diri semua baris hanya menampilkan data, jadi tidak ada
      // chevron sama sekali walau flag-nya masih true.
      final rows = tester
          .widgetList<ProfileGroupRow>(find.byType(ProfileGroupRow))
          .toList();
      expect(rows.length, 4);
      for (final row in rows) {
        expect(row.onTap, isNull);
      }
      expect(
        find.byIcon(Icons.chevron_right_rounded),
        findsNothing,
        reason: 'halaman Data Diri tidak butuh chevron',
      );
    });
  });

  group('Tata letak profil Admin', () {
    testWidgets('data profil terbaca lengkap', (WidgetTester tester) async {
      await _openProfile(tester);

      expect(find.text('Admin'), findsWidgets);
      expect(find.text('Administrator'), findsWidgets);
      expect(find.text('0881 2345 6789'), findsOneWidget);
      expect(find.text('admin@pln.co.id'), findsOneWidget);
    });

    testWidgets('baris memakai grouped list: satu kartu, pemisah antar baris', (
      WidgetTester tester,
    ) async {
      await _openProfile(tester);

      // Dua kartu: kartu data diri (4 baris) dan kartu menu (3 baris).
      expect(find.byType(ProfileGroupCard), findsNWidgets(2));
      expect(find.byType(ProfileGroupRow), findsNWidgets(7));

      // Baris dipisah garis tipis, bukan kotak sendiri-sendiri:
      // 4 baris -> 3 pemisah, 3 baris -> 2 pemisah.
      expect(find.byType(Divider), findsNWidgets(5));
    });

    testWidgets('label dan nilai tidak tumpang tindih', (
      WidgetTester tester,
    ) async {
      await _openProfile(tester);

      // Lebar label dibuat tetap sehingga nilai kolom selalu rata kanan.
      final nominal = tester.getRect(_row('Nomor HP'));
      final email = tester.getRect(_row('Email'));
      expect(nominal.left, email.left);
      expect(nominal.width, email.width);
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

        await _openProfile(tester);
        expect(tester.takeException(), isNull, reason: 'Profil $size');

        await tester.tap(_row('Data Diri'), warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'Data Diri $size',
        );

        // Mode edit juga harus muat di layar sempit.
        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Edit $size');
      }
    });
  });

  group('Menu turunan Profil Admin sama dengan user', () {
    testWidgets('Pengaturan membuka halaman Pengaturan, bukan SnackBar', (
      WidgetTester tester,
    ) async {
      await _openProfile(tester);

      await tester.tap(_row('Pengaturan'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.text('Akun'), findsOneWidget);
      expect(find.text('Notifikasi Peminjaman'), findsOneWidget);
      expect(find.text('Tema Gelap'), findsOneWidget);
      // Tidak lagi sekadar/snack "akan dilengkapi".
      expect(find.textContaining('akan dilengkapi'), findsNothing);
    });

    testWidgets('Bantuan membuka halaman Bantuan yang sudah ada', (
      WidgetTester tester,
    ) async {
      await _openProfile(tester);

      await tester.tap(_row('Bantuan'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(HelpPage), findsOneWidget);
      expect(find.text('Email Helpdesk'), findsOneWidget);
      expect(find.textContaining('akan dilengkapi'), findsNothing);
    });

    testWidgets('Tentang Aplikasi membuka halaman Tentang Aplikasi', (
      WidgetTester tester,
    ) async {
      await _openProfile(tester);

      await tester.tap(_row('Tentang Aplikasi'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(AboutPage), findsOneWidget);
      expect(find.text(aboutAppVersion), findsWidgets);
      expect(find.textContaining('akan dilengkapi'), findsNothing);
    });

    testWidgets('halaman turunan tidak memunculkan navbar user', (
      WidgetTester tester,
    ) async {
      await _openProfile(tester);

      for (final (label, type) in [
        ('Pengaturan', SettingsPage),
        ('Bantuan', HelpPage),
        ('Tentang Aplikasi', AboutPage),
      ]) {
        await tester.tap(_row(label), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(find.byType(type), findsOneWidget, reason: label);
        expect(
          find.byType(AppBottomNavigation),
          findsNothing,
          reason: '$label di area Admin tidak boleh memakai navbar user',
        );
        expect(
          find.byType(AdminBottomNavigation),
          findsNothing,
          reason: 'halaman detail Admin memang tanpa navbar',
        );

        await tester.tap(find.byTooltip('Kembali').first);
        await tester.pumpAndSettle();
        expect(find.byType(AdminProfilePage), findsOneWidget);
      }
    });

    testWidgets('Edit Profil di Pengaturan membuka Data Diri Admin', (
      WidgetTester tester,
    ) async {
      await _openProfile(tester);

      await tester.tap(_row('Pengaturan'), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit Profil'));
      await tester.pumpAndSettle();

      // Harus Data Diri Admin, bukan PersonalDataPage milik user.
      expect(find.byType(AdminPersonalDataPage), findsOneWidget);
      expect(find.byType(PersonalDataPage), findsNothing);
    });

    testWidgets('Tentang Aplikasi dari dalam Pengaturan tetap tanpa navbar', (
      WidgetTester tester,
    ) async {
      await _openProfile(tester);

      await tester.tap(_row('Pengaturan'), warnIfMissed: false);
      await tester.pumpAndSettle();
      // Baris ini berada di bawah lipatan pada layar test.
      final aboutRow = find.text('Tentang Aplikasi');
      await tester.ensureVisible(aboutRow);
      await tester.pumpAndSettle();
      await tester.tap(aboutRow);
      await tester.pumpAndSettle();

      expect(find.byType(AboutPage), findsOneWidget);
      expect(find.byType(AppBottomNavigation), findsNothing);
    });

    testWidgets('setiap menu turunan bisa ditutup dan kembali ke Profil', (
      WidgetTester tester,
    ) async {
      for (final label in ['Pengaturan', 'Bantuan', 'Tentang Aplikasi']) {
        await _openProfile(tester);
        await tester.tap(_row(label), warnIfMissed: false);
        await tester.pumpAndSettle();
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(find.byType(AdminProfilePage), findsOneWidget, reason: label);
        expect(tester.takeException(), isNull, reason: label);
      }
    });
  });

  group('Halaman Data Diri Admin', () {
    testWidgets('menampilkan seluruh data akses, nomor HP, dan email', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        _host(const AdminPersonalDataPage(profile: dummyAdminProfile)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nama'), findsOneWidget);
      expect(find.text('Akses'), findsOneWidget);
      expect(find.text('Nomor HP'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);

      expect(find.text('Administrator'), findsNWidgets(2));
      expect(find.text('0881 2345 6789'), findsOneWidget);
      expect(find.text('admin@pln.co.id'), findsOneWidget);
    });

    testWidgets('halaman detail tidak memakai navbar', (
      WidgetTester tester,
    ) async {
      await _openProfile(tester);
      await tester.tap(_row('Data Diri'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(AdminBottomNavigation), findsNothing);
      expect(find.text('Data Diri'), findsWidgets);
    });

    testWidgets('Akses, Nomor HP, Email bisa diisi dan disimpan', (
      WidgetTester tester,
    ) async {
      final auth = AdminAuthState()..signIn();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        AdminNotificationStateScope(
          state: AdminNotificationState(),
          child: AdminVehicleStateScope(
            state: AdminVehicleState(),
            child: AdminLoanStateScope(
              state: AdminLoanState(),
              child: AdminAuthStateScope(
                state: auth,
                child: const MaterialApp(
                  home: AdminPersonalDataPage(profile: dummyAdminProfile),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Sebelum mode edit belum ada input.
      expect(find.byType(TextField), findsNothing);

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Tiga field yang boleh diisi.
      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(3));

      await tester.enterText(fields.at(0), 'Super Admin');
      await tester.enterText(fields.at(1), '0812 3456 6789');
      await tester.enterText(fields.at(2), 'admin.pln@pln.co.id');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan Perubahan'));
      await tester.pumpAndSettle();

      // Kembali ke mode tampilan dengan nilai baru.
      expect(find.byType(TextField), findsNothing);
      // "Super Admin" muncul dua kali: di kartu identitas dan di baris Akses.
      expect(find.text('Super Admin'), findsNWidgets(2));
      expect(find.text('0812 3456 6789'), findsOneWidget);
      expect(find.text('admin.pln@pln.co.id'), findsOneWidget);

      // Tersimpan di state, bukan hanya tampil di halaman ini.
      expect(auth.profile!.role, 'Super Admin');
      expect(auth.profile!.phone, '0812 3456 6789');
      expect(auth.profile!.email, 'admin.pln@pln.co.id');
    });

    testWidgets('halaman Profil ikut menampilkan data yang baru disimpan', (
      WidgetTester tester,
    ) async {
      final auth = AdminAuthState()..signIn();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        AdminNotificationStateScope(
          state: AdminNotificationState(),
          child: AdminVehicleStateScope(
            state: AdminVehicleState(),
            child: AdminLoanStateScope(
              state: AdminLoanState(),
              child: AdminAuthStateScope(
                state: auth,
                child: const MaterialApp(home: AdminProfilePage()),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('0881 2345 6789'), findsOneWidget);

      await tester.tap(_row('Data Diri'), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).at(1),
        '0812 3456 6789',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan Perubahan'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Kembali').first);
      await tester.pumpAndSettle();

      // Kembali ke Profil, nomor HP harus yang baru.
      expect(find.text('0812 3456 6789'), findsOneWidget);
      expect(find.text('0881 2345 6789'), findsNothing);
    });

    testWidgets('tombol Batal mengembalikan nilai yang belum disimpan', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        _host(const AdminPersonalDataPage(profile: dummyAdminProfile)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(1), '0000');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
      expect(find.text('0000'), findsNothing);
      expect(find.text('0881 2345 6789'), findsOneWidget);
    });

    testWidgets('Nama tidak bisa diisi', (WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        _host(const AdminPersonalDataPage(profile: dummyAdminProfile)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Hanya tiga input: Akses, Nomor HP, Email.
      expect(find.byType(TextField), findsNWidgets(3));
    });
  });
}