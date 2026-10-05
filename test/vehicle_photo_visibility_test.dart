import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_plnmobile/data/admin_vehicle_data.dart';
import 'package:flutter_application_plnmobile/data/vehicle_loan_data.dart';
import 'package:flutter_application_plnmobile/widgets/admin_loan_card.dart';
import 'package:flutter_application_plnmobile/widgets/vehicle_card.dart';
import 'package:flutter_application_plnmobile/widgets/vehicle_photo.dart';

/// Warna latar foto kendaraan. Foto bawaan berlatar putih, jadi tanpa
/// latar ini mobilnya nyaris tak terlihat di atas kartu putih.
const _backdrop = Color(0xFFF1F5F9);

Widget _host(Widget child) =>
    MaterialApp(home: Scaffold(backgroundColor: Colors.white, body: child));

/// Warna latar pada container yang membungkus [VehiclePhoto].
Color? _backdropOf(WidgetTester tester) {
  final container = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(VehiclePhoto),
          matching: find.byType(Container),
        )
        .first,
  );
  return (container.decoration as BoxDecoration?)?.color;
}

void main() {
  group('Foto kendaraan berb.latar putih tetap terlihat', () {
    testWidgets('VehiclePhoto memberi latar saat diminta', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          VehiclePhoto(
            vehicle: dummyAdminVehicles.first,
            width: 72,
            height: 64,
            backgroundColor: _backdrop,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_backdropOf(tester), _backdrop);
    });

    testWidgets('VehiclePhoto tetap polos bila latar tidak diminta', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(VehiclePhoto(vehicle: dummyAdminVehicles.first)),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(VehiclePhoto),
          matching: find.byType(Container),
        ),
        findsNothing,
      );
    });

    testWidgets('foto mobil dan motor memakai asset yang ada', (
      WidgetTester tester,
    ) async {
      // Aset wajib benar-benar dirujuk, kalau salah path foto tidak muncul.
      final paths = dummyAdminVehicles.map((v) => v.imageAsset).toSet();
      expect(paths, {'assets/img/mobil.png', 'assets/img/motor.jpeg'});

      for (final asset in paths) {
        expect(asset, startsWith('assets/img/'));
      }
    });
  });

  group('Kartu kendaraan memakai VehiclePhoto berlatar', () {
    testWidgets('VehicleCard user punya latar di belakang foto', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(VehicleCard(vehicle: dummyAdminVehicles.first, onTap: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.byType(VehiclePhoto), findsOneWidget);
      expect(_backdropOf(tester), _backdrop);
    });

    testWidgets('AdminLoanCard punya latar di belakang foto', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          AdminLoanCard(
            loan: dummyVehicleLoans.first,
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(VehiclePhoto), findsOneWidget);
      expect(_backdropOf(tester), _backdrop);
    });

    testWidgets('kartu mobil dan motor sama-sama punya latar', (
      WidgetTester tester,
    ) async {
      for (final vehicle in dummyAdminVehicles) {
        await tester.pumpWidget(
          _host(VehicleCard(vehicle: vehicle, onTap: () {})),
        );
        await tester.pumpAndSettle();

        expect(
          _backdropOf(tester),
          _backdrop,
          reason: '${vehicle.name} harus punya latar',
        );
      }
    });
  });

  group('Semua kartu memuat foto yang benar', () {
    testWidgets('kartu loan memakai foto kendaraan yang sesuai', (
      WidgetTester tester,
    ) async {
      for (final loan in dummyVehicleLoans) {
        await tester.pumpWidget(
          _host(AdminLoanCard(loan: loan, onTap: () {})),
        );
        await tester.pumpAndSettle();

        final image = tester.widget<Image>(
          find.descendant(
            of: find.byType(VehiclePhoto),
            matching: find.byType(Image),
          ),
        );
        expect((image.image as AssetImage).assetName, loan.vehicle.imageAsset);
      }
    });

    testWidgets('VehiclePhoto memuat Image.asset saat belum ada foto unggah', (
      WidgetTester tester,
    ) async {
      final vehicle = dummyAdminVehicles.first;
      expect(vehicle.photoPath, isNull);

      await tester.pumpWidget(_host(VehiclePhoto(vehicle: vehicle)));
      await tester.pumpAndSettle();

      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName, vehicle.imageAsset);
    });
  });

  group('Ukuran foto tidak berubah', () {
    testWidgets('VehiclePhoto menghormati width dan height', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          VehiclePhoto(
            vehicle: dummyAdminVehicles.first,
            width: 72,
            height: 64,
            backgroundColor: _backdrop,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final size = tester.getSize(find.byType(VehiclePhoto));
      expect(size.width, 72);
      expect(size.height, 64);
    });
  });
}