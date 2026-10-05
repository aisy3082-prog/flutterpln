import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../utils/constants.dart';

/// Label field pada form kendaraan.
class AdminFormLabel extends StatelessWidget {
  const AdminFormLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textStrong,
        fontSize: 9,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Field teks form kendaraan, lengkap dengan label dan gaya input yang sama
/// dengan halaman Tambah Kendaraan.
class AdminTextFieldBox extends StatelessWidget {
  const AdminTextFieldBox({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminFormLabel(label),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          style: const TextStyle(color: Color(0xFF2E3742), fontSize: 9.5),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9AA3AB), fontSize: 9.5),
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 10,
            ),
            border: _border(AppColors.borderSoft),
            enabledBorder: _border(AppColors.borderSoft),
            focusedBorder: _border(AppColors.primary),
            errorBorder: _border(const Color(0xFFD9534F)),
            focusedErrorBorder: _border(const Color(0xFFD9534F)),
            errorStyle: const TextStyle(
              color: Color(0xFFD9534F),
              fontSize: 7.5,
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color),
  );
}

/// Dropdown untuk field "Kapasitas Mesin".
///
/// Pilihan menyesuaikan jenis kendaraan: cc untuk motor, liter untuk mobil.
class AdminEngineCapacityDropdown extends StatelessWidget {
  const AdminEngineCapacityDropdown({
    super.key,
    required this.value,
    required this.type,
    required this.onChanged,
    this.label = 'Kapasitas Mesin',
  });

  static const List<String> motorOptions = [
    '85 cc',
    '100 cc',
    '110 cc',
    '115 cc',
    '125 cc',
    '150 cc',
  ];

  static const List<String> mobilOptions = [
    '1.3 L',
    '1.5 L',
    '2.0 L',
    '2.4 L',
    '3.0 L',
  ];

  final String value;
  final VehicleType type;
  final ValueChanged<String> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    // Nilai lama tetap bisa dipilih walau tidak ada di daftar.
    final options = <String>[
      ...(type == VehicleType.motor ? motorOptions : mobilOptions),
      if (!(type == VehicleType.motor ? motorOptions : mobilOptions).contains(
        value,
      ))
        value,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminFormLabel(label),
        const SizedBox(height: 5),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              key: const ValueKey('admin_engine_capacity_dropdown'),
              value: value,
              isExpanded: true,
              isDense: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: Color(0xFF7D8791),
              ),
              style: const TextStyle(color: Color(0xFF2E3742), fontSize: 9.5),
              items: [
                for (final option in options)
                  DropdownMenuItem(
                    value: option,
                    child: Text(
                      option,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF2E3742),
                        fontSize: 9.5,
                      ),
                    ),
                  ),
              ],
              onChanged: (selected) {
                if (selected != null) {
                  onChanged(selected);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Dropdown "Jenis Bahan Bakar".
class AdminFuelDropdown extends StatelessWidget {
  const AdminFuelDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final VehicleFuelType value;
  final ValueChanged<VehicleFuelType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminFormLabel('Jenis Bahan Bakar'),
        const SizedBox(height: 5),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<VehicleFuelType>(
              key: const ValueKey('admin_vehicle_fuel_dropdown'),
              value: value,
              isExpanded: true,
              isDense: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: Color(0xFF7D8791),
              ),
              style: const TextStyle(color: Color(0xFF2E3742), fontSize: 9.5),
              items: [
                for (final fuel in VehicleFuelType.values)
                  DropdownMenuItem(
                    value: fuel,
                    child: Text(
                      fuel.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF2E3742),
                        fontSize: 9.5,
                      ),
                    ),
                  ),
              ],
              onChanged: (selected) {
                if (selected != null) {
                  onChanged(selected);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Pemilih "Status Kendaraan" dengan tiga pilihan radio.
///
/// Warna latar pilihan yang aktif mengikuti statusnya: hijau untuk
/// Tersedia, oranye untuk Dalam Perawatan, abu-abu untuk Tidak Tersedia.
class AdminVehicleStatusSelector extends StatelessWidget {
  const AdminVehicleStatusSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final VehicleStatus selected;
  final ValueChanged<VehicleStatus> onChanged;

  static const Map<VehicleStatus, (String, String)> options = {
    VehicleStatus.tersedia: (
      'Tersedia',
      'Siap digunakan untuk peminjaman',
    ),
    VehicleStatus.perawatan: (
      'Dalam Perawatan',
      'Sedang dalam proses perawatan',
    ),
    VehicleStatus.digunakan: ('Tidak Tersedia', 'Tidak dapat digunakan'),
  };

  static Color accentOf(VehicleStatus status) => switch (status) {
    VehicleStatus.tersedia => const Color(0xFF1E9B3B),
    VehicleStatus.perawatan => const Color(0xFFE8730C),
    VehicleStatus.digunakan => const Color(0xFF9AA3AB),
  };

  static Color highlightOf(VehicleStatus status) => switch (status) {
    VehicleStatus.tersedia => const Color(0xFFF1FAF3),
    VehicleStatus.perawatan => const Color(0xFFFDF1E7),
    VehicleStatus.digunakan => const Color(0xFFF5F6F7),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AdminFormLabel('Status Kendaraan'),
          const SizedBox(height: 10),
          for (final entry in options.entries)
            _StatusOption(
              status: entry.key,
              title: entry.value.$1,
              description: entry.value.$2,
              selected: entry.key == selected,
              onTap: () => onChanged(entry.key),
            ),
        ],
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.status,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final VehicleStatus status;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = AdminVehicleStatusSelector.accentOf(status);

    return Material(
      color: selected
          ? AdminVehicleStatusSelector.highlightOf(status)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        key: ValueKey('admin_vehicle_status_${status.name}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 15,
                color: selected ? accent : const Color(0xFF8A949E),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: selected ? accent : AppColors.textStrong,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppColors.textSubtle,
                        fontSize: 8.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dua tombol aksi form: Batal (outlined) dan Simpan (filled).
class AdminFormActionButtons extends StatelessWidget {
  const AdminFormActionButtons({
    super.key,
    required this.onCancel,
    required this.onSave,
    this.cancelLabel = 'Batal',
    this.saveLabel = 'Simpan',
  });

  final VoidCallback onCancel;
  final VoidCallback onSave;
  final String cancelLabel;
  final String saveLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 40,
            child: OutlinedButton(
              key: const ValueKey('admin_vehicle_cancel_button'),
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(cancelLabel),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 40,
            child: ElevatedButton(
              key: const ValueKey('admin_vehicle_save_button'),
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(saveLabel),
            ),
          ),
        ),
      ],
    );
  }
}
