import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_plnmobile/data/admin_vehicle_data.dart';
import 'package:flutter_application_plnmobile/data/vehicle_maintenance_data.dart';
import 'package:flutter_application_plnmobile/models/vehicle.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_vehicle_detail_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_vehicle_edit_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_vehicle_page.dart';
import 'package:flutter_application_plnmobile/state/admin_notification_state.dart';
import 'package:flutter_application_plnmobile/state/admin_vehicle_state.dart';
import 'package:flutter_application_plnmobile/widgets/admin_header_actions.dart';

Future<AdminVehicleState> bootDetail(
  WidgetTester tester,
  String code,
) async {
  await tester.pumpWidget(const SizedBox.shrink());
  final state = AdminVehicleState(vehicles: dummyAdminVehicles);
  await tester.pumpWidget(
    AdminNotificationStateScope(
      state: AdminNotificationState(),
      child: AdminVehicleStateScope(
        state: state,
        child: MaterialApp(home: AdminVehicleDetailPage(vehicleCode: code)),
      ),
      ),
  );
  await tester.pumpAndSettle();
  return state;
}

Future<AdminVehicleState> bootEdit(
  WidgetTester tester,
  String code,
) async {
  await tester.pumpWidget(const SizedBox.shrink());
  final state = AdminVehicleState(vehicles: dummyAdminVehicles);
  await tester.pumpWidget(
    AdminNotificationStateScope(
      state: AdminNotificationState(),
      child: AdminVehicleStateScope(
        state: state,
        child: MaterialApp(home: AdminVehicleEditPage(vehicleCode: code)),
      ),
      ),
  );
  await tester.pumpAndSettle();
  return state;
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

void main() {
  group('Detail Kendaraan', () {
    testWidgets('menampilkan header, ringkasan, dan info singkat', (
      WidgetTester tester,
    ) async {
      final state = await bootDetail(tester, 'KDN-001');
      addTearDown(state.dispose);

      expect(find.text('Detail Kendaraan'), findsOneWidget);
      expect(find.byTooltip('Kembali'), findsOneWidget);
      // Bagian kanan header standar.
      expect(find.byType(AdminHeaderActions), findsOneWidget);
      expect(find.byTooltip('Notifikasi'), findsOneWidget);

      // Ringkasan kendaraan.
      expect(find.text('Toyota Innova'), findsWidgets);
      expect(find.text('KDN-001    AB 123 XX'), findsOneWidget);
      expect(find.text('Tersedia'), findsOneWidget);
    });

    testWidgets('tiga info singkat sesuai desain', (
      WidgetTester tester,
    ) async {
      final state = await bootDetail(tester, 'KDN-001');
      addTearDown(state.dispose);

      expect(find.text('Bensin'), findsOneWidget);
      expect(find.text('7 Seat'), findsOneWidget);
      expect(find.text('Tahun'), findsOneWidget);
      expect(find.text('2020'), findsOneWidget);
    });

    testWidgets('menampilkan Informasi Perawatan', (
      WidgetTester tester,
    ) async {
      final state = await bootDetail(tester, 'KDN-001');
      addTearDown(state.dispose);

      expect(find.text('Informasi Perawatan'), findsOneWidget);
      for (final item in maintenanceOf('KDN-001')) {
        expect(find.text(item.title), findsOneWidget);
        expect(find.text(item.date), findsOneWidget);
      }
      expect(find.text('Selesai'), findsNWidgets(3));
    });

    testWidgets('kendaraan tanpa riwayat menampilkan pesan kosong', (
      WidgetTester tester,
    ) async {
      final state = await bootDetail(tester, 'KDN-004');
      addTearDown(state.dispose);

      expect(find.text('Belum ada riwayat perawatan'), findsOneWidget);
    });

    testWidgets('tombol Edit Kendaraan ada', (WidgetTester tester) async {
      final state = await bootDetail(tester, 'KDN-001');
      addTearDown(state.dispose);

      expect(
        find.byKey(const ValueKey('admin_vehicle_edit_button')),
        findsOneWidget,
      );
      expect(find.text('Edit Kendaraan'), findsOneWidget);
    });

    testWidgets('halaman detail tidak punya bottom navigation', (
      WidgetTester tester,
    ) async {
      final state = await bootDetail(tester, 'KDN-001');
      addTearDown(state.dispose);

      // Sesuai desain: halaman detail tidak menampilkan navbar.
      expect(find.text('Kendaraan'), findsNothing);
      expect(find.text('Profil'), findsNothing);
    });
  });

  group('Alur Daftar -> Detail -> Edit', () {
    testWidgets('card -> detail -> Edit Kendaraan -> detail', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      final state = AdminVehicleState(vehicles: dummyAdminVehicles);
      addTearDown(state.dispose);
      await tester.pumpWidget(
        AdminNotificationStateScope(
          state: AdminNotificationState(),
          child: AdminVehicleStateScope(
            state: state,
            child: const MaterialApp(home: AdminVehiclePage()),
          ),
          ),
      );
      await tester.pumpAndSettle();

      // Daftar -> Detail
      await tapVisible(tester, find.byType(AdminVehicleCard).first);
      expect(find.byType(AdminVehicleDetailPage), findsOneWidget);

      // Detail -> Edit
      await tapVisible(
        tester,
        find.byKey(const ValueKey('admin_vehicle_edit_button')),
      );
      expect(find.byType(AdminVehicleEditPage), findsOneWidget);
      expect(find.text('Edit Kendaraan'), findsWidgets);

      // Edit -> kembali ke Detail
      await tapVisible(tester, find.byTooltip('Kembali'));
      expect(find.byType(AdminVehicleEditPage), findsNothing);
      expect(find.byType(AdminVehicleDetailPage), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });

  group('Edit Kendaraan', () {
    testWidgets('form terisi dari kendaraan yang dipilih', (
      WidgetTester tester,
    ) async {
      final state = await bootEdit(tester, 'KDN-002');
      addTearDown(state.dispose);

      final fields = find.byType(TextFormField);
      expect(fields, findsNWidgets(4));
      expect(
        tester.widget<TextFormField>(fields.at(0)).controller!.text,
        'Toyota Innova',
      );
      expect(
        tester.widget<TextFormField>(fields.at(1)).controller!.text,
        'AB 126 XX',
      );
      expect(
        tester.widget<TextFormField>(fields.at(2)).controller!.text,
        '7',
      );
      expect(
        tester.widget<TextFormField>(fields.at(3)).controller!.text,
        '2020',
      );

      // Ringkasan kendaraan di atas form.
      expect(find.text('Toyota Innova'), findsWidgets);
      expect(find.text('KDN-002    AB 126 XX'), findsOneWidget);
    });

    testWidgets('dropdown Kapasitas Mesin berfungsi', (
      WidgetTester tester,
    ) async {
      final state = await bootEdit(tester, 'KDN-001');
      addTearDown(state.dispose);

      final dropdown = find.byKey(
        const ValueKey('admin_engine_capacity_dropdown'),
      );
      expect(dropdown, findsOneWidget);

      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Untuk mobil, opsinya liter.
      expect(find.text('2.4 L').last, findsOneWidget);
      await tester.tap(find.text('2.4 L').last);
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<DropdownButton<String>>(dropdown)
            .value,
        '2.4 L',
      );
    });

    testWidgets('dropdown Kapasitas Mesin untuk motor memakai cc', (
      WidgetTester tester,
    ) async {
      final state = await bootEdit(tester, 'KDM-001');
      addTearDown(state.dispose);

      await tester.tap(
        find.byKey(const ValueKey('admin_engine_capacity_dropdown')),
      );
      await tester.pumpAndSettle();

      expect(find.text('110 cc').last, findsOneWidget);
      expect(find.text('2.4 L'), findsNothing);
    });

    testWidgets('status awal mengikuti kendaraan', (
      WidgetTester tester,
    ) async {
      final state = await bootEdit(tester, 'KDN-002');
      addTearDown(state.dispose);

      // KDN-002 berstatus Digunakan -> label "Tidak Tersedia" aktif.
      expect(
        find.descendant(
          of: find.byKey(
            const ValueKey('admin_vehicle_status_digunakan'),
          ),
          matching: find.byIcon(Icons.radio_button_checked),
        ),
        findsOneWidget,
      );
    });

    testWidgets('simpan menulis perubahan ke state', (
      WidgetTester tester,
    ) async {
      final state = await bootEdit(tester, 'KDN-001');
      addTearDown(state.dispose);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Toyota Fortuner');
      await tester.enterText(fields.at(1), 'B 2345 XX');
      await tester.enterText(fields.at(3), '2022');

      await tester.tap(
        find.byKey(const ValueKey('admin_vehicle_status_perawatan')),
      );
      await tester.pumpAndSettle();

      await tapVisible(
        tester,
        find.byKey(const ValueKey('admin_vehicle_save_button')),
      );

      final saved = state.byCode('KDN-001')!;
      expect(saved.name, 'Toyota Fortuner');
      expect(saved.plateNumber, 'B 2345 XX');
      expect(saved.productionYear, 2022);
      expect(saved.status, VehicleStatus.perawatan);
    });

    testWidgets('perubahan status terlihat di halaman detail', (
      WidgetTester tester,
    ) async {
      final state = await bootEdit(tester, 'KDN-001');
      addTearDown(state.dispose);

      await tester.tap(
        find.byKey(const ValueKey('admin_vehicle_status_perawatan')),
      );
      await tester.pumpAndSettle();
      await tapVisible(
        tester,
        find.byKey(const ValueKey('admin_vehicle_save_button')),
      );

      // Kembali ke detail untuk memastikan state terpakai.
      await tester.pumpWidget(
        AdminNotificationStateScope(
          state: AdminNotificationState(),
          child: AdminVehicleStateScope(
            state: state,
            child: const MaterialApp(
              home: AdminVehicleDetailPage(vehicleCode: 'KDN-001'),
            ),
          ),
          ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Perawatan'), findsWidgets);
    });

    testWidgets('batal tidak menyimpan perubahan', (
      WidgetTester tester,
    ) async {
      // Edit dibuka di atas Daftar Kendaraan supaya tombol Batal punya
      // halaman untuk kembali.
      final state = AdminVehicleState(vehicles: dummyAdminVehicles);
      addTearDown(state.dispose);
      await tester.pumpWidget(
        AdminNotificationStateScope(
          state: AdminNotificationState(),
          child: AdminVehicleStateScope(
            state: state,
            child: MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              const AdminVehicleEditPage(vehicleCode: 'KDN-001'),
                        ),
                      ),
                      child: const Text('Buka Edit'),
                    ),
                  ),
                ),
              ),
            ),
          ),
          ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buka Edit'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Tidak Boleh Masuk',
      );
      await tester.pumpAndSettle();

      await tapVisible(
        tester,
        find.byKey(const ValueKey('admin_vehicle_cancel_button')),
      );

      // Kembali ke halaman sebelumnya dan data tidak tersimpan.
      expect(find.byType(AdminVehicleEditPage), findsNothing);
      expect(find.text('Tidak Boleh Masuk'), findsNothing);
      expect(state.byCode('KDN-001')!.name, 'Toyota Innova');
    });

    testWidgets('kode dan jenis kendaraan tidak berubah saat edit', (
      WidgetTester tester,
    ) async {
      final state = await bootEdit(tester, 'KDN-001');
      addTearDown(state.dispose);

      final before = state.byCode('KDN-001')!;
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Nama Baru',
      );
      await tester.pumpAndSettle();
      await tapVisible(
        tester,
        find.byKey(const ValueKey('admin_vehicle_save_button')),
      );

      final after = state.byCode('KDN-001')!;
      expect(after.name, 'Nama Baru');
      expect(after.code, before.code);
      expect(after.type, before.type);
      expect(after.plateNumber, before.plateNumber);
      expect(after.photoPath, before.photoPath);
    });

    testWidgets('validasi field kosong', (WidgetTester tester) async {
      final state = await bootEdit(tester, 'KDN-001');
      addTearDown(state.dispose);

      await tester.enterText(find.byType(TextFormField).at(0), '');
      await tester.enterText(find.byType(TextFormField).at(1), '');
      await tester.pumpAndSettle();

      await tapVisible(
        tester,
        find.byKey(const ValueKey('admin_vehicle_save_button')),
      );

      expect(find.text('Wajib diisi'), findsWidgets);
      // Data tidak tersimpan.
      expect(state.byCode('KDN-001')!.name, 'Toyota Innova');
    });
  });

  group('Model & data', () {
    test('copyWith hanya mengubah field yang diberikan', () {
      const v = Vehicle(
        name: 'Toyota Innova',
        code: 'KDN-001',
        plateNumber: 'AB 123 XX',
        type: VehicleType.mobil,
        status: VehicleStatus.tersedia,
        imageAsset: 'assets/img/mobil.png',
        capacity: 7,
        engineCapacity: '2.4 L',
        productionYear: 2020,
      );

      final edited = v.copyWith(name: 'Baru', status: VehicleStatus.perawatan);
      expect(edited.name, 'Baru');
      expect(edited.status, VehicleStatus.perawatan);
      expect(edited.code, v.code);
      expect(edited.type, v.type);
      expect(edited.plateNumber, v.plateNumber);
      expect(edited.capacity, v.capacity);
      expect(edited.engineCapacity, v.engineCapacity);
      expect(edited.productionYear, v.productionYear);
    });

    test('data perawatan terpisah per kode kendaraan', () {
      expect(maintenanceOf('KDN-001').length, 3);
      expect(maintenanceOf('KDM-001').length, 1);
      expect(maintenanceOf('TIDAK-ADA'), isEmpty);
    });
  });

  group('Responsive', () {
    testWidgets('tanpa overflow di berbagai ukuran', (
      WidgetTester tester,
    ) async {
      for (final size in const [
        Size(320, 480),
        Size(360, 640),
        Size(393, 852),
      ]) {
        await tester.binding.setSurfaceSize(size);

        final detail = await bootDetail(tester, 'KDN-001');
        expect(
          tester.takeException(),
          isNull,
          reason: 'detail harus muat di $size',
        );
        detail.dispose();

        final edit = await bootEdit(tester, 'KDN-001');
        expect(tester.takeException(), isNull, reason: 'edit harus muat di $size');
        edit.dispose();
      }
      await tester.binding.setSurfaceSize(null);
    });
  });
}