import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'package:flutter_application_plnmobile/data/admin_vehicle_data.dart';
import 'package:flutter_application_plnmobile/models/vehicle.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_navigation.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_vehicle_form_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_vehicle_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_vehicle_detail_page.dart';
import 'package:flutter_application_plnmobile/state/admin_auth_state.dart';
import 'package:flutter_application_plnmobile/state/admin_loan_state.dart';
import 'package:flutter_application_plnmobile/state/admin_notification_state.dart';
import 'package:flutter_application_plnmobile/state/admin_vehicle_state.dart';
import 'package:flutter_application_plnmobile/widgets/admin_bottom_navigation.dart';

Finder _nav(String label) => find.byKey(ValueKey('admin_bottom_nav_$label'));

/// Search bar memakai `TextField`.
Finder _search() => find.byType(TextField);

/// Field form memakai `TextFormField`.
Finder _formField() => find.byType(TextFormField);

/// Palsukan image_picker supaya bisa diuji tanpa kamera sungguhan.
class _FakeImagePicker extends ImagePickerPlatform {
  _FakeImagePicker(this.files);

  /// File yang dikembalikan setiap panggilan pickImage.
  List<XFile> files;
  int callCount = 0;
  ImageSource? lastSource;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    callCount++;
    lastSource = source;
    if (files.isEmpty) {
      return null;
    }
    return files.removeAt(0);
  }

  @override
  Future<PickedFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    final file = await getImageFromSource(
      source: source,
      options: ImagePickerOptions(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        requestFullMetadata: requestFullMetadata,
      ),
    );
    return file == null ? null : PickedFile(file.path);
  }

  @override
  Future<List<PickedFile>?> pickMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    bool requestFullMetadata = true,
  }) async => null;
}

/// Menulis file PNG kecil ke disk supaya bisa dipakai sebagai foto选定.
String _createTempImage(String name) {
  final dir = Directory.systemTemp.createTempSync('vehicle_test');
  final file = File('${dir.path}/$name');
  // 1x1 PNG transparan.
  file.writeAsBytesSync(const [
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
    0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
    0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
    0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
    0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
    0x42, 0x60, 0x82,
  ]);
  return file.path;
}

/// Host dengan ketiga scope area Admin, sama seperti yang dipasang `main.dart`.
///
/// `AdminLoanStateScope` diperlukan karena navbar dapat membuka shell yang
/// memuat Daftar Peminjaman.
Widget _adminHost(Widget child) {
  return AdminNotificationStateScope(
    state: AdminNotificationState(),
    child: AdminVehicleStateScope(
    state: AdminVehicleState(vehicles: dummyAdminVehicles),
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

Future<AdminVehicleState> bootList(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  final state = AdminVehicleState(vehicles: dummyAdminVehicles);
  await tester.pumpWidget(
    AdminNotificationStateScope(
      state: AdminNotificationState(),
      child: AdminVehicleStateScope(
        state: state,
        child: AdminLoanStateScope(
          state: AdminLoanState(),
          child: const MaterialApp(home: AdminVehiclePage()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return state;
}

Future<AdminVehicleState> bootForm(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  final state = AdminVehicleState(vehicles: dummyAdminVehicles);
  await tester.pumpWidget(
    AdminNotificationStateScope(
      state: AdminNotificationState(),
      child: AdminVehicleStateScope(
        state: state,
        child: AdminLoanStateScope(
          state: AdminLoanState(),
          child: const MaterialApp(home: AdminVehicleFormPage()),
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

/// Ketuk sebuah widget, menggulir lebih dulu kalau belum dibangun.
///
/// Form dan daftar memakai `ListView` yang membangun anak secara bertahap,
/// jadi tombol di bagian bawah belum ada sebelum digulir.
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

/// Buka sheet sumber foto lalu pilih galeri.
Future<void> pickFromGallery(WidgetTester tester) async {
  await tapVisible(
    tester,
    find.byKey(const ValueKey('admin_vehicle_photo_area')),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('admin_vehicle_gallery_option')));
  await tester.pumpAndSettle();
}

void main() {
  late _FakeImagePicker picker;
  late Directory docsDir;

  setUp(() {
    picker = _FakeImagePicker([]);
    ImagePickerPlatform.instance = picker;

    // Palsukan path_provider supaya folder dokumen bisa dipakai saat test.
    docsDir = Directory.systemTemp.createTempSync('vehicle_docs_test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async {
            if (call.method == 'getApplicationDocumentsDirectory') {
              return docsDir.path;
            }
            return null;
          },
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    ImagePickerPlatform.instance = _RestoreImagePicker();
  });

  group('TEST 1: navbar Kendaraan membuka Daftar Kendaraan', () {
    testWidgets('TEST 1: tekan Kendaraan -> Daftar Kendaraan', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(_adminHost(const AdminShellPage()));
      await tester.pumpAndSettle();

      await tester.tap(_nav('Kendaraan'));
      await tester.pumpAndSettle();

      expect(find.byType(AdminVehiclePage), findsOneWidget);
      expect(find.text('Daftar Kendaraan'), findsOneWidget);
      expect(_selected(tester), AdminShellPage.indexKendaraan);
      // Tidak ada navbar ganda saat sudah jadi tab shell.
      expect(find.byType(AdminBottomNavigation), findsOneWidget);
    });
  });

  group('TEST 2 & 3: filter Mobil dan Motor', () {
    testWidgets('TEST 2: filter Mobil hanya menampilkan mobil', (
      WidgetTester tester,
    ) async {
      final harness = await bootList(tester);
      addTearDown(harness.dispose);

      // Default-nya Mobil.
      expect(find.byType(AdminVehicleCard), findsNWidgets(4));
      expect(
        find.descendant(
          of: find.byType(AdminVehicleCard),
          matching: find.text('Toyota Innova'),
        ),
        findsNWidgets(4),
      );
      expect(
        find.descendant(
          of: find.byType(AdminVehicleCard),
          matching: find.text('Lifan'),
        ),
        findsNothing,
      );
    });

    testWidgets('TEST 3: filter Motor hanya menampilkan motor', (
      WidgetTester tester,
    ) async {
      final harness = await bootList(tester);
      addTearDown(harness.dispose);

      await tester.tap(find.widgetWithText(InkWell, 'Motor'));
      await tester.pumpAndSettle();

      expect(find.byType(AdminVehicleCard), findsNWidgets(4));
      expect(
        find.descendant(
          of: find.byType(AdminVehicleCard),
          matching: find.text('Lifan'),
        ),
        findsNWidgets(4),
      );
      expect(
        find.descendant(
          of: find.byType(AdminVehicleCard),
          matching: find.text('Toyota Innova'),
        ),
        findsNothing,
      );
    });

    testWidgets('tombol aktif biru dan tidak aktif putih', (
      WidgetTester tester,
    ) async {
      final harness = await bootList(tester);
      addTearDown(harness.dispose);

      Color bgOf(String label) {
        final ink = tester.widget<Ink>(
          find
              .ancestor(of: find.text(label), matching: find.byType(Ink))
              .first,
        );
        return (ink.decoration! as BoxDecoration).color!;
      }

      expect(bgOf('Mobil'), const Color(0xFF0B75D1));
      expect(bgOf('Motor'), Colors.white);

      await tester.tap(find.widgetWithText(InkWell, 'Motor'));
      await tester.pumpAndSettle();

      expect(bgOf('Motor'), const Color(0xFF0B75D1));
      expect(bgOf('Mobil'), Colors.white);
    });
  });

  group('TEST 4: search kendaraan', () {
    testWidgets('TEST 4a: cari nama kendaraan', (WidgetTester tester) async {
      final harness = await bootList(tester);
      addTearDown(harness.dispose);

      await tester.enterText(_search(), 'innova');
      await tester.pumpAndSettle();
      expect(find.byType(AdminVehicleCard), findsNWidgets(4));
    });

    testWidgets('TEST 4b: cari kode kendaraan', (WidgetTester tester) async {
      final harness = await bootList(tester);
      addTearDown(harness.dispose);

      await tester.tap(find.widgetWithText(InkWell, 'Motor'));
      await tester.pumpAndSettle();
      await tester.enterText(_search(), 'KDM-003');
      await tester.pumpAndSettle();
      expect(find.byType(AdminVehicleCard), findsOneWidget);
    });

    testWidgets('TEST 4c: cari plat nomor', (WidgetTester tester) async {
      final harness = await bootList(tester);
      addTearDown(harness.dispose);

      await tester.enterText(_search(), 'AB 128');
      await tester.pumpAndSettle();
      expect(find.byType(AdminVehicleCard), findsOneWidget);
    });

    testWidgets('TEST 4d: tidak ditemukan -> empty state', (
      WidgetTester tester,
    ) async {
      final harness = await bootList(tester);
      addTearDown(harness.dispose);

      await tester.enterText(_search(), 'tidak ada mobil ini');
      await tester.pumpAndSettle();

      expect(find.byType(AdminVehicleCard), findsNothing);
      expect(find.text('Data kendaraan tidak ditemukan'), findsOneWidget);
    });

    testWidgets('TEST 4e: search + filter dipakai bersamaan', (
      WidgetTester tester,
    ) async {
      final harness = await bootList(tester);
      addTearDown(harness.dispose);

      // Motor + Lifan
      await tester.tap(find.widgetWithText(InkWell, 'Motor'));
      await tester.pumpAndSettle();
      await tester.enterText(_search(), 'Lifan');
      await tester.pumpAndSettle();
      expect(find.byType(AdminVehicleCard), findsNWidgets(4));

      // Ganti ke Mobil + Toyota
      await tester.tap(find.widgetWithText(InkWell, 'Mobil'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminVehicleCard), findsNothing);

      await tester.enterText(_search(), 'Toyota');
      await tester.pumpAndSettle();
      expect(find.byType(AdminVehicleCard), findsNWidgets(4));
    });
  });

  group('TEST 5: tombol + Tambah', () {
    testWidgets('TEST 5: + Tambah membuka halaman Tambah Kendaraan', (
      WidgetTester tester,
    ) async {
      final harness = await bootList(tester);
      addTearDown(harness.dispose);

      await tester.tap(find.widgetWithText(InkWell, '+ Tambah'));
      await tester.pumpAndSettle();

      expect(find.byType(AdminVehicleFormPage), findsOneWidget);
      expect(find.text('Tambah Kendaraan'), findsOneWidget);
      expect(find.text('Foto Kendaraan'), findsOneWidget);
      expect(find.text('Status Kendaraan'), findsOneWidget);
    });
  });

  group('TEST 6: pilih jenis kendaraan', () {
    testWidgets('TEST 6: Mobil/Motor berganti state', (
      WidgetTester tester,
    ) async {
      final harness = await bootForm(tester);
      addTearDown(harness.dispose);

      Color bgOf(String label) {
        final ink = tester.widget<Ink>(
          find.byKey(ValueKey('admin_vehicle_type_${label.toLowerCase()}')),
        );
        return (ink.decoration! as BoxDecoration).color!;
      }

      // Default Mobil.
      expect(bgOf('Mobil'), const Color(0xFF0B75D1));
      expect(bgOf('Motor'), Colors.transparent);

      await tester.tap(find.byKey(const ValueKey('admin_vehicle_type_motor')));
      await tester.pumpAndSettle();
      expect(bgOf('Motor'), const Color(0xFF0B75D1));
      expect(bgOf('Mobil'), Colors.transparent);
    });

    testWidgets('TEST 6: jenis tersimpan saat Simpan', (
      WidgetTester tester,
    ) async {
      final harness = await bootForm(tester);
      addTearDown(harness.dispose);

      picker.files = [XFile(_createTempImage('motor.png'))];
      await tester.tap(find.byKey(const ValueKey('admin_vehicle_type_motor')));
      await tester.pumpAndSettle();

      await _fillRequiredFields(tester);
      await tapVisible(tester, find.byKey(const ValueKey('admin_vehicle_save_button')));

      expect(harness.vehicles.first.type, VehicleType.motor);
    });
  });

  group('TEST 7, 8, 9: unggah dan ganti foto', () {
    testWidgets('TEST 7: tekan area foto membuka pilihan sumber', (
      WidgetTester tester,
    ) async {
      final harness = await bootForm(tester);
      addTearDown(harness.dispose);

      await tapVisible(
        tester,
        find.byKey(const ValueKey('admin_vehicle_photo_area')),
      );

      // Pilihan gallery (dan kamera) tersedia.
      expect(
        find.byKey(const ValueKey('admin_vehicle_gallery_option')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('admin_vehicle_camera_option')),
        findsOneWidget,
      );
      expect(find.text('Tap untuk mengunggah foto'), findsOneWidget);
    });

    testWidgets('TEST 7: galeri yang dipilih benar-benar dipanggil', (
      WidgetTester tester,
    ) async {
      final harness = await bootForm(tester);
      addTearDown(harness.dispose);

      picker.files = [XFile(_createTempImage('a.png'))];
      await pickFromGallery(tester);

      expect(picker.callCount, 1);
      expect(picker.lastSource, ImageSource.gallery);
    });

    testWidgets('TEST 8: foto terpilih tampil sebagai preview', (
      WidgetTester tester,
    ) async {
      final harness = await bootForm(tester);
      addTearDown(harness.dispose);

      picker.files = [XFile(_createTempImage('preview.png'))];
      await pickFromGallery(tester);

      // Placeholder diganti preview foto + ada tombol Ganti Foto.
      expect(find.text('Tap untuk mengunggah foto'), findsNothing);
      // `FileImage` adalah ImageProvider, jadi diperiksa lewat widget Image.
      final preview = tester.widget<Image>(find.byType(Image).first);
      expect(preview.image, isA<FileImage>());
      expect(
        find.byKey(const ValueKey('admin_vehicle_change_photo')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('TEST 9: ganti foto memakai foto baru', (
      WidgetTester tester,
    ) async {
      final harness = await bootForm(tester);
      addTearDown(harness.dispose);

      final first = _createTempImage('first.png');
      final second = _createTempImage('second.png');
      picker.files = [XFile(first), XFile(second)];

      await pickFromGallery(tester);
      expect(picker.callCount, 1);

      // Tekan "Ganti Foto".
      await tapVisible(
        tester,
        find.byKey(const ValueKey('admin_vehicle_change_photo')),
      );
      await tester.tap(find.byKey(const ValueKey('admin_vehicle_gallery_option')));
      await tester.pumpAndSettle();

      expect(picker.callCount, 2);
      // Preview tidak error dan foto barunya yang dipakai.
      final preview = tester.widget<Image>(find.byType(Image).first);
      expect(preview.image, isA<FileImage>());
      expect(
        (preview.image as FileImage).file.path,
        second,
        reason: 'preview harus memakai foto terbaru',
      );
      expect(find.text('Tap untuk mengunggah foto'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('batal pilih foto tidak merusak form', (
      WidgetTester tester,
    ) async {
      final harness = await bootForm(tester);
      addTearDown(harness.dispose);

      // pickImage mengembalikan null (Admin membatalkan).
      picker.files = [];
      await pickFromGallery(tester);

      expect(picker.callCount, 1);
      expect(find.text('Tap untuk mengunggah foto'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('TEST 10: validasi foto wajib', () {
    testWidgets('TEST 10: Simpan tanpa foto menampilkan validasi', (
      WidgetTester tester,
    ) async {
      final harness = await bootForm(tester);
      addTearDown(harness.dispose);

      await tapVisible(
        tester,
        find.byKey(const ValueKey('admin_vehicle_save_button')),
      );

      // Pesan muncul dua kali: di bawah area foto dan sebagai snackbar.
      expect(find.text('Foto kendaraan wajib diunggah'), findsWidgets);
      // Tetap di halaman form, data tidak tersimpan.
      expect(find.byType(AdminVehicleFormPage), findsOneWidget);
      expect(harness.vehicles.length, dummyAdminVehicles.length);
    });

    testWidgets('TEST 10: validasi hilang setelah foto dipilih', (
      WidgetTester tester,
    ) async {
      final harness = await bootForm(tester);
      addTearDown(harness.dispose);

      await tapVisible(
        tester,
        find.byKey(const ValueKey('admin_vehicle_save_button')),
      );
      expect(find.text('Foto kendaraan wajib diunggah'), findsWidgets);

      picker.files = [XFile(_createTempImage('ok.png'))];
      await pickFromGallery(tester);
      // Biarkan snackbar dari percobaan sebelumnya habis.
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Foto kendaraan wajib diunggah'), findsNothing);
    });
  });

  group('TEST 11 & 12: simpan data lengkap', () {
    testWidgets('TEST 11: dropdown bahan bakar benar-benar berfungsi', (
      WidgetTester tester,
    ) async {
      final harness = await bootForm(tester);
      addTearDown(harness.dispose);

      expect(find.text('Pertamax'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('admin_vehicle_fuel_dropdown')),
      );
      await tester.pumpAndSettle();

      // Kelima pilihan dari spesifikasi.
      for (final fuel in ['Pertalite', 'Pertamax', 'Pertamax Turbo', 'Dexlite', 'Solar']) {
        expect(
          find.text(fuel).last,
          findsOneWidget,
          reason: 'opsi $fuel harus ada',
        );
      }

      await tester.tap(find.text('Solar').last);
      await tester.pumpAndSettle();
      expect(find.text('Solar'), findsOneWidget);
    });

    testWidgets('TEST 11: pilihan status radio tunggal', (
      WidgetTester tester,
    ) async {
      final harness = await bootForm(tester);
      addTearDown(harness.dispose);

      Finder checkedIn(String name) => find.descendant(
        of: find.byKey(ValueKey('admin_vehicle_status_$name')),
        matching: find.byIcon(Icons.radio_button_checked),
      );

      // Default: Tersedia aktif.
      expect(checkedIn('tersedia'), findsOneWidget);

      await tapVisible(
        tester,
        find.byKey(const ValueKey('admin_vehicle_status_perawatan')),
      );
      // Hanya satu yang aktif.
      expect(checkedIn('perawatan'), findsOneWidget);
      expect(checkedIn('tersedia'), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('admin_vehicle_status_tersedia')),
          matching: find.byIcon(Icons.radio_button_unchecked),
        ),
        findsOneWidget,
      );
    });

    testWidgets('TEST 11 & 12: simpan lalu kembali ke daftar', (
      WidgetTester tester,
    ) async {
      final harness = await bootList(tester);
      addTearDown(harness.dispose);

      await tester.tap(find.widgetWithText(InkWell, '+ Tambah'));
      await tester.pumpAndSettle();

      picker.files = [XFile(_createTempImage('baru.png'))];
      await pickFromGallery(tester);
      await tester.enterText(_formField().at(0), 'Toyota Fortuner');
      await tester.enterText(_formField().at(1), 'B 2345 XX');
      await tester.tap(find.byKey(const ValueKey('admin_vehicle_fuel_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pertamax Turbo').last);
      await tester.pumpAndSettle();
      await tester.enterText(_formField().at(2), '2.4 L');
      await tester.enterText(_formField().at(3), '7');
      await tester.enterText(_formField().at(4), '2020');
      await tester.pumpAndSettle();

      final before = harness.vehicles.length;
      await tapVisible(
        tester,
        find.byKey(const ValueKey('admin_vehicle_save_button')),
      );

      // Kembali ke daftar.
      expect(find.byType(AdminVehicleFormPage), findsNothing);
      expect(find.byType(AdminVehiclePage), findsOneWidget);
      expect(harness.vehicles.length, before + 1);

      // Kendaraan baru tersimpan dengan semua data.
      final saved = harness.vehicles.first;
      expect(saved.name, 'Toyota Fortuner');
      expect(saved.plateNumber, 'B 2345 XX');
      expect(saved.fuelType, VehicleFuelType.pertamaxTurbo);
      expect(saved.engineCapacity, '2.4 L');
      expect(saved.capacity, 7);
      expect(saved.productionYear, 2020);
      expect(saved.type, VehicleType.mobil);
      expect(saved.status, VehicleStatus.tersedia);
      expect(saved.hasPickedPhoto, isTrue, reason: 'foto harus tersimpan');
      expect(File(saved.photoPath!).existsSync(), isTrue);
    });

    testWidgets('TEST 13: kendaraan baru muncul di daftar', (
      WidgetTester tester,
    ) async {
      final harness = await bootList(tester);
      addTearDown(harness.dispose);

      await tester.tap(find.widgetWithText(InkWell, '+ Tambah'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('admin_vehicle_type_motor')));
      await tester.pumpAndSettle();
      picker.files = [XFile(_createTempImage('motor-baru.png'))];
      await pickFromGallery(tester);
      await _fillRequiredFields(tester);
      await tapVisible(tester, find.byKey(const ValueKey('admin_vehicle_save_button')));

      // Sekarang di daftar, dan tampilan awal masih filter Mobil.
      expect(find.byType(AdminVehiclePage), findsOneWidget);
      // Ganti ke Motor supaya kendaraan baru terlihat.
      await tester.tap(find.widgetWithText(InkWell, 'Motor'));
      await tester.pumpAndSettle();

      final newCard = find.ancestor(
        of: find.text('Toyota Fortuner'),
        matching: find.byType(AdminVehicleCard),
      );
      expect(newCard, findsOneWidget);
      // Foto hasil unggahan tampil di card.
      final cardImage = tester.widget<Image>(
        find.descendant(of: newCard, matching: find.byType(Image)),
      );
      expect(cardImage.image, isA<FileImage>());
    });

    testWidgets('Batal tidak menyimpan data', (WidgetTester tester) async {
      final harness = await bootList(tester);
      addTearDown(harness.dispose);

      await tester.tap(find.widgetWithText(InkWell, '+ Tambah'));
      await tester.pumpAndSettle();
      await tester.enterText(_formField().at(0), 'Tidak Boleh Masuk');
      await tester.pumpAndSettle();

      final before = harness.vehicles.length;
      await tapVisible(
        tester,
        find.byKey(const ValueKey('admin_vehicle_cancel_button')),
      );

      expect(find.byType(AdminVehicleFormPage), findsNothing);
      expect(find.byType(AdminVehiclePage), findsOneWidget);
      expect(harness.vehicles.length, before);
      expect(
        find.text('Tidak Boleh Masuk'),
        findsNothing,
        reason: 'data batal tidak boleh tampil di daftar',
      );
    });
  });

  group('TEST 14: setiap card membuka Detail Kendaraan', () {
    testWidgets('TEST 14: tekan card membuka Detail Kendaraan', (
      WidgetTester tester,
    ) async {
      final harness = await bootList(tester);
      addTearDown(harness.dispose);

      // Ketuk card pertama.
      await tapVisible(tester, find.byType(AdminVehicleCard).first);

      expect(find.byType(AdminVehicleDetailPage), findsOneWidget);
      expect(find.text('Detail Kendaraan'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Kembali ke daftar.
      await tester.tap(find.byTooltip('Kembali'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminVehicleDetailPage), findsNothing);
      expect(find.byType(AdminVehiclePage), findsOneWidget);
    });

    testWidgets('TEST 14: card kedua membuka detail yang benar', (
      WidgetTester tester,
    ) async {
      final harness = await bootList(tester);
      addTearDown(harness.dispose);

      // Baca dulu isi card kedua yang benar-benar terlihat di daftar, lalu
      // pastikan detail-nya sesuai card itu (bukan card lain).
      final second = find.byType(AdminVehicleCard).at(1);
      String codeOf(Finder card) => tester
          .widgetList<Text>(
            find.descendant(of: card, matching: find.byType(Text)),
          )
          .map((t) => t.data ?? '')
          .firstWhere((d) => d.startsWith('KDN'));

      final secondCode = codeOf(second);
      final firstCode = codeOf(find.byType(AdminVehicleCard).first);
      expect(secondCode, isNot(firstCode), reason: 'dua kartu harus berbeda');

      // Ringkasan pada halaman detail menampilkan "kode    plat".
      final secondVehicle = harness.byCode(secondCode)!;
      final firstVehicle = harness.byCode(firstCode)!;
      final secondSummary =
          '${secondVehicle.code}    ${secondVehicle.plateNumber}';
      final firstSummary =
          '${firstVehicle.code}    ${firstVehicle.plateNumber}';

      await tapVisible(tester, second);

      expect(find.byType(AdminVehicleDetailPage), findsOneWidget);
      expect(find.text('Detail Kendaraan'), findsOneWidget);
      // Data yang tampil milik kendaraan kedua, bukan yang pertama.
      expect(find.text(secondVehicle.name), findsWidgets);
      expect(find.text(secondSummary), findsOneWidget);
      expect(find.text(firstSummary), findsNothing);
    });

    testWidgets('TEST 14: semua status tetap bisa dibuka', (
      WidgetTester tester,
    ) async {
      final harness = await bootList(tester);
      addTearDown(harness.dispose);

      // Untuk tiap status yang ada di daftar, card-nya harus bisa ditekan.
      for (final status in ['Tersedia', 'Digunakan', 'Perawatan']) {
        expect(find.text(status), findsWidgets, reason: 'status $status');
      }

      for (var i = 0; i < 4; i++) {
        await tester.tap(find.byType(AdminVehicleCard).at(i), warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(
          find.byType(AdminVehicleDetailPage),
          findsOneWidget,
          reason: 'card ke-$i harus terbuka',
        );
        await tester.tap(find.byTooltip('Kembali'));
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('badge status tampil dengan warna yang sesuai', (
      WidgetTester tester,
    ) async {
      final harness = await bootList(tester);
      addTearDown(harness.dispose);

      Color bgOf(String label) {
        final container = tester.widget<Container>(
          find
              .ancestor(of: find.text(label), matching: find.byType(Container))
              .first,
        );
        return (container.decoration! as BoxDecoration).color!;
      }

      expect(bgOf('Tersedia'), const Color(0xFFDDF5E2));
      expect(bgOf('Digunakan'), const Color(0xFFFDE8B0));
      expect(bgOf('Perawatan'), const Color(0xFFF9D5D5));
    });
  });

  group('TEST 15: navbar tetap bisa dipakai', () {
    testWidgets('TEST 15: keempat tombol navbar dari Daftar Kendaraan', (
      WidgetTester tester,
    ) async {
      const labels = [
        'Beranda',
        'Kendaraan',
        'Notifikasi',
        'Profil',
      ];
      for (var i = 0; i < labels.length; i++) {
        final harness = await bootList(tester);
        addTearDown(harness.dispose);

        await tester.tap(_nav(labels[i]));
        await tester.pumpAndSettle();

        expect(_selected(tester), i, reason: 'harus di ${labels[i]}');
        expect(find.byType(AdminBottomNavigation), findsOneWidget);
      }
    });

    testWidgets('TEST 15: navbar dari form Tambah Kendaraan', (
      WidgetTester tester,
    ) async {
      final harness = await bootForm(tester);
      addTearDown(harness.dispose);

      expect(find.byType(AdminBottomNavigation), findsOneWidget);
      expect(_selected(tester), AdminShellPage.indexKendaraan);

      await tester.tap(_nav('Profil'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminVehicleFormPage), findsNothing);
      expect(_selected(tester), AdminShellPage.indexProfil);
    });
  });

  group('Model kendaraan', () {
    test('struktur data lengkap untuk backend', () {
      final vehicle = dummyAdminVehicles.first;
      expect(vehicle.name, isNotEmpty);
      expect(vehicle.code, isNotEmpty);
      expect(vehicle.plateNumber, isNotEmpty);
      expect(vehicle.type, VehicleType.motor);
      expect(vehicle.capacity, isNotNull);
      expect(vehicle.photo, isNotEmpty);
      expect(vehicle.fuelType.label, isNotEmpty);
      expect(vehicle.engineCapacity, isNotEmpty);
      expect(vehicle.productionYear, greaterThan(2000));
      expect(vehicle.status, VehicleStatus.tersedia);
      expect(vehicle.hasPickedPhoto, isFalse);
    });

    test('nextCode menghasilkan kode unik berikutnya', () {
      final state = AdminVehicleState(vehicles: dummyAdminVehicles);
      expect(state.nextCode(), 'KDN-005');
      state.add(
        Vehicle(
          name: 'Uji',
          code: 'KDN-010',
          plateNumber: 'B 1 XX',
          type: VehicleType.mobil,
          status: VehicleStatus.tersedia,
          imageAsset: 'assets/img/mobil.png',
        ),
      );
      expect(state.nextCode(), 'KDN-011');
      state.dispose();
    });

    test('matches mencari nama, kode, dan plat', () {
      const v = Vehicle(
        name: 'Toyota Innova',
        code: 'KDN-001',
        plateNumber: 'AB 123 XX',
        type: VehicleType.mobil,
        status: VehicleStatus.tersedia,
        imageAsset: 'assets/img/mobil.png',
      );
      expect(v.matches('innova'), isTrue);
      expect(v.matches('KDN-001'), isTrue);
      expect(v.matches('ab 123'), isTrue);
      expect(v.matches('lifan'), isFalse);
      expect(v.matches(''), isTrue);
    });
  });

  group('Responsif', () {
    testWidgets('tidak ada overflow di daftar dan form', (
      WidgetTester tester,
    ) async {
      for (final size in const [
        Size(320, 480),
        Size(360, 640),
        Size(393, 852),
      ]) {
        await tester.binding.setSurfaceSize(size);

        final listHarness = await bootList(tester);
        expect(
          tester.takeException(),
          isNull,
          reason: 'daftar harus muat di $size',
        );
        listHarness.dispose();

        final formHarness = await bootForm(tester);
        expect(
          tester.takeException(),
          isNull,
          reason: 'form harus muat di $size',
        );
        formHarness.dispose();
      }
      await tester.binding.setSurfaceSize(null);
    });
  });
}

/// Mengisi field wajib form (nama, plat, mesin, kursi, tahun).
Future<void> _fillRequiredFields(WidgetTester tester) async {
  await tester.enterText(_formField().at(0), 'Toyota Fortuner');
  await tester.enterText(_formField().at(1), 'B 2345 XX');
  await tester.enterText(_formField().at(2), '2.4 L');
  await tester.enterText(_formField().at(3), '7');
  await tester.enterText(_formField().at(4), '2020');
  await tester.pumpAndSettle();
}

/// Platform image_picker asli, dipakai untuk mengembalikan kondisi setelah
/// test selesai.
class _RestoreImagePicker extends ImagePickerPlatform {
}