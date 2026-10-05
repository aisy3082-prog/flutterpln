import 'package:flutter/material.dart';

import '../models/vehicle.dart';

const _filterActiveBlue = Color(0xFF0B75D1);
const _filterBorder = Color(0xFFDCE1E6);
const _filterMuted = Color(0xFF7D8791);

class VehicleFilterBar extends StatelessWidget {
  const VehicleFilterBar({
    super.key,
    required this.selectedType,
    required this.selectedStatus,
    required this.onTypeChanged,
    required this.onStatusChanged,
  });

  final VehicleType? selectedType;
  final VehicleStatus? selectedStatus;
  final ValueChanged<VehicleType?> onTypeChanged;
  final ValueChanged<VehicleStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _FilterButton(
            label: 'Semua',
            selected: selectedType == null,
            onTap: () => onTypeChanged(null),
          ),
          const SizedBox(width: 8),
          _FilterButton(
            label: 'Mobil',
            selected: selectedType == VehicleType.mobil,
            onTap: () => onTypeChanged(VehicleType.mobil),
          ),
          const SizedBox(width: 8),
          _FilterButton(
            label: 'Motor',
            selected: selectedType == VehicleType.motor,
            onTap: () => onTypeChanged(VehicleType.motor),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<VehicleStatus>(
            tooltip: 'Filter status kendaraan',
            onSelected: onStatusChanged,
            itemBuilder: (context) => VehicleStatus.values
                .map(
                  (status) => PopupMenuItem<VehicleStatus>(
                    value: status,
                    child: Text(status.label),
                  ),
                )
                .toList(),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 11),
              decoration: BoxDecoration(
                color: selectedStatus == null
                    ? Colors.white
                    : _filterActiveBlue,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selectedStatus == null
                      ? _filterBorder
                      : _filterActiveBlue,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedStatus?.label ?? 'Tersedia',
                    style: TextStyle(
                      color: selectedStatus == null
                          ? _filterMuted
                          : Colors.white,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 15,
                    color: selectedStatus == null ? _filterMuted : Colors.white,
                  ),
                ],
              ),
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
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _filterActiveBlue : Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: 36,
          width: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? _filterActiveBlue : _filterBorder,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : _filterMuted,
                fontSize: 9,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
