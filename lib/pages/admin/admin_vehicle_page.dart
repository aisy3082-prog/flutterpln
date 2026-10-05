import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/vehicle.dart';
import '../../state/admin_vehicle_state.dart';
import '../../utils/constants.dart';
import '../../widgets/admin_bottom_navigation.dart';
import '../../widgets/admin_header_actions.dart';
import '../../widgets/vehicle_card.dart' show VehicleStatusBadge;
import '../../widgets/vehicle_photo.dart';
import 'admin_navigation.dart';
import 'admin_vehicle_detail_page.dart';
import 'admin_vehicle_form_page.dart';

/// Halaman "Daftar Kendaraan" milik Admin.
///
/// Berisi search, filter Mobil/Motor, tombol "+ Tambah", dan daftar card
/// kendaraan. Setiap card dapat ditekan untuk membuka Detail Kendaraan.
class AdminVehiclePage extends StatefulWidget {
  const AdminVehiclePage({super.key, this.embedded = false});

  /// Kalau true, navbar tidak ditampilkan karena host shell yang menanganinya.
  final bool embedded;

  @override
  State<AdminVehiclePage> createState() => _AdminVehiclePageState();
}

class _AdminVehiclePageState extends State<AdminVehiclePage> {
  final _searchController = TextEditingController();

  String _query = '';

  /// Default-nya Mobil, sesuai permintaan.
  late VehicleType _typeFilter = VehicleType.mobil;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Vehicle> _filtered(List<Vehicle> vehicles) => vehicles
      .where(
        (vehicle) =>
            vehicle.type == _typeFilter && vehicle.matches(_query),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final state = AdminVehicleStateScope.of(context);
    final vehicles = _filtered(state.vehicles);

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
        appBar: const AdminPageAppBar(title: 'Daftar Kendaraan'),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              _VehicleSearchField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
              ),
              _VehicleFilterBar(
                selected: _typeFilter,
                onSelected: (type) => setState(() => _typeFilter = type),
                onAdd: () => _openForm(context),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _typeFilter.label,
                    style: const TextStyle(
                      color: AppColors.textStrong,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: vehicles.isEmpty
                    ? const _EmptyVehicleState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                        itemCount: vehicles.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final vehicle = vehicles[index];
                          return AdminVehicleCard(
                            key: ValueKey(
                              'admin_vehicle_card_${vehicle.code}',
                            ),
                            vehicle: vehicle,
                            onTap: () => _openDetail(context, vehicle),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: widget.embedded
            ? null
            : AdminBottomNavigation(
                selectedIndex: AdminShellPage.indexKendaraan,
                onSelected: (index) => openAdminTab(context, index: index),
              ),
      ),
    );
  }

  void _openForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AdminVehicleFormPage()),
    );
  }

  /// Membuka Detail Kendaraan untuk kendaraan yang benar-benar ditekan.
  ///
  /// [pressed] adalah objek kendaraan milik card yang diketuk, sehingga card
  /// pertama membuka kendaraan pertama, card kedua membuka kendaraan kedua,
  /// dan seterusnya. Data terbaru diambil lagi dari state berdasarkan kode
  /// kendaraan; kalau tidak ditemukan, data milik card itu yang dipakai agar
  /// tap tidak pernah gagal tanpa keterangan apa pun.
  void _openDetail(BuildContext context, Vehicle pressed) {
    final state = AdminVehicleStateScope.of(context);
    final vehicle = state.byCode(pressed.code) ?? pressed;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdminVehicleDetailPage(vehicleCode: vehicle.code),
      ),
    );
  }
}

class _VehicleSearchField extends StatelessWidget {
  const _VehicleSearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: SizedBox(
        height: 40,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          style: const TextStyle(color: Color(0xFF2E3742), fontSize: 10),
          decoration: InputDecoration(
            hintText: 'Cari Kendaraan....',
            hintStyle: const TextStyle(color: Color(0xFF8A949E), fontSize: 10),
            prefixIcon: const Icon(Icons.search, size: 18),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            border: _border(AppColors.borderSoft),
            enabledBorder: _border(AppColors.borderSoft),
            focusedBorder: _border(AppColors.primary),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(9),
    borderSide: BorderSide(color: color),
  );
}

/// Tiga tombol: Mobil, Motor, dan "+ Tambah".
class _VehicleFilterBar extends StatelessWidget {
  const _VehicleFilterBar({
    required this.selected,
    required this.onSelected,
    required this.onAdd,
  });

  final VehicleType selected;
  final ValueChanged<VehicleType> onSelected;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          for (final type in VehicleType.values) ...[
            if (type != VehicleType.mobil) const SizedBox(width: 8),
            Expanded(
              child: _FilterButton(
                label: type.label,
                active: type == selected,
                onTap: () => onSelected(type),
              ),
            ),
          ],
          const SizedBox(width: 8),
          Expanded(
            child: _FilterButton(
              label: '+ Tambah',
              active: false,
              outline: true,
              onTap: onAdd,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.active,
    required this.onTap,
    this.outline = false,
  });

  final String label;
  final bool active;
  final bool outline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Tombol "+ Tambah" selalu bergaya outlined biru.
    final background = active ? AppColors.primary : Colors.white;
    final borderColor = active
        ? AppColors.primary
        : (outline ? AppColors.primary : AppColors.borderSoft);
    final textColor = active
        ? Colors.white
        : (outline ? AppColors.primary : const Color(0xFF7D8791));

    return SizedBox(
      height: 32,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 9.5,
                      fontWeight: active || outline
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Card kendaraan: foto, nama, kode, plat, kapasitas, status, dan chevron.
///
/// Seluruh isi card berada di dalam satu [InkWell], jadi bukan hanya ikon
/// panah yang dapat ditekan: seluruh area card adalah target tap yang sama.
class AdminVehicleCard extends StatelessWidget {
  const AdminVehicleCard({super.key, required this.vehicle, this.onTap});

  final Vehicle vehicle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final capacity = vehicle.capacity;

    return Semantics(
      button: true,
      label: 'Detail Kendaraan',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          // Warna ripple dibuat terlihat agar jelas saat card ditekan.
          splashColor: const Color(0x1F0B75D1),
          highlightColor: const Color(0x140B75D1),
          child: Ink(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSoft),
              boxShadow: AppShadows.card,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VehiclePhoto(
                  vehicle: vehicle,
                  width: 72,
                  height: 58,
                  fallbackIcon: vehicle.type == VehicleType.mobil
                      ? Icons.directions_car
                      : Icons.two_wheeler,
                  // Foto kendaraan berlatar putih, jadi diberi latar tipis
                  // supaya mobilnya tidak tenggelam di kartu putih.
                  backgroundColor: const Color(0xFFF1F5F9),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF20252B),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        vehicle.code,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF65707A),
                          fontSize: 8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        vehicle.plateNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF65707A),
                          fontSize: 8,
                        ),
                      ),
                      if (capacity != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Kapasitas $capacity orang',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF65707A),
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    VehicleStatusBadge(status: vehicle.status),
                    const SizedBox(height: 14),
                    const Icon(
                      Icons.chevron_right,
                      size: 19,
                      color: Color(0xFF7D8791),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyVehicleState extends StatelessWidget {
  const _EmptyVehicleState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 34, color: Color(0xFFB4BCC4)),
            SizedBox(height: AppSpacing.xl),
            Text(
              'Data kendaraan tidak ditemukan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF77818B),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Coba kata kunci lain atau pilih jenis kendaraan yang lain.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF9AA3AB), fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}
