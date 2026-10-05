import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/vehicle_maintenance_data.dart';
import '../../models/vehicle.dart';
import '../../models/vehicle_maintenance.dart';
import '../../state/admin_vehicle_state.dart';
import '../../utils/constants.dart';
import '../../widgets/admin_vehicle_detail_widgets.dart';
import 'admin_vehicle_edit_page.dart';

/// Halaman "Detail Kendaraan" milik Admin.
///
/// Menampilkan ringkasan kendaraan, tiga info singkat, riwayat perawatan, dan
/// tombol "Edit Kendaraan". Data selalu diambil dari state berdasarkan kode,
/// jadi halaman ini ikut berubah setelah kendaraan diedit.
class AdminVehicleDetailPage extends StatelessWidget {
  const AdminVehicleDetailPage({super.key, required this.vehicleCode});

  final String vehicleCode;

  @override
  Widget build(BuildContext context) {
    final state = AdminVehicleStateScope.of(context);
    final vehicle = state.byCode(vehicleCode);

    if (vehicle == null) {
      return const _MissingVehicleScaffold();
    }

    final maintenance = maintenanceOf(vehicle.code);

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
        appBar: const AdminVehicleAppBar(title: 'Detail Kendaraan'),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  children: [
                    AdminVehicleSummaryCard(vehicle: vehicle),
                    const SizedBox(height: 14),
                    _QuickFacts(vehicle: vehicle),
                    const SizedBox(height: 16),
                    _MaintenanceSection(items: maintenance),
                  ],
                ),
              ),
              // Tombol aksi tetap terlihat tanpa harus menggulir.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: AppColors.borderSoft),
                  ),
                ),
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    key: const ValueKey('admin_vehicle_edit_button'),
                    onPressed: () => _openEdit(context, vehicle.code),
                    icon: const Icon(Icons.edit_outlined, size: 15),
                    label: const Text('Edit Kendaraan'),
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEdit(BuildContext context, String code) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdminVehicleEditPage(vehicleCode: code),
      ),
    );
  }
}

/// Tiga kartu info singkat: bahan bakar, jumlah kursi, dan tahun produksi.
class _QuickFacts extends StatelessWidget {
  const _QuickFacts({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FactCard(
            icon: Icons.local_gas_station_outlined,
            label: 'Bensin',
            value: vehicle.fuelType.label,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _FactCard(
            icon: Icons.event_seat_outlined,
            label: '${vehicle.capacity ?? '-'} Seat',
            value: vehicle.engineCapacity,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _FactCard(
            icon: Icons.calendar_today_outlined,
            label: 'Tahun',
            value: '${vehicle.productionYear}',
          ),
        ),
      ],
    );
  }
}

class _FactCard extends StatelessWidget {
  const _FactCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: AppColors.primary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textStrong,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bagian "Informasi Perawatan" berisi riwayat perawatan kendaraan.
class _MaintenanceSection extends StatelessWidget {
  const _MaintenanceSection({required this.items});

  final List<VehicleMaintenance> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AdminVehicleSectionTitle('Informasi Perawatan'),
        const SizedBox(height: 10),
        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: const Center(
              child: Text(
                'Belum ada riwayat perawatan',
                style: TextStyle(color: AppColors.textSubtle, fontSize: 9),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFEDEFF1),
                    ),
                  _MaintenanceRow(item: items[i]),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _MaintenanceRow extends StatelessWidget {
  const _MaintenanceRow({required this.item});

  final VehicleMaintenance item;

  @override
  Widget build(BuildContext context) {
    final done = item.status == MaintenanceStatus.selesai;
    final color = switch (item.status) {
      MaintenanceStatus.selesai => const Color(0xFF35A744),
      MaintenanceStatus.berjalan => const Color(0xFFE8730C),
      MaintenanceStatus.terjadwal => const Color(0xFF8A949E),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.schedule,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textStrong,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.date,
                  style: const TextStyle(
                    color: AppColors.textSubtle,
                    fontSize: 7.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              item.status.label,
              style: TextStyle(
                color: color,
                fontSize: 7.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingVehicleScaffold extends StatelessWidget {
  const _MissingVehicleScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminVehicleAppBar(title: 'Detail Kendaraan'),
      body: const Center(
        child: Text(
          'Data kendaraan tidak ditemukan',
          style: TextStyle(color: AppColors.textSubtle, fontSize: 10),
        ),
      ),
    );
  }
}
