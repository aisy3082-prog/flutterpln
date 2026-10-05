import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../widgets/route_map_placeholder.dart';
import 'trip_completion_page.dart';

class TripDetailPage extends StatelessWidget {
  const TripDetailPage({super.key, required this.vehicle});

  final Vehicle vehicle;

  void _showRouteDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Detail Rute',
                  style: TextStyle(
                    color: Color(0xFF20252B),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                const RouteMapPlaceholder(height: 150),
                const SizedBox(height: 12),
                const _RouteInfoRow(label: 'Asal', value: 'UPJS Magdalena'),
                const SizedBox(height: 6),
                const _RouteInfoRow(label: 'Tujuan', value: 'Bala Desa Gkreeg'),
                const SizedBox(height: 6),
                const _RouteInfoRow(label: 'Jarak', value: '8.5 Km'),
                const SizedBox(height: 6),
                const _RouteInfoRow(label: 'Estimasi', value: '12 menit'),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, size: 20),
          tooltip: 'Kembali',
        ),
        title: const Text(
          'Detail Perjalanan',
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
              _TripVehicleCard(vehicle: vehicle),
              const SizedBox(height: 14),
              const RouteMapPlaceholder(height: 205),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TripMetric(label: 'Jarak', value: '8.5 Km'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TripMetric(
                      label: 'Estimasi Time',
                      value: '12 menit',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => TripCompletionPage(vehicle: vehicle),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B75D1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Selesai Perjalanan'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 42,
                child: OutlinedButton(
                  onPressed: () => _showRouteDetails(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF6E6E73),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Lihat detail rute'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripVehicleCard extends StatelessWidget {
  const _TripVehicleCard({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFDCE1E6)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            height: 52,
            child: Image.asset(
              vehicle.imageAsset,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.name,
                  style: const TextStyle(
                    color: Color(0xFF20252B),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${vehicle.code}   ${vehicle.plateNumber}',
                  style: const TextStyle(color: Color(0xFF65707A), fontSize: 8),
                ),
                if (vehicle.capacity != null)
                  Text(
                    'Kapasitas ${vehicle.capacity} Orang',
                    style: const TextStyle(
                      color: Color(0xFF65707A),
                      fontSize: 8,
                    ),
                  ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF7D8791), size: 19),
        ],
      ),
    );
  }
}

class _TripMetric extends StatelessWidget {
  const _TripMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDCE1E6)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF77818B), fontSize: 8),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF20252B),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteInfoRow extends StatelessWidget {
  const _RouteInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 74,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF77818B), fontSize: 9),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF20252B),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
