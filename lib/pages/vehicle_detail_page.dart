import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../widgets/vehicle_card.dart';
import '../widgets/vehicle_photo.dart';

class VehicleDetailPage extends StatelessWidget {
  const VehicleDetailPage({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Detail Kendaraan',
          style: TextStyle(
            color: Color(0xFF20252B),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE1E5E8)),
                ),
                // `VehiclePhoto` dipakai supaya foto hasil unggahan dari
                // perangkat ikut tampil, bukan hanya foto dari assets.
                child: VehiclePhoto(vehicle: vehicle, fit: BoxFit.contain),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE1E5E8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vehicle.name,
                            style: const TextStyle(
                              color: Color(0xFF20252B),
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        VehicleStatusBadge(status: vehicle.status),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(label: 'Kode Kendaraan', value: vehicle.code),
                    const SizedBox(height: 10),
                    _DetailRow(
                      label: 'Nomor Kendaraan',
                      value: vehicle.plateNumber,
                    ),
                    if (vehicle.capacity != null) ...[
                      const SizedBox(height: 10),
                      _DetailRow(
                        label: 'Kapasitas',
                        value: '${vehicle.capacity} orang',
                      ),
                    ],
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 112,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF77818B), fontSize: 10),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF20252B),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
