import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_plnmobile/data/vehicle_loan_data.dart';
import 'package:flutter_application_plnmobile/main.dart';
import 'package:flutter_application_plnmobile/models/admin_dashboard.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_home_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_login_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_loan_detail_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_loan_list_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_navigation.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_notification_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_profile_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_vehicle_page.dart';
import 'package:flutter_application_plnmobile/pages/login_page.dart';
import 'package:flutter_application_plnmobile/widgets/admin_bottom_navigation.dart';
import 'package:flutter_application_plnmobile/widgets/admin_loan_card.dart';

Finder _nav(String label) => find.byKey(ValueKey('admin_bottom_nav_$label'));
Finder _field() => find.byType(TextField);

/// Teks yang hanya dihitung di dalam card, supaya tidak ikut menghitung
/// teks yang diketik di search bar.
Finder _cardText(String text) => find.descendant(
  of: find.byType(AdminLoanCard),
  matching: find.text(text),
);

/// Login Admin lalu sampai di Beranda Admin.
Future<void> _loginToAdminHome(WidgetTester tester) async {
  // Reset supaya iterasi sebelumnya tidak meninggalkan halaman lain.
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(const MyApp());
  await tester.tap(find.byType(OnboardingFirstPage));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();

  // Masuk ke area Admin.
  final entry = find.text('Masuk sebagai Admin');
  await tester.ensureVisible(entry);
  await tester.pumpAndSettle();
  await tester.tap(entry);
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextFormField).at(0), dummyAdminEmail);
  await tester.enterText(find.byType(TextFormField).at(1), dummyAdminPassword);
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle(const Duration(milliseconds: 400));

  expect(find.byType(AdminHomePage), findsOneWidget);
}

/// Buka halaman daftar lewat tombol "Lihat Semua" di Beranda Admin.
Future<void> _openList(WidgetTester tester) async {
  await _loginToAdminHome(tester);
  final link = find.text('Lihat Semua');
  await tester.ensureVisible(link);
  await tester.pumpAndSettle();
  await tester.tap(link);
  await tester.pumpAndSettle();
}

int _selected(WidgetTester tester) => tester
    .widget<AdminBottomNavigation>(find.byType(AdminBottomNavigation))
    .selectedIndex;

void main() {
  group('Alur: Beranda Admin -> Lihat Semua -> Daftar', () {
    testWidgets('tombol Lihat Semua membuka Daftar Peminjaman Terbaru', (
      WidgetTester tester,
    ) async {
      await _openList(tester);

      expect(find.byType(AdminLoanListPage), findsOneWidget);
      expect(find.text('Daftar Peminjaman Terbaru'), findsOneWidget);
      // Beranda Admin masih ada di stack, hanya offstage karena tertutup daftar.
      expect(
        find.byType(AdminHomePage, skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('tombol back kembali ke Beranda Admin', (
      WidgetTester tester,
    ) async {
      await _openList(tester);
      expect(find.byType(AdminLoanListPage), findsOneWidget);

      await tester.tap(find.byTooltip('Kembali'));
      await tester.pumpAndSettle();

      expect(find.byType(AdminLoanListPage), findsNothing);
      expect(find.byType(AdminHomePage), findsOneWidget);
      expect(find.text('Peminjaman Terbaru'), findsOneWidget);
    });
  });

  group('Header dan search bar', () {
    testWidgets('judul, tombol back, dan search bar tampil', (
      WidgetTester tester,
    ) async {
      await _openList(tester);

      expect(find.text('Daftar Peminjaman Platinum'), findsNothing);
      expect(find.text('Daftar Peminjaman Terbaru'), findsOneWidget);
      expect(find.byTooltip('Kembali'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      expect(find.widgetWithText(TextField, 'Cari Kendaraan....'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('header tidak terlalu tinggi', (WidgetTester tester) async {
      await _openList(tester);
      final appBar = tester.getRect(find.byType(AppBar));
      expect(appBar.height, lessThanOrEqualTo(60));
    });
  });

  group('Filter Semua / Mobil / Motor', () {
    testWidgets('default Semua menampilkan 4 card', (
      WidgetTester tester,
    ) async {
      await _openList(tester);
      expect(find.byType(AdminLoanCard), findsNWidgets(4));
    });

    testWidgets('filter Mobil hanya mobil, filter Motor hanya motor', (
      WidgetTester tester,
    ) async {
      await _openList(tester);

      await tester.tap(find.widgetWithText(InkWell, 'Mobil'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoanCard), findsNWidgets(2));
      expect(_cardText('Toyota Innova'), findsNWidgets(2));
      expect(_cardText('Lifan'), findsNothing);

      await tester.tap(find.widgetWithText(InkWell, 'Motor'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoanCard), findsNWidgets(2));
      expect(_cardText('Lifan'), findsNWidgets(2));
      expect(_cardText('Toyota Innova'), findsNothing);

      await tester.tap(find.widgetWithText(InkWell, 'Semua'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoanCard), findsNWidgets(4));
    });

    testWidgets('tampilan tombol filter aktif dan non-aktif', (
      WidgetTester tester,
    ) async {
      await _openList(tester);

      Finder buttonFor(String label) => find.ancestor(
        of: find.text(label),
        matching: find.byType(Ink),
      );

      // Default: Semua aktif (biru) dan dua lainnya non-aktif.
      expect(
        tester.widget<Ink>(buttonFor('Semua').first).decoration,
        isA<BoxDecoration>().having(
          (d) => d.color,
          'color',
          const Color(0xFF0B75D1),
        ),
      );
      expect(
        tester.widget<Ink>(buttonFor('Mobil').first).decoration,
        isA<BoxDecoration>().having((d) => d.color, 'color', Colors.white),
      );

      await tester.tap(find.widgetWithText(InkWell, 'Motor'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<Ink>(buttonFor('Motor').first).decoration,
        isA<BoxDecoration>().having(
          (d) => d.color,
          'color',
          const Color(0xFF0B75D1),
        ),
      );
      expect(
        tester.widget<Ink>(buttonFor('Semua').first).decoration,
        isA<BoxDecoration>().having((d) => d.color, 'color', Colors.white),
      );
    });

    testWidgets('filter dan search bisa dipakai bersamaan', (
      WidgetTester tester,
    ) async {
      await _openList(tester);

      await tester.tap(find.widgetWithText(InkWell, 'Mobil'));
      await tester.pumpAndSettle();
      await tester.enterText(_field(), 'Prabowo');
      await tester.pumpAndSettle();

      expect(find.byType(AdminLoanCard), findsOneWidget);
      expect(_cardText('Prabowo'), findsOneWidget);
    });
  });

  group('Search', () {
    testWidgets('mencari berdasarkan nama kendaraan', (
      WidgetTester tester,
    ) async {
      await _openList(tester);

      await tester.enterText(_field(), 'Lifan');
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoanCard), findsNWidgets(2));
      expect(_cardText('Lifan'), findsNWidgets(2));

      await tester.enterText(_field(), 'Toyota');
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoanCard), findsNWidgets(2));
      expect(_cardText('Toyota Innova'), findsNWidgets(2));
    });

    testWidgets('mencari berdasarkan kode dan plat nomor', (
      WidgetTester tester,
    ) async {
      await _openList(tester);

      await tester.enterText(_field(), 'KDN-001');
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoanCard), findsNWidgets(2));

      await tester.enterText(_field(), 'AB 123');
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoanCard), findsNWidgets(4));
    });

    testWidgets('mencari berdasarkan nama peminjam', (
      WidgetTester tester,
    ) async {
      await _openList(tester);

      await tester.enterText(_field(), 'Siti');
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoanCard), findsOneWidget);
      expect(_cardText('Siti Aminah'), findsOneWidget);
    });

    testWidgets('pencarian tidak error dan bisa dikosongkan lagi', (
      WidgetTester tester,
    ) async {
      await _openList(tester);

      await tester.enterText(_field(), 'zzzz tidak ada');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(AdminLoanCard), findsNothing);

      await tester.enterText(_field(), '');
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoanCard), findsNWidgets(4));
    });

    testWidgets('empty state tampil saat tidak ada hasil', (
      WidgetTester tester,
    ) async {
      await _openList(tester);

      await tester.enterText(_field(), 'tidak ada kendaraan ini');
      await tester.pumpAndSettle();

      expect(find.text('Data peminjaman tidak ditemukan'), findsOneWidget);
      expect(find.byType(AdminLoanCard), findsNothing);
    });
  });

  group('Card peminjaman', () {
    testWidgets('isi card lengkap sesuai desain', (
      WidgetTester tester,
    ) async {
      await _openList(tester);

      // Card pertama: Toyota Innova / Budi Santoso / Menunggu.
      expect(_cardText('Toyota Innova'), findsNWidgets(2));
      expect(_cardText('Budi Santoso'), findsOneWidget);
      expect(_cardText('Kapasitas 7 orang'), findsNWidgets(2));
      expect(_cardText('Kapasitas 2 orang'), findsNWidgets(2));
      expect(_cardText('KDN-001    AB 123 XX'), findsNWidgets(2));
      expect(_cardText('14 Sep 2026, 08:00'), findsOneWidget);
      expect(_cardText('13 Sep 2026, 08:00'), findsOneWidget);
      expect(_cardText('Menunggu'), findsNWidgets(2));
      expect(_cardText('Disetujui'), findsNWidgets(2));
      // Ikon peminjam, kalender, dan chevron ada di setiap card.
      expect(
        find.descendant(
          of: find.byType(AdminLoanCard),
          matching: find.byIcon(Icons.person_outline),
        ),
        findsNWidgets(4),
      );
      expect(
        find.descendant(
          of: find.byType(AdminLoanCard),
          matching: find.byIcon(Icons.calendar_today_outlined),
        ),
        findsNWidgets(4),
      );
      expect(
        find.descendant(
          of: find.byType(AdminLoanCard),
          matching: find.byIcon(Icons.chevron_right),
        ),
        findsNWidgets(4),
      );
    });

    testWidgets('gambar kendaraan tampil', (WidgetTester tester) async {
      await _openList(tester);
      expect(find.byType(Image), findsNWidgets(4));
      expect(tester.takeException(), isNull);
    });

    testWidgets('badge Menunggu biru muda dan Disetujui hijau muda', (
      WidgetTester tester,
    ) async {
      await _openList(tester);

      Color pillFor(String label) {
        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.ancestor(
                  of: find.text(label),
                  matching: find.byType(AdminLoanStatusBadge),
                ),
                matching: find.byType(Container),
              )
              .first,
        );
        final color = (container.decoration! as BoxDecoration).color;
        expect(color, isNotNull);
        return color!;
      }

      expect(pillFor('Menunggu'), const Color(0xFFDDE9FB));
      expect(pillFor('Disetujui'), const Color(0xFFB8F0C0));
    });

    testWidgets('tiap card bisa ditekan dan membuka Detail Peminjaman', (
      WidgetTester tester,
    ) async {
      await _openList(tester);

      await tester.tap(find.byType(AdminLoanCard).at(1));
      await tester.pumpAndSettle();

      expect(find.byType(AdminLoanDetailPage), findsOneWidget);
      expect(find.text('Detail Peminjaman Motor'), findsOneWidget);
      // Card kedua = Lifan / Siti Aminah.
      expect(find.text('Siti Aminah'), findsWidgets);
    });

    testWidgets('detail menampilkan data lalu bisa kembali ke daftar', (
      WidgetTester tester,
    ) async {
      await _openList(tester);
      await tester.tap(find.byType(AdminLoanCard).first);
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoanDetailPage), findsOneWidget);

      await tester.tap(find.byTooltip('Kembali'));
      await tester.pumpAndSettle();

      expect(find.byType(AdminLoanDetailPage), findsNothing);
      expect(find.byType(AdminLoanListPage), findsOneWidget);
    });

    testWidgets('chevron di card juga bisa ditekan', (
      WidgetTester tester,
    ) async {
      await _openList(tester);

      final chevron = find
          .descendant(
            of: find.byType(AdminLoanCard).first,
            matching: find.byIcon(Icons.chevron_right),
          );
      await tester.tap(chevron);
      await tester.pumpAndSettle();

      expect(find.byType(AdminLoanDetailPage), findsOneWidget);
    });
  });

  group('Bottom Navigation dari halaman daftar', () {
    testWidgets('navbar tetap ada dan aktif di Beranda', (
      WidgetTester tester,
    ) async {
      await _openList(tester);

      expect(find.byType(AdminBottomNavigation), findsOneWidget);
      expect(_selected(tester), AdminShellPage.indexBeranda);
    });

    testWidgets('setiap tombol navbar membuka tab yang benar', (
      WidgetTester tester,
    ) async {
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

      for (final target in const [1, 2, 3, 0]) {
        await _openList(tester);
        expect(find.byType(AdminLoanListPage), findsOneWidget);

        await tester.tap(_nav(labels[target]));
        await tester.pumpAndSettle();

        // Pindah tab membersihkan stack, jadi halaman yang pushed (daftar
        // dengan navbar sendiri) sudah tidak ada sebagai route terpisah.
        expect(
          find.byType(AdminBottomNavigation),
          findsOneWidget,
          reason: 'hanya boleh ada satu navbar',
        );
        expect(_selected(tester), target, reason: 'harus di ${labels[target]}');
        expect(
          find.byType(pages[target]!, skipOffstage: true),
          findsOneWidget,
          reason: 'harus menampilkan ${labels[target]}',
        );
      }
    });
  });

  group('Perjalanan berpindah', () {
    testWidgets('Beranda -> Daftar -> Profil -> Beranda -> Daftar', (
      WidgetTester tester,
    ) async {
      await _loginToAdminHome(tester);

      // Beranda -> Daftar
      await tester.tap(find.text('Lihat Semua'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoanListPage), findsOneWidget);

      // Daftar -> Profil
      await tester.tap(_nav('Profil'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminProfilePage), findsOneWidget);

      // Profil -> Beranda
      await tester.tap(_nav('Beranda'));
      await tester.pumpAndSettle();
      expect(find.text('Peminjaman Terbaru'), findsOneWidget);

      // Beranda -> Daftar lagi
      await tester.ensureVisible(find.text('Lihat Semua'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lihat Semua'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoanListPage), findsOneWidget);
      expect(find.byType(AdminLoanCard), findsNWidgets(4));
    });

    testWidgets('Daftar -> back -> Daftar -> back -> Beranda', (
      WidgetTester tester,
    ) async {
      await _loginToAdminHome(tester);

      for (var i = 0; i < 2; i++) {
        await tester.ensureVisible(find.text('Lihat Semua'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Lihat Semua'));
        await tester.pumpAndSettle();
        expect(find.byType(AdminLoanListPage), findsOneWidget);

        await tester.tap(find.byTooltip('Kembali'));
        await tester.pumpAndSettle();
        expect(find.byType(AdminLoanListPage), findsNothing);
      }
      expect(find.byType(AdminHomePage), findsOneWidget);
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
        await _openList(tester);
        expect(
          tester.takeException(),
          isNull,
          reason: 'daftar harus muat di $size',
        );

        // Cek juga saat filter dan search aktif.
        await tester.tap(find.widgetWithText(InkWell, 'Motor'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.enterText(_field(), 'Lifan');
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Dan di halaman detail.
        await tester.tap(find.byType(AdminLoanCard).first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('search bar dan tombol filter tidak keluar layar', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 480));
      await _openList(tester);

      expect(tester.getRect(_field()).right, lessThanOrEqualTo(320));
      for (final label in ['Semua', 'Mobil', 'Motor']) {
        expect(
          tester.getRect(find.text(label)).right,
          lessThanOrEqualTo(320),
          reason: '$label harus di dalam layar',
        );
      }
      // Search bar dan navbar tidak saling tumpang tindih.
      expect(
        tester.getRect(_field()).bottom,
        lessThan(
          tester.getRect(find.byType(AdminBottomNavigation)).top,
        ),
      );
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('daftar bisa di-scroll', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 700));
      await _openList(tester);

      expect(find.text('Ucup Markucup'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, -250));
      await tester.pumpAndSettle();
      // Card terakhir tetap bisa dijangkau.
      expect(find.byType(AdminLoanCard), findsNWidgets(4));
      expect(tester.takeException(), isNull);
      await tester.binding.setSurfaceSize(null);
    });
  });

  group('Model peminjaman', () {
    test('pencarian dan field lengkap sesuai kebutuhan backend', () {
      final loan = dummyVehicleLoans.first;

      expect(loan.id, 'PLN-2026-0001');
      expect(loan.vehicleName, 'Toyota Innova');
      expect(loan.vehicleType.name, 'mobil');
      expect(loan.vehicle.code, 'KDN-001');
      expect(loan.vehicle.plateNumber, 'AB 123 XX');
      expect(loan.vehicle.capacity, 7);
      expect(loan.vehicle.imageAsset, isNotEmpty);
      expect(loan.borrowerName, 'Budi Santoso');
      expect(loan.borrowerPhone, '085xxxxxxxx');
      expect(loan.startDate, '14 Sep 2026');
      expect(loan.startTime, '08:00');
      expect(loan.returnDate, '14 Sep 2026');
      expect(loan.returnTime, '16:00');
      expect(loan.destination, 'Batik, kuliner magelang');
      expect(loan.driverId, isNull);
      expect(loan.status, AdminLoanStatus.menunggu);
      expect(loan.dateTime, '14 Sep 2026, 08:00');
      expect(loan.returnDateTime, '14 Sep 2026, 16:00');
      expect(loan.scheduleLabel, '14 Sep 2026, 08:00 - 16:00');

      expect(loan.matches('innova'), isTrue);
      expect(loan.matches('KDN-001'), isTrue);
      expect(loan.matches('AB 123'), isTrue);
      expect(loan.matches('budi'), isTrue);
      expect(loan.matches('lifan'), isFalse);
      expect(loan.matches('   '), isTrue);
    });
  });

  group('Halaman user tidak terganggu', () {
    testWidgets('Login user tetap tanpa tombol Admin', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.byType(OnboardingFirstPage));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(AdminLoanListPage), findsNothing);
    });
  });
}
