import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Ringkasan perjalanan kendaraan: jumlah perjalanan, total jarak, total
/// energi, dan total biaya.
class TravelSummaryCard extends StatelessWidget {
  const TravelSummaryCard({
    super.key,
    required this.tripCount,
    required this.totalDistance,
    required this.energyLabel,
    required this.totalEnergy,
    required this.totalCost,
    required this.costLabel,
  });

  final String tripCount;
  final String totalDistance;
  final String energyLabel;
  final String totalEnergy;
  final String totalCost;
  final String costLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SummaryMetric(value: tripCount, label: 'Perjalanan'),
              ),
              const MetricDivider(),
              Expanded(
                child: SummaryMetric(
                  value: totalDistance,
                  label: 'Total Jarak',
                ),
              ),
              const MetricDivider(),
              Expanded(
                child: SummaryMetric(value: totalEnergy, label: energyLabel),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.medium)),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.xs,
              children: [
                Text(
                  totalCost,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  costLabel,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryMetric extends StatelessWidget {
  const SummaryMetric({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: const TextStyle(color: AppColors.textSubtle, fontSize: 8),
        ),
      ],
    );
  }
}

class MetricDivider extends StatelessWidget {
  const MetricDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 30, color: AppColors.borderSoft);
  }
}
