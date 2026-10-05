enum VehicleType { mobil, motor }

enum VehicleStatus { tersedia, digunakan, perawatan }

enum VehicleEnergyType { bbm, listrik }

/// Pilihan jenis bahan bakar pada form Tambah Kendaraan.
enum VehicleFuelType { pertalite, pertamax, pertamaxTurbo, dexlite, solar }

extension VehicleTypeLabel on VehicleType {
  String get label => switch (this) {
    VehicleType.mobil => 'Mobil',
    VehicleType.motor => 'Motor',
  };
}

extension VehicleStatusLabel on VehicleStatus {
  String get label => switch (this) {
    VehicleStatus.tersedia => 'Tersedia',
    VehicleStatus.digunakan => 'Digunakan',
    VehicleStatus.perawatan => 'Perawatan',
  };
}

extension VehicleFuelTypeLabel on VehicleFuelType {
  String get label => switch (this) {
    VehicleFuelType.pertalite => 'Pertalite',
    VehicleFuelType.pertamax => 'Pertamax',
    VehicleFuelType.pertamaxTurbo => 'Pertamax Turbo',
    VehicleFuelType.dexlite => 'Dexlite',
    VehicleFuelType.solar => 'Solar',
  };
}

class Vehicle {
  const Vehicle({
    required this.name,
    required this.code,
    required this.plateNumber,
    required this.type,
    required this.status,
    required this.imageAsset,
    this.capacity,
    this.energyType = VehicleEnergyType.bbm,
    this.fuelType = VehicleFuelType.pertamax,
    this.engineCapacity = '2.4 L',
    this.productionYear = 2020,
    this.photoPath,
  });

  final String name;
  final String code;
  final String plateNumber;
  final VehicleType type;
  final VehicleStatus status;

  /// Foto bawaan dari folder assets. Tetap dipakai untuk data dummy.
  final String imageAsset;

  /// Path foto hasil unggahan dari perangkat.
  ///
  /// Kalau diisi, foto inilah yang ditampilkan, bukan [imageAsset].
  final String? photoPath;

  final int? capacity;
  final VehicleEnergyType energyType;
  final VehicleFuelType fuelType;

  /// Kapasitas mesin, mis. "2.4 L".
  final String engineCapacity;

  final int productionYear;

  /// True kalau foto kendaraan diambil dari perangkat, bukan dari assets.
  bool get hasPickedPhoto => photoPath != null && photoPath!.isNotEmpty;

  /// Sumber foto yang perlu ditampilkan: file dulu, lalu asset.
  String? get photo => hasPickedPhoto ? photoPath : imageAsset;

  /// Jumlah kursi; memakai [capacity] supaya tidak ada data yang dobel.
  int? get seatCount => capacity;

  String get searchableText => '$name $code $plateNumber'.toLowerCase();

  /// Pencarian berdasarkan nama kendaraan, nomor/kode, dan plat nomor.
  bool matches(String query) {
    final keyword = query.trim().toLowerCase();
    if (keyword.isEmpty) {
      return true;
    }
    return searchableText.contains(keyword);
  }

  bool get isElectric => energyType == VehicleEnergyType.listrik;

  /// Salinan dengan sebagian field diganti.
  ///
  /// Dipakai halaman Edit Kendaraan supaya kode kendaraan, jenis, dan foto
  /// tidak ikut berubah saat Admin hanya mengubah data lain.
  Vehicle copyWith({
    String? name,
    String? code,
    String? plateNumber,
    VehicleType? type,
    VehicleStatus? status,
    String? imageAsset,
    String? photoPath,
    int? capacity,
    VehicleFuelType? fuelType,
    String? engineCapacity,
    int? productionYear,
  }) => Vehicle(
    name: name ?? this.name,
    code: code ?? this.code,
    plateNumber: plateNumber ?? this.plateNumber,
    type: type ?? this.type,
    status: status ?? this.status,
    imageAsset: imageAsset ?? this.imageAsset,
    photoPath: photoPath ?? this.photoPath,
    capacity: capacity ?? this.capacity,
    energyType: energyType,
    fuelType: fuelType ?? this.fuelType,
    engineCapacity: engineCapacity ?? this.engineCapacity,
    productionYear: productionYear ?? this.productionYear,
  );

  /// Helper untuk pengujian dan simulasi kendaraan listrik.
  Vehicle copyWithElectric() => Vehicle(
    name: name,
    code: code,
    plateNumber: plateNumber,
    type: type,
    status: status,
    imageAsset: imageAsset,
    capacity: capacity,
    energyType: VehicleEnergyType.listrik,
    fuelType: fuelType,
    engineCapacity: engineCapacity,
    productionYear: productionYear,
    photoPath: photoPath,
  );
}

