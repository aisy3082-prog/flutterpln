import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression test untuk asset gambar.
///
/// Gejala yang pernah terjadi: file gambar sudah ada di `assets/img` dan sudah
/// didaftarkan di `pubspec.yaml`, tapi aplikasi masih menampilkan
/// "Unable to load asset". Tes ini memastikan semua gambar yang dipakai aplikasi
/// benar-benar ikut ter-bundle dan tidak kosong.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const usedImages = <String>[
    'assets/img/logo.png',
    'assets/img/backgrond.jpeg',
    'assets/img/mobil.png',
    'assets/img/motor.jpeg',
    'assets/img/profil.jpg',
  ];

  test('semua gambar terdaftar di AssetManifest', () async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

    for (final image in usedImages) {
      expect(
        manifest.listAssets(),
        contains(image),
        reason: '$image belum terdaftar di pubspec.yaml bagian assets',
      );
    }
  });

  test('isi semua gambar tidak kosong dan bisa dibaca', () async {
    for (final image in usedImages) {
      final data = await rootBundle.load(image);

      expect(
        data.lengthInBytes,
        greaterThan(0),
        reason: '$image ada di bundle tapi isinya kosong',
      );
    }
  });
}