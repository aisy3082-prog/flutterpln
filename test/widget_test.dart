import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_plnmobile/main.dart';
import 'package:flutter_application_plnmobile/pages/home_page.dart';
import 'package:flutter_application_plnmobile/pages/login_page.dart';
import 'package:flutter_application_plnmobile/pages/register_page.dart';
import 'package:flutter_application_plnmobile/pages/vehicle_list_page.dart';
import 'package:flutter_application_plnmobile/pages/loan_application_page.dart';
import 'package:flutter_application_plnmobile/pages/queue_page.dart';
import 'package:flutter_application_plnmobile/pages/trip_detail_page.dart';
import 'package:flutter_application_plnmobile/pages/trip_completion_page.dart';
import 'package:flutter_application_plnmobile/pages/fuel_input_page.dart';
import 'package:flutter_application_plnmobile/pages/fuel_type_selection_page.dart';
import 'package:flutter_application_plnmobile/pages/history_page.dart';
import 'package:flutter_application_plnmobile/pages/approval_status_page.dart';
import 'package:flutter_application_plnmobile/pages/submission_status_page.dart';
import 'package:flutter_application_plnmobile/data/vehicle_data.dart';
import 'package:flutter_application_plnmobile/models/vehicle.dart';
import 'package:flutter_application_plnmobile/widgets/vehicle_card.dart';
import 'package:flutter_application_plnmobile/state/loan_state.dart';

void main() {
  testWidgets('shows the first onboarding screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('PLN Move'), findsOneWidget);
    expect(find.text('PT PLN (Persero)'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('tapping the logo-only onboarding opens the second slide', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byType(OnboardingFirstPage));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingSecondPage), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingFirstPage), findsOneWidget);
  });

  testWidgets('onboarding can reach login, register, and home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byType(OnboardingFirstPage));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Register'));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterPage), findsOneWidget);

    final registerFields = find.byType(TextFormField);
    await tester.enterText(registerFields.at(0), 'andi');
    await tester.enterText(registerFields.at(1), 'andi@example.com');
    await tester.enterText(registerFields.at(2), 'password123');
    await tester.enterText(registerFields.at(3), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);

    final loginFields = find.byType(TextFormField);
    await tester.enterText(loginFields.at(0), dummyEmail);
    await tester.enterText(loginFields.at(1), dummyPassword);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Halo, Andi Pratama'), findsOneWidget);
    expect(find.text('Ringkasan Kendaraan'), findsOneWidget);

    await tester.tap(find.text('Kendaraan'));
    await tester.pumpAndSettle();
    expect(find.byType(VehicleListPage), findsOneWidget);
  });

  testWidgets('Login validates empty email and password', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);
  });

  testWidgets('invalid dummy credentials stay on Login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byType(OnboardingFirstPage));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    final loginFields = find.byType(TextFormField);
    await tester.enterText(loginFields.at(0), dummyEmail);
    await tester.enterText(loginFields.at(1), 'wrong-password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Email atau password salah.'), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
  });

  testWidgets('auth and home remain responsive on Android portrait sizes', (
    WidgetTester tester,
  ) async {
    const sizes = [
      Size(320, 480),
      Size(360, 640),
      Size(393, 852),
      Size(412, 915),
    ];

    for (final size in sizes) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.byType(OnboardingFirstPage));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Login should fit at $size',
      );

      await tester.tap(find.widgetWithText(OutlinedButton, 'Register'));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Register should fit at $size',
      );

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      final loginFields = find.byType(TextFormField);
      await tester.enterText(loginFields.at(0), dummyEmail);
      await tester.enterText(loginFields.at(1), dummyPassword);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Home should fit at $size',
      );
    }

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('does not overflow on common Android portrait sizes', (
    WidgetTester tester,
  ) async {
    const sizes = [
      Size(320, 480),
      Size(360, 640),
      Size(393, 852),
      Size(412, 915),
    ];

    for (final size in sizes) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      expect(
        tester.takeException(),
        isNull,
        reason: 'Layout should fit at $size',
      );
      expect(
        tester.getCenter(find.byType(Image)).dx,
        closeTo(size.width / 2, 3),
        reason: 'The logo should remain horizontally centered at $size',
      );
    }

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('vehicle list search, filters, and detail navigation work', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      LoanStateScope(
        state: LoanState(),
        child: const MaterialApp(home: VehicleListPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daftar Kendaraan Dinas'), findsOneWidget);
    expect(find.byType(VehicleCard), findsAtLeastNWidgets(4));

    await tester.enterText(find.byType(TextField), 'KDN-001');
    await tester.pump();
    expect(find.byType(VehicleCard), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.text('Mobil'));
    await tester.pump();
    expect(find.byType(VehicleCard), findsNWidgets(3));

    await tester.tap(find.text('Motor'));
    await tester.pump();
    expect(find.byType(VehicleCard), findsNWidgets(3));

    await tester.tap(find.byTooltip('Filter status kendaraan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tersedia').last);
    await tester.pumpAndSettle();
    expect(find.byType(VehicleCard), findsOneWidget);

    await tester.tap(find.byType(VehicleCard).first);
    await tester.pumpAndSettle();
    expect(find.byType(LoanApplicationPage), findsOneWidget);
  });

  testWidgets('vehicle list remains responsive on Android portrait sizes', (
    WidgetTester tester,
  ) async {
    const sizes = [
      Size(320, 480),
      Size(360, 640),
      Size(393, 852),
      Size(412, 915),
    ];

    for (final size in sizes) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        LoanStateScope(
          state: LoanState(),
          child: const MaterialApp(home: VehicleListPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        isNull,
        reason: 'Vehicle list should fit at $size',
      );
    }

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('queue progress follows every loan status', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    final loanState = LoanState();
    await tester.pumpWidget(
      LoanStateScope(
        state: loanState,
        child: const MaterialApp(home: QueuePage()),
      ),
    );

    for (final status in LoanStatus.values) {
      loanState.setStatus(status);
      await tester.pump();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Status $status should fit',
      );
    }

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('Home request flow selects a vehicle and opens Antrean Saya', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    final loanState = LoanState();
    await tester.pumpWidget(
      LoanStateScope(
        state: loanState,
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ajukan Peminjaman'));
    await tester.pumpAndSettle();
    expect(find.byType(LoanApplicationPage), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<Vehicle>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Toyota Innova • KDN-001').last);
    await tester.pumpAndSettle();

    final submitButton = find.widgetWithText(
      ElevatedButton,
      'Ajukan Peminjaman',
    );
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.byType(QueuePage), findsOneWidget);
    expect(loanState.status, LoanStatus.pengajuan);
    expect(find.text('Menunggu persetujuan'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('active queue is accessible from Home activity row', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    await tester.pumpWidget(
      LoanStateScope(
        state: LoanState(),
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mobil - Avanza'));
    await tester.pumpAndSettle();

    expect(find.byType(QueuePage), findsOneWidget);
    expect(find.text('Driver'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.byTooltip('Hubungi driver'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('unavailable vehicle cannot open the loan form', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    await tester.pumpWidget(
      LoanStateScope(
        state: LoanState(),
        child: const MaterialApp(home: VehicleListPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Filter status kendaraan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Digunakan').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(VehicleCard).first);
    await tester.pumpAndSettle();

    expect(find.byType(VehicleListPage), findsOneWidget);
    expect(find.byType(LoanApplicationPage), findsNothing);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('active trip detail can continue to completion and BBM input', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    final loanState = LoanState();
    await tester.pumpWidget(
      LoanStateScope(
        state: loanState,
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    // Card Perjalanan Aktif di section "Aktivitas Saya" membuka detail.
    await tester.tap(find.text('Perjalanan\nAktif'));
    await tester.pumpAndSettle();
    expect(find.byType(TripDetailPage), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Selesai Perjalanan'));
    await tester.pumpAndSettle();
    expect(find.byType(TripCompletionPage), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan'));
    await tester.pumpAndSettle();
    expect(find.byType(FuelInputPage), findsOneWidget);

    await tester.tap(find.textContaining('Pertalite'));
    await tester.pumpAndSettle();
    expect(find.byType(FuelTypeSelectionPage), findsOneWidget);
    await tester.tap(find.text('Pertamax'));
    await tester.pumpAndSettle();
    expect(find.byType(FuelInputPage), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan'));
    await tester.pumpAndSettle();
    expect(find.byType(QueuePage), findsOneWidget);
    expect(loanState.status, LoanStatus.selesai);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('history page supports perjalanan and energi tabs', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    await tester.pumpWidget(
      LoanStateScope(
        state: LoanState(),
        child: const MaterialApp(home: HistoryPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Riwayat Kendaraan'), findsOneWidget);
    expect(find.text('Perjalanan'), findsNWidgets(2));
    expect(find.text('Energi'), findsOneWidget);
    expect(find.text('Riwayat Perjalanan'), findsOneWidget);

    await tester.tap(find.text('Energi'));
    await tester.pumpAndSettle();
    expect(find.text('BBM'), findsAtLeastNWidgets(1));
    expect(find.text('Listrik'), findsOneWidget);
    expect(find.text('Informasi Pengisian'), findsAtLeastNWidgets(1));
    expect(find.text('Jumlah Liter'), findsAtLeastNWidgets(1));
    expect(find.text('Bukti Pengisian'), findsOneWidget);

    await tester.tap(find.text('Listrik'));
    await tester.pumpAndSettle();
    expect(find.text('Informasi Pengisian Listrik'), findsOneWidget);
    expect(find.text('Jumlah Energi'), findsAtLeastNWidgets(1));
    expect(find.text('Lokasi Pengisian'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('status pages show data when requests exist', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ApprovalStatusPage()));
    await tester.pumpAndSettle();
    expect(find.text('Menunggu Persetujuan'), findsWidgets);
    expect(find.text('Tidak ada persetujuan'), findsNothing);

    await tester.pumpWidget(const MaterialApp(home: SubmissionStatusPage()));
    await tester.pumpAndSettle();
    expect(find.text('Tidak ada pengajuan'), findsNothing);
    expect(find.text('PNG-2026-0042'), findsOneWidget);
  });

  testWidgets('Antrean Saya shows empty state when no active submission', (
    WidgetTester tester,
  ) async {
    final loanState = LoanState()..setStatus(LoanStatus.selesai);
    await tester.pumpWidget(
      LoanStateScope(
        state: loanState,
        child: const MaterialApp(home: QueuePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tidak ada pengajuan'), findsOneWidget);
  });

  testWidgets('Home history and status shortcuts navigate correctly', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    await tester.pumpWidget(
      LoanStateScope(
        state: LoanState(),
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryPage), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Menunggu\nPersetujuan'));
    await tester.pumpAndSettle();
    expect(find.byType(ApprovalStatusPage), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Perjalanan\nAktif'));
    await tester.pumpAndSettle();
    expect(find.byType(TripDetailPage), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pengajuan\nAktif'));
    await tester.pumpAndSettle();
    expect(find.byType(SubmissionStatusPage), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // Baris "Aktivitas Terakhir" jadi pintu masuk Antrean Saya.
    await tester.tap(find.text('Mobil - Avanza'));
    await tester.pumpAndSettle();
    expect(find.byType(QueuePage), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('history and status pages remain responsive', (
    WidgetTester tester,
  ) async {
    const sizes = [Size(320, 480), Size(393, 852)];

    for (final size in sizes) {
      await tester.binding.setSurfaceSize(size);
      for (final page in <Widget>[
        const ApprovalStatusPage(),
        const SubmissionStatusPage(),
      ]) {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(MaterialApp(home: page));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        LoanStateScope(
          state: LoanState(),
          child: const MaterialApp(home: HistoryPage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('loan flow pages remain responsive on Android portrait sizes', (
    WidgetTester tester,
  ) async {
    const sizes = [Size(320, 480), Size(393, 852)];
    final vehicle = dummyVehicles.first;

    for (final size in sizes) {
      await tester.binding.setSurfaceSize(size);
      for (final page in <Widget>[
        const LoanApplicationPage(),
        const QueuePage(),
        TripDetailPage(vehicle: vehicle),
        TripCompletionPage(vehicle: vehicle),
        FuelInputPage(vehicle: vehicle),
        const FuelTypeSelectionPage(selectedFuel: 'Pertalite'),
      ]) {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(
          LoanStateScope(
            state: LoanState(),
            child: MaterialApp(home: page),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${page.runtimeType} should fit at $size',
        );
      }
    }

    await tester.binding.setSurfaceSize(null);
  });
}
