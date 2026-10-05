import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/vehicle.dart';
import '../../state/admin_vehicle_state.dart';
import '../../utils/constants.dart';
import '../../widgets/admin_bottom_navigation.dart';
import '../../widgets/admin_vehicle_form_fields.dart';
import 'admin_navigation.dart';

/// Halaman "Tambah Kendaraan" milik Admin.
///
/// Berisi pilihan jenis kendaraan, unggah foto (gallery/kamera), data
/// kendaraan, dan pilihan status. Foto wajib diisi sebelum bisa disimpan.
class AdminVehicleFormPage extends StatefulWidget {
  const AdminVehicleFormPage({super.key});

  @override
  State<AdminVehicleFormPage> createState() => _AdminVehicleFormPageState();
}

class _AdminVehicleFormPageState extends State<AdminVehicleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _plateController = TextEditingController();
  final _engineController = TextEditingController();
  final _seatController = TextEditingController();
  final _yearController = TextEditingController();

  VehicleType _type = VehicleType.mobil;
  VehicleFuelType _fuelType = VehicleFuelType.pertamax;
  VehicleStatus _status = VehicleStatus.tersedia;

  /// Path foto sementara, dipakai untuk preview sebelum disimpan.
  String? _pickedPhotoPath;

  /// Sumber gambar dipakai agar file foto bisa dibuka tanpa dependency Image.
  final ImagePicker _picker = ImagePicker();

  /// True setelah Admin pernah menekan Simpan tanpa foto, supaya pesan
  /// validasi tidak muncul sebelum form disentuh.
  bool _photoAttempted = false;

  /// Kendaraan sementara hanya untuk merender preview foto, mengikuti jenis
  /// kendaraan yang sedang dipilih.
  Vehicle get _previewVehicle => Vehicle(
    name: _nameController.text.trim().isEmpty
        ? 'Kendaraan'
        : _nameController.text.trim(),
    code: '',
    plateNumber: '',
    type: _type,
    status: _status,
    imageAsset: 'assets/img/mobil.png',
    photoPath: _pickedPhotoPath,
    capacity: int.tryParse(_seatController.text.trim()),
  );

  @override
  void dispose() {
    _nameController.dispose();
    _plateController.dispose();
    _engineController.dispose();
    _seatController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  /// Membuka pilihan sumber foto: kamera atau galeri.
  ///
  /// Keduanya selalu ditampilkan; kalau kamera tidak tersedia (misalnya di
  /// emulator tanpa kamera), [_pick] menangkap errornya dan menampilkan pesan
  /// singkat, sehingga galeri tetap bisa dipakai.
  Future<void> _choosePhotoSource() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const ValueKey('admin_vehicle_camera_option'),
              leading: const Icon(
                Icons.photo_camera_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              title: const Text(
                'Ambil Foto',
                style: TextStyle(fontSize: 11),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pick(ImageSource.camera);
              },
            ),
            ListTile(
              key: const ValueKey('admin_vehicle_gallery_option'),
              leading: const Icon(
                Icons.photo_library_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              title: const Text(
                'Pilih dari Galeri',
                style: TextStyle(fontSize: 11),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pick(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        // Rasio foto dibatasi supaya tidak terlalu besar dan tidak overflow.
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (file == null || !mounted) {
        return;
      }
      setState(() {
        _pickedPhotoPath = file.path;
      });
      // Form divalidasi ulang supaya pesan foto lama langsung hilang.
      _formKey.currentState?.validate();
    } on Object {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak bisa membuka galeri pada perangkat ini.'),
        ),
      );
    }
  }

  Future<void> _save() async {
    // Foto wajib ada sebelum data disimpan.
    if (_pickedPhotoPath == null) {
      setState(() {
        _photoAttempted = true;
      });
      _formKey.currentState?.validate();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Foto kendaraan wajib diunggah')),
        );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final state = AdminVehicleStateScope.of(context);
    final code = state.nextCode();
    final pickedPath = _pickedPhotoPath!;

    // Kendaraan langsung didaftarkan dengan foto yang dipilih, lalu salinan
    // permanen dibuat setelahnya. Dengan begitu Admin tidak menunggu proses
    // penyimpanan file.
    state.add(
      Vehicle(
        name: _nameController.text.trim(),
        code: code,
        plateNumber: _plateController.text.trim(),
        type: _type,
        status: _status,
        imageAsset: _type == VehicleType.mobil
            ? 'assets/img/mobil.png'
            : 'assets/img/motor.jpeg',
        photoPath: pickedPath,
        capacity: int.tryParse(_seatController.text.trim()),
        fuelType: _fuelType,
        engineCapacity: _engineController.text.trim(),
        productionYear:
            int.tryParse(_yearController.text.trim()) ??
            DateTime.now().year,
      ),
    );

    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();

    // Foto disalin ke folder aplikasi supaya tetap ada setelah aplikasi
    // ditutup, lalu path-nya ditukar di state.
    final savedPath = await AdminVehicleState.persistPhoto(pickedPath);
    if (savedPath != pickedPath) {
      state.replacePhoto(code, savedPath);
    }
  }

  void _cancel() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _pickedPhotoPath != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textStrong,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          toolbarHeight: 44,
          leading: IconButton(
            onPressed: _cancel,
            icon: const Icon(Icons.arrow_back, size: 20),
            tooltip: 'Kembali',
          ),
          title: const Text(
            'Tambah Kendaraan',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textStrong,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            // SingleChildScrollView supaya form tetap bisa digulir saat
            // keyboard muncul.
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              children: [
                _TypeSegmented(
                  selected: _type,
                  onChanged: (type) => setState(() => _type = type),
                ),
                const SizedBox(height: 14),
                const AdminFormLabel('Foto Kendaraan'),
                const SizedBox(height: 6),
                _PhotoPicker(
                  vehicle: _previewVehicle,
                  hasPhoto: hasPhoto,
                  onTap: _choosePhotoSource,
                ),
                _PhotoError(
                  visible: _photoAttempted && !hasPhoto,
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AdminTextFieldBox(
                        label: 'Nomor Kendaraan',
                        hint: 'Toyota Fortuner',
                        controller: _nameController,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AdminTextFieldBox(
                        label: 'Plat Nomor',
                        hint: 'B 2345 XX',
                        controller: _plateController,
                        validator: _required,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AdminFuelDropdown(
                        value: _fuelType,
                        onChanged: (value) =>
                            setState(() => _fuelType = value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AdminTextFieldBox(
                        label: 'Kapasitas Mesin',
                        hint: '2.4 L',
                        controller: _engineController,
                        validator: _required,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AdminTextFieldBox(
                        label: 'Jumlah Kursi',
                        hint: '7 Seat',
                        controller: _seatController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final required = _required(value);
                          if (required != null) {
                            return required;
                          }
                          return int.tryParse(value!.trim()) == null
                              ? 'Masukkan angka'
                              : null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AdminTextFieldBox(
                        label: 'Tahun Produksi',
                        hint: '2020',
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final required = _required(value);
                          if (required != null) {
                            return required;
                          }
                          return int.tryParse(value!.trim()) == null
                              ? 'Masukkan angka'
                              : null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AdminVehicleStatusSelector(
                  selected: _status,
                  onChanged: (status) => setState(() => _status = status),
                ),
                const SizedBox(height: 20),
                AdminFormActionButtons(
                  onCancel: _cancel,
                  onSave: _save,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: AdminBottomNavigation(
          selectedIndex: AdminShellPage.indexKendaraan,
          onSelected: (index) => openAdminTab(context, index: index),
        ),
      ),
    );
  }

  /// Dipakai untuk field yang wajib diisi.
  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }
    return null;
  }
}

/// Area unggah foto: menampilkan placeholder saat kosong dan preview foto
/// yang sudah dipilih, lengkap dengan tombol "Ganti Foto".
class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.vehicle,
    required this.hasPhoto,
    required this.onTap,
  });

  final Vehicle vehicle;
  final bool hasPhoto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        key: const ValueKey('admin_vehicle_photo_area'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: AppColors.borderSoft),
          ),
          // Rasio dijaga 16:9 supaya tidak terlalu tinggi atau lebar.
          child: SizedBox(
            height: 96,
            child: hasPhoto
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _PreviewImage(vehicle: vehicle),
                      ),
                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          child: InkWell(
                            key: const ValueKey('admin_vehicle_change_photo'),
                            onTap: onTap,
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Text(
                                'Ganti Foto',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const Row(
                    children: [
                      SizedBox(width: 14),
                      Icon(
                        Icons.photo_camera_outlined,
                        size: 20,
                        color: Color(0xFFB4BCC4),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Tap untuk mengunggah foto',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF7D8791),
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _PreviewImage extends StatelessWidget {
  const _PreviewImage({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(vehicle.photoPath!),
      fit: BoxFit.cover,
      errorBuilder: (context, _, _) => const Icon(
        Icons.broken_image_outlined,
        size: 22,
        color: Color(0xFFB4BCC4),
      ),
    );
  }
}

/// Pesan validasi foto, muncul tepat di bawah area unggah.
class _PhotoError extends StatelessWidget {
  const _PhotoError({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }
    return const Padding(
      padding: EdgeInsets.only(top: 5),
      child: Text(
        'Foto kendaraan wajib diunggah',
        style: TextStyle(color: Color(0xFFD9534F), fontSize: 8.5),
      ),
    );
  }
}

/// Segmented control Mobil / Motor.
class _TypeSegmented extends StatelessWidget {
  const _TypeSegmented({required this.selected, required this.onChanged});

  final VehicleType selected;
  final ValueChanged<VehicleType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1F3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          for (final type in VehicleType.values)
            Expanded(
              child: _SegmentButton(
                label: type.label,
                active: type == selected,
                onTap: () => onChanged(type),
              ),
            ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Ink(
          key: ValueKey('admin_vehicle_type_${label.toLowerCase()}'),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : AppColors.primary,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
