import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../data/vehicle_data.dart';
import '../models/vehicle.dart';

/// Sumber data kendaraan untuk halaman Admin.
///
/// Kendaraan yang ditambahkan lewat form disimpan di sini, sehingga langsung
/// muncul di Daftar Kendaraan tanpa perlu reload. Foto hasil unggahan disalin
/// ke folder aplikasi supaya tidak hilang setelah aplikasi ditutup.
///
/// Nanti tinggal ganti daftar awal dengan data dari backend.
class AdminVehicleState extends ChangeNotifier {
  AdminVehicleState({List<Vehicle>? vehicles})
    : _vehicles = List<Vehicle>.of(vehicles ?? dummyVehicles);

  final List<Vehicle> _vehicles;

  List<Vehicle> get vehicles => List<Vehicle>.unmodifiable(_vehicles);

  /// Mencari kendaraan berdasarkan kode, mis. "KDN-001".
  ///
  /// Dipakai saat card ditekan supaya data yang dibuka selalu data terbaru
  /// dari state, bukan salinan yang tertahan sejak card dibangun.
  Vehicle? byCode(String code) {
    for (final vehicle in _vehicles) {
      if (vehicle.code == code) {
        return vehicle;
      }
    }
    return null;
  }

  /// Mendaftarkan kendaraan baru. Foto sudah dipastikan berupa path permanen
  /// oleh pemanggil sebelum method ini dipanggil.
  void add(Vehicle vehicle) {
    _vehicles.insert(0, vehicle);
    notifyListeners();
  }

  /// Memperbarui data kendaraan yang sudah ada (dari halaman Edit).
  void updateVehicle(Vehicle vehicle) {
    final index = _vehicles.indexWhere(
      (item) => item.code == vehicle.code,
    );
    if (index == -1) {
      return;
    }
    _vehicles[index] = vehicle;
    notifyListeners();
  }

  /// Memperbarui path foto kendaraan setelah salinan permanen selesai dibuat.
  void replacePhoto(String code, String photoPath) {
    final index = _vehicles.indexWhere((vehicle) => vehicle.code == code);
    if (index == -1) {
      return;
    }
    final current = _vehicles[index];
    _vehicles[index] = Vehicle(
      name: current.name,
      code: current.code,
      plateNumber: current.plateNumber,
      type: current.type,
      status: current.status,
      imageAsset: current.imageAsset,
      capacity: current.capacity,
      energyType: current.energyType,
      fuelType: current.fuelType,
      engineCapacity: current.engineCapacity,
      productionYear: current.productionYear,
      photoPath: photoPath,
    );
    notifyListeners();
  }

  /// Kode kendaraan berikutnya, mis. "KDN-001" -> "KDN-002".
  String nextCode() {
    var max = 0;
    for (final vehicle in _vehicles) {
      final digits = RegExp(r'(\d+)$').firstMatch(vehicle.code)?.group(1);
      final value = int.tryParse(digits ?? '');
      if (value != null && value > max) {
        max = value;
      }
    }
    return 'KDN-${(max + 1).toString().padLeft(3, '0')}';
  }

  /// Menyalin foto hasil unggahan ke folder aplikasi dan mengembalikan path
  /// yang aman dipakai ulang.
  ///
  /// Foto dari gallery sering berada di cache sementara yang bisa dihapus
  /// sistem, jadi wajib disalin agar tetap tampil setelah aplikasi ditutup.
  /// Kalau salinan gagal atau platform tidak merespons, path asli tetap
  /// dikembalikan sebagai cadangan supaya penyimpanan tidak pernah terhenti.
  static Future<String> persistPhoto(String pickedPath) async {
    try {
      final source = File(pickedPath);
      if (!source.existsSync()) {
        return pickedPath;
      }
      // Batas waktu mencegah penyimpanan menggantung kalau platform tidak
      // merespons.
      final directory = await getApplicationDocumentsDirectory().timeout(
        const Duration(seconds: 5),
      );
      final photos = Directory('${directory.path}/vehicle_photos');
      if (!photos.existsSync()) {
        await photos.create(recursive: true);
      }
      final extension = pickedPath.contains('.')
          ? pickedPath.substring(pickedPath.lastIndexOf('.'))
          : '.jpg';
      final target = File(
        '${photos.path}/vehicle_${DateTime.now().millisecondsSinceEpoch}'
        '$extension',
      );
      await source.copy(target.path);
      return target.path;
    } on Object {
      // Kalau ada masalah (misalnya di platform tanpa storage), pakai path asli.
      return pickedPath;
    }
  }
}

class AdminVehicleStateScope extends InheritedNotifier<AdminVehicleState> {
  const AdminVehicleStateScope({
    super.key,
    required AdminVehicleState state,
    required super.child,
  }) : super(notifier: state);

  static AdminVehicleState of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AdminVehicleStateScope>();
    assert(scope != null, 'AdminVehicleStateScope tidak ditemukan.');
    return scope!.notifier!;
  }

  static AdminVehicleState? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<AdminVehicleStateScope>()
      ?.notifier;
}
