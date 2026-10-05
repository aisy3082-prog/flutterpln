import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_plnmobile/data/admin_vehicle_data.dart';
import 'package:flutter_application_plnmobile/data/driver_data.dart';
import 'package:flutter_application_plnmobile/models/admin_dashboard.dart';
import 'package:flutter_application_plnmobile/models/driver.dart';
import 'package:flutter_application_plnmobile/models/vehicle.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_driver_confirm_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_home_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_loan_detail_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_loan_list_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_navigation.dart';
import 'package:flutter_application_plnmobile/state/admin_loan_state.dart';
import 'package:flutter_application_plnmobile/state/admin_notification_state.dart';
import 'package:flutter_application_plnmobile/state/admin_vehicle_state.dart';
import 'package:flutter_application_plnmobile/widgets/admin_bottom_navigation.dart';
import 'package:flutter_application_plnmobile/widgets/admin_loan_card.dart';

/// Id dari data dummy yang dipakai di test ini.
const _mobilMenunggu = 'PLN-2026-0001'; // Toyota Innova, Budi Santoso
const _motorMenunggu = 'PLN-2026-0002'; // Lifan, Siti Aminah

Finder _nav(String label) => find.byKey(ValueKey('admin_bottom_nav_$label'));
Finder _field() => find.byType(TextField);

/// Tombol ElevatedButton yang memuat [label].
///
/// Dipakai `byWidgetPredicate` supaya ikut mencocokkan `ElevatedButton.icon`,
/// karena `find.byType` hanya cocok dengan tipe persis.
Finder _btn(String label) => find.ancestor(
  of: find.text(label),
  matching: find.byWidgetPredicate((w) => w is ElevatedButton),
);

/// Tombol pada baris driver tertentu, lewat key yang stabil.
Finder _driverButton(String driverId) =>
    find.byKey(ValueKey('admin_driver_pick_$driverId'));

Finder _confirmButton() => find.byKey(const ValueKey('admin_driver_confirm_button'));

/// Tombol filter Semua/Mobil/Motor, yang memakai Material + InkWell.
Finder _filter(String label) => find.widgetWithText(InkWell, label);

/// Ketuk sebuah widget setelah digulir ke dalam layar dulu.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

/// Buka card peminjaman berdasarkan nama peminjam.
Future<void> openLoanByBorrower(
  WidgetTester tester,
  String borrower,
) async {
  final card = find.descendant(
    of: find.byType(AdminLoanCard),
    matching: find.text(borrower),
  );
  await tapVisible(tester, card);
}

/// Shell Admin dengan state peminjaman yang bisa diperiksa.
Future<AdminLoanState> bootShell(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  final state = AdminLoanState();
  await tester.pumpWidget(
    AdminNotificationStateScope(
      state: AdminNotificationState(),
      child: AdminVehicleStateScope(
        state: AdminVehicleState(vehicles: dummyAdminVehicles),
        child: AdminLoanStateScope(
          state: state,
          child: const MaterialApp(home: AdminShellPage()),
        ),
      ),
      ),
  );
  await tester.pumpAndSettle();
  return state;
}

/// Membuka daftar peminjaman dengan filter tertentu.
Future<AdminLoanState> openList(
  WidgetTester tester, {
  VehicleType? filter,
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  final state = AdminLoanState();
  await tester.pumpWidget(
    AdminNotificationStateScope(
      state: AdminNotificationState(),
      child: AdminVehicleStateScope(
        state: AdminVehicleState(vehicles: dummyAdminVehicles),
        child: AdminLoanStateScope(
          state: state,
          child: MaterialApp(
            home: AdminLoanListPage(initialFilter: filter),
          ),
        ),
      ),
      ),
  );
  await tester.pumpAndSettle();
  return state;
}

int _selected(WidgetTester tester) => tester
    .widget<AdminBottomNavigation>(find.byType(AdminBottomNavigation))
    .selectedIndex;

void main() {
  group('TEST 1 & 2: card statistik membuka daftar dengan filter', () {
    testWidgets('TEST 1: Peminjaman Mobil -> Daftar dengan filter Mobil', (
      WidgetTester tester,
    ) async {
      await bootShell(tester);

      await tester.tap(find.text('Peminjaman Mobil'));
      await tester.pumpAndSettle();

      // Membuka halaman daftar yang sama, bukan halaman baru.
      expect(find.byType(AdminLoanListPage), findsOneWidget);
      expect(find.text('Daftar Peminjaman Terbaru'), findsOneWidget);

      // Hanya mobil yang tampil.
      expect(find.byType(AdminLoanCard), findsNWidgets(2));
      expect(
        find.descendant(
          of: find.byType(AdminLoanCard),
          matching: find.text('Toyota Innova'),
        ),
        findsNWidgets(2),
      );

      // Filter Mobil aktif, dan Admin tetap bisa menggantinya.
      final aktif = find.ancestor(
        of: find.text('Mobil'),
        matching: find.byType(Ink),
      );
      expect(
        tester.widget<Ink>(aktif.first).decoration,
        isA<BoxDecoration>().having(
          (d) => d.color,
          'color',
          const Color(0xFF0B75D1),
        ),
      );

      await tester.tap(_filter('Semua'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoanCard), findsNWidgets(4));
    });

    testWidgets('TEST 2: Peminjaman Motor -> Daftar dengan filter Motor', (
      WidgetTester tester,
    ) async {
      await bootShell(tester);

      await tester.tap(find.text('Peminjaman Motor'));
      await tester.pumpAndSettle();

      expect(find.byType(AdminLoanListPage), findsOneWidget);
      expect(find.byType(AdminLoanCard), findsNWidgets(2));
      expect(
        find.descendant(
          of: find.byType(AdminLoanCard),
          matching: find.text('Lifan'),
        ),
        findsNWidgets(2),
      );

      final aktif = find.ancestor(
        of: find.text('Motor'),
        matching: find.byType(Ink),
      );
      expect(
        tester.widget<Ink>(aktif.first).decoration,
        isA<BoxDecoration>().having(
          (d) => d.color,
          'color',
          const Color(0xFF0B75D1),
        ),
      );
    });

    testWidgets('card lain (Menunggu Driver) tidak membuka daftar', (
      WidgetTester tester,
    ) async {
      await bootShell(tester);
      await tester.tap(find.text('Menunggu Driver'));
      await tester.pumpAndSettle();
      // Tetap di Beranda; daftar yang ada di shell tab 1 masih offstage.
      expect(find.byType(AdminLoanListPage, skipOffstage: true), findsNothing);
      expect(find.byType(AdminHomePage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('TEST 3: card Menunggu membuka detail sesuai jenis', () {
    testWidgets('TEST 3a: mobil Menunggu -> Detail Peminjaman Mobil', (
      WidgetTester tester,
    ) async {
      await openList(tester);

      await openLoanByBorrower(tester, 'Budi Santoso');

      expect(find.byType(AdminLoanDetailPage), findsOneWidget);
      expect(find.text('Detail Peminjaman Mobil'), findsOneWidget);
      // Tombol aksi tetap ada karena status masih Menunggu.
      expect(_btn('Setujui'), findsOneWidget);
      expect(_btn('Tolak'), findsOneWidget);
      expect(find.text('Menunggu Persetujuan'), findsOneWidget);
    });

    testWidgets('TEST 3b: motor Menunggu -> Detail Peminjaman Motor', (
      WidgetTester tester,
    ) async {
      await openList(tester);

      await openLoanByBorrower(tester, 'Siti Aminah');

      expect(find.byType(AdminLoanDetailPage), findsOneWidget);
      expect(find.text('Detail Peminjaman Motor'), findsOneWidget);
      // Motor tidak punya blok driver.
      expect(_btn('Ganti Driver'), findsNothing);
      expect(_btn('Setujui'), findsOneWidget);
    });

    testWidgets('informasi peminjaman tampil lengkap', (
      WidgetTester tester,
    ) async {
      await openList(tester);
      await openLoanByBorrower(tester, 'Budi Santoso');

      expect(find.text('Informasi Peminjaman'), findsOneWidget);
      expect(find.text('Nama'), findsOneWidget);
      expect(find.text('No. HP'), findsOneWidget);
      expect(find.text('Tanggal Pinjam'), findsOneWidget);
      expect(find.text('Tanggal Kembali'), findsOneWidget);
      expect(find.text('Tujuan'), findsOneWidget);
      expect(find.text('14 Sep 2026, 16:00'), findsOneWidget);
      expect(find.text('Batik, kuliner magelang'), findsOneWidget);
    });
  });

  group('TEST 4: Ganti Driver membuka Konfirmasi Driver', () {
    testWidgets('TEST 4: Detail Mobil -> Konfirmasi Driver', (
      WidgetTester tester,
    ) async {
      await openList(tester);
      await openLoanByBorrower(tester, 'Budi Santoso');

      await tapVisible(tester, _btn('Ganti Driver'));

      expect(find.byType(AdminDriverConfirmPage), findsOneWidget);
      expect(find.text('Konfirmasi Driver'), findsOneWidget);
      expect(find.text('Data Peminjam'), findsOneWidget);
      expect(find.text('Data Driver'), findsOneWidget);
      expect(find.text('Jadwal'), findsOneWidget);
    });

    testWidgets('driver default mobil tampil tanpa Admin memilih', (
      WidgetTester tester,
    ) async {
      await openList(tester);
      await openLoanByBorrower(tester, 'Budi Santoso');

      // Toyota Innova punya driver default Andi Pratama.
      expect(find.text('Andi Pratama'), findsOneWidget);
      expect(find.text('Driver'), findsOneWidget);
    });

    testWidgets('halaman konfirmasi menampilkan semua driver', (
      WidgetTester tester,
    ) async {
      await openList(tester);
      await openLoanByBorrower(tester, 'Budi Santoso');
      await tapVisible(tester, _btn('Ganti Driver'));

      expect(find.text('Daftar Driver Tersedia'), findsOneWidget);
      for (final driver in dummyDrivers) {
        expect(find.text(driver.name), findsWidgets);
      }
    });
  });

  group('TEST 5: aturan(driver pilih driver)', () {
    Future<void> openDriverPage(WidgetTester tester) async {
      await openList(tester);
      await openLoanByBorrower(tester, 'Budi Santoso');
      await tapVisible(tester, _btn('Ganti Driver'));
    }

    testWidgets('TEST 5: driver tersedia bisa dipilih', (
      WidgetTester tester,
    ) async {
      await openDriverPage(tester);

      // Driver default sudah terpilih (Andi Pratama).
      await tapVisible(tester, _btn('Pilih').last);
      expect(tester.takeException(), isNull);

      // Driver baru yang dipilih muncul di blok Data Driver.
      final terisi = find.descendant(
        of: find.byType(AdminDriverConfirmPage),
        matching: find.text('Dimas Saputra'),
      );
      expect(terisi, findsWidgets);
    });

    testWidgets('TEST 5: driver sedang bertugas tidak bisa dipilih', (
      WidgetTester tester,
    ) async {
      await openDriverPage(tester);

      // Rizki Maulana berstatus Sibuk => tombolnya nonaktif.
      final button = tester.widget<ElevatedButton>(
        _driverButton('DRV-005').first,
      );
      expect(
        button.onPressed,
        isNull,
        reason: 'driver sibuk tidak boleh dipilih',
      );
      expect(find.text('Sedang Bertugas'), findsWidgets);
    });

    testWidgets('search driver menyaring daftar', (WidgetTester tester) async {
      await openDriverPage(tester);

      await tester.enterText(_field(), 'Budi');
      await tester.pumpAndSettle();

      expect(find.text('Budi Setiawan'), findsOneWidget);
      expect(find.text('Angga Yuan'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('TEST 6: konfirmasi driver menyimpan dan menyetujui', () {
    testWidgets('TEST 6: pilih driver -> konfirmasi -> status Disetujui', (
      WidgetTester tester,
    ) async {
      final state = await openList(tester);

      await openLoanByBorrower(tester, 'Budi Santoso');
      await tapVisible(tester, _btn('Ganti Driver'));

      // Pilih Dimas Saputra.
      await tapVisible(tester, _driverButton('DRV-003'));
      await tester.pumpAndSettle();
      await tapVisible(tester, _confirmButton());

      // Kembali ke Detail.
      expect(find.byType(AdminDriverConfirmPage), findsNothing);
      expect(find.byType(AdminLoanDetailPage), findsOneWidget);

      // Status benar-benar berubah di state.
      expect(state.byId(_mobilMenunggu)!.status, AdminLoanStatus.disetujui);
      expect(state.byId(_mobilMenunggu)!.driverId, 'DRV-003');

      // Detail menampilkan driver yang dipilih dan status baru.
      expect(find.text('Detail Peminjaman Disetujui'), findsOneWidget);
      expect(find.text('Dimas Saputra'), findsOneWidget);
      expect(_btn('Setujui'), findsNothing);
    });
  });

  group('TEST 7: motor bisa langsung disetujui', () {
    testWidgets('TEST 7: Detail Motor -> Setujui -> status Disetujui', (
      WidgetTester tester,
    ) async {
      final state = await openList(tester);

      await openLoanByBorrower(tester, 'Siti Aminah');

      await tapVisible(tester, _btn('Setujui'));

      expect(state.byId(_motorMenunggu)!.status, AdminLoanStatus.disetujui);
      expect(find.text('Detail Peminjaman Disetujui'), findsOneWidget);
      expect(find.text('Disetujui'), findsWidgets);
      expect(_btn('Setujui'), findsNothing);
      expect(
        find.textContaining('Peminjaman motor telah disetujui'),
        findsWidgets,
      );
    });

    testWidgets('Tolak mengubah status jadi Ditolak', (
      WidgetTester tester,
    ) async {
      final state = await openList(tester);

      await openLoanByBorrower(tester, 'Budi Santoso');
      await tapVisible(tester, _btn('Tolak'));

      expect(state.byId(_mobilMenunggu)!.status, AdminLoanStatus.ditolak);
      expect(find.text('Detail Peminjaman Ditolak'), findsOneWidget);
      expect(_btn('Setujui'), findsNothing);
    });
  });

  group('TEST 8: card Disetujui membuka Detail Peminjaman Disetujui', () {
    testWidgets('TEST 8: daftar -> card Disetujui -> detail disetujui', (
      WidgetTester tester,
    ) async {
      await openList(tester);

      await openLoanByBorrower(tester, 'Prabowo');

      expect(find.byType(AdminLoanDetailPage), findsOneWidget);
      expect(find.text('Detail Peminjaman Disetujui'), findsOneWidget);
      // Tidak ada tombol persetujuan lagi.
      expect(_btn('Setujui'), findsNothing);
      expect(_btn('Tolak'), findsNothing);
      // Mobil menampilkan driver yang sudah ditetapkan.
      expect(find.text('Andi Pratama'), findsOneWidget);
    });

    testWidgets('motor disetujui tidak menampilkan driver', (
      WidgetTester tester,
    ) async {
      await openList(tester);
      await openLoanByBorrower(tester, 'Ucup Markucup');

      expect(find.text('Detail Peminjaman Disetujui'), findsOneWidget);
      expect(find.text('Driver'), findsNothing);
      expect(_btn('Ganti Driver'), findsNothing);
    });
  });

  group('TEST 9: tombol back', () {
    testWidgets('TEST 9: daftar -> detail -> driver -> detail -> daftar', (
      WidgetTester tester,
    ) async {
      await openList(tester);

      // Daftar -> Detail Mobil
      await openLoanByBorrower(tester, 'Budi Santoso');
      expect(find.byType(AdminLoanDetailPage), findsOneWidget);

      // Detail -> Driver -> kembali
      await tapVisible(tester, _btn('Ganti Driver'));
      expect(find.byType(AdminDriverConfirmPage), findsOneWidget);
      await tester.tap(find.byTooltip('Kembali'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminDriverConfirmPage), findsNothing);
      expect(find.byType(AdminLoanDetailPage), findsOneWidget);

      // Detail -> Daftar
      await tester.tap(find.byTooltip('Kembali'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoanDetailPage), findsNothing);
      expect(find.byType(AdminLoanListPage), findsOneWidget);
    });

    testWidgets('TEST 9: back dari daftar ke Beranda Admin', (
      WidgetTester tester,
    ) async {
      await bootShell(tester);
      await tester.tap(find.text('Peminjaman Mobil'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoanListPage), findsOneWidget);

      await tester.tap(find.byTooltip('Kembali'));
      await tester.pumpAndSettle();

      expect(find.byType(AdminLoanListPage), findsNothing);
      expect(find.byType(AdminHomePage), findsOneWidget);
    });
  });

  group('TEST 10: navbar tetap bisa dipakai di semua halaman', () {
    const labels = [
        'Beranda',
        'Kendaraan',
        'Notifikasi',
        'Profil',
      ];

    Future<void> openDetailMobil(WidgetTester tester) async {
      await openList(tester);
      await openLoanByBorrower(tester, 'Budi Santoso');
    }

    testWidgets('TEST 10: navbar aktif di Beranda dan tetap bisa ditekan', (
      WidgetTester tester,
    ) async {
      // Daftar peminjaman dibuka dari Beranda, jadi tab Beranda yang aktif.
      await openList(tester);
      expect(find.byType(AdminBottomNavigation), findsOneWidget);
      expect(_selected(tester), AdminShellPage.indexBeranda);
    });

    testWidgets('TEST 10: navbar tidak terkunci di halaman detail', (
      WidgetTester tester,
    ) async {
      await openDetailMobil(tester);

      // Navbar tetap ada di halaman detail.
      expect(find.byType(AdminBottomNavigation), findsOneWidget);
      for (final label in labels) {
        expect(find.text(label), findsWidgets, reason: '$label harus ada');
      }
    });

    testWidgets('TEST 10: dari detail, navbar membuka tab yang benar', (
      WidgetTester tester,
    ) async {
      await openDetailMobil(tester);
      await tester.tap(_nav('Profil'));
      await tester.pumpAndSettle();

      expect(find.byType(AdminLoanDetailPage), findsNothing);
      expect(_selected(tester), AdminShellPage.indexProfil);
      expect(find.text('Administrator'), findsWidgets);

      await tester.tap(_nav('Beranda'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminHomePage), findsOneWidget);
      expect(_selected(tester), AdminShellPage.indexBeranda);
    });

    testWidgets('TEST 10: navbar tidak terkunci di halaman driver', (
      WidgetTester tester,
    ) async {
      await openDetailMobil(tester);
      await tapVisible(tester, _btn('Ganti Driver'));

      expect(find.byType(AdminBottomNavigation), findsOneWidget);
      await tester.tap(_nav('Beranda'));
      await tester.pumpAndSettle();

      expect(find.byType(AdminDriverConfirmPage), findsNothing);
      expect(find.byType(AdminHomePage), findsOneWidget);
    });
  });

  group('Konsistensi data antar halaman', () {
    testWidgets('status di daftar ikut berubah setelah disetujui di detail', (
      WidgetTester tester,
    ) async {
      final state = await openList(tester);
      expect(state.byId(_mobilMenunggu)!.status, AdminLoanStatus.menunggu);

      await openLoanByBorrower(tester, 'Budi Santoso');
      await tapVisible(tester, _btn('Setujui'));

      // Kembali ke daftar, badge card ikut berubah.
      await tester.tap(find.byTooltip('Kembali'));
      await tester.pumpAndSettle();

      final card = find.ancestor(
        of: find.text('Budi Santoso'),
        matching: find.byType(AdminLoanCard),
      );
      expect(
        find.descendant(of: card, matching: find.text('Disetujui')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.text('Menunggu')),
        findsNothing,
      );
    });

    testWidgets('data driver tidak hilang saat berpindah halaman', (
      WidgetTester tester,
    ) async {
      final state = await openList(tester);

      await openLoanByBorrower(tester, 'Budi Santoso');
      await tapVisible(tester, _btn('Ganti Driver'));
      await tapVisible(tester, _driverButton('DRV-004'));
      await tester.pumpAndSettle();
      await tapVisible(tester, _confirmButton());

      // Keluar lagi ke driver, pilihan masih apa yang dikonfirmasi.
      await tapVisible(tester, _btn('Ganti Driver'));
      expect(find.text('Angga Yuan'), findsWidgets);
      expect(state.byId(_mobilMenunggu)!.driverId, 'DRV-004');
    });
  });

  group('Model driver', () {
    test('struktur dan status sesuai kebutuhan backend', () {
      final andi = driverById('DRV-001')!;
      expect(andi.name, 'Andi Pratama');
      expect(andi.status, DriverStatus.available);
      expect(andi.isSelectable, isTrue);

      final rizki = driverById('DRV-005')!;
      expect(rizki.status, DriverStatus.busy);
      expect(rizki.isSelectable, isFalse);
      expect(rizki.status.label, 'Sedang Bertugas');
    });

    test('mobil punya driver default sesuai kode kendaraan', () {
      // KDN-001 (Toyota Innova) -> DRV-001 (Andi Pratama).
      const innova = Vehicle(
        name: 'Toyota Innova',
        code: 'KDN-001',
        plateNumber: 'AB 123 XX',
        type: VehicleType.mobil,
        status: VehicleStatus.tersedia,
        imageAsset: 'assets/img/mobil.png',
        capacity: 7,
      );
      final driver = defaultDriverFor(innova, drivers: dummyDrivers);
      expect(driver, isNotNull);
      expect(driver!.name, 'Andi Pratama');

      // Kendaraan tanpa driver default menghasilkan null.
      const tanpaDefault = Vehicle(
        name: 'Bus',
        code: 'KDN-999',
        plateNumber: 'AB 999 XX',
        type: VehicleType.mobil,
        status: VehicleStatus.tersedia,
        imageAsset: 'assets/img/mobil.png',
      );
      expect(defaultDriverFor(tanpaDefault, drivers: dummyDrivers), isNull);
    });
  });

  group('Responsif', () {
    testWidgets('tidak ada overflow di semua halaman fitur baru', (
      WidgetTester tester,
    ) async {
      for (final size in const [
        Size(320, 480),
        Size(360, 640),
        Size(393, 852),
      ]) {
        await tester.binding.setSurfaceSize(size);
        final state = await openList(tester);
        expect(tester.takeException(), isNull, reason: 'daftar $size');

        await openLoanByBorrower(tester, 'Budi Santoso');
        expect(tester.takeException(), isNull, reason: 'detail $size');

        await tapVisible(tester, _btn('Ganti Driver'));
        expect(
          tester.takeException(),
          isNull,
          reason: 'konfirmasi driver $size',
        );
        expect(state.byId(_mobilMenunggu)!.driverId, isNull);
      }
      await tester.binding.setSurfaceSize(null);
    });
  });
}