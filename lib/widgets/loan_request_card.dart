import 'package:flutter/material.dart';

import '../models/loan_request.dart';
import '../utils/constants.dart';

/// Card pengajuan dengan status dan informasi prosesnya.
class LoanRequestCard extends StatelessWidget {
  const LoanRequestCard({
    super.key,
    required this.request,
    this.showProgress = true,
  });

  final LoanRequest request;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final isWaiting = request.status == LoanRequestStatus.menungguPersetujuan;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.number,
                      style: const TextStyle(
                        color: AppColors.textStrong,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      request.vehicleName,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _RequestRow(label: 'Kode Kendaraan', value: request.vehicleCode),
          _RequestRow(label: 'Nomor Plat', value: request.plateNumber),
          _RequestRow(label: 'Keperluan', value: request.purpose),
          _RequestRow(label: 'Tujuan', value: request.destination),
          _RequestRow(label: 'Tanggal Pengajuan', value: request.submittedAt),
          _RequestRow(label: 'Rencana Pinjam', value: request.borrowDate),
          _RequestRow(label: 'Rencana Kembali', value: request.returnDate),
          if (request.approver != null)
            _RequestRow(label: 'Disetujui Oleh', value: request.approver!),
          if (showProgress) ...[
            const SizedBox(height: AppSpacing.xs),
            _WaitingProgress(isWaiting: isWaiting),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final LoanRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground) = switch (status) {
      LoanRequestStatus.menungguPersetujuan => (
        const Color(0xFFFFF4E5),
        const Color(0xFFB26A00),
      ),
      LoanRequestStatus.disetujui => (
        const Color(0xFFE7F7EE),
        const Color(0xFF1B7F45),
      ),
      LoanRequestStatus.ditolak => (const Color(0xFFFDECEC), AppColors.danger),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: foreground,
          fontSize: 7,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSubtle, fontSize: 8),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textStrong,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaitingProgress extends StatelessWidget {
  const _WaitingProgress({required this.isWaiting});

  final bool isWaiting;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                isWaiting
                    ? Icons.hourglass_top_rounded
                    : Icons.check_circle_outline,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  isWaiting
                      ? 'Pengajuan sedang menunggu persetujuan atasan.'
                      : 'Pengajuan ini sudah selesai diproses.',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 8,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          if (isWaiting) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: const LinearProgressIndicator(
                value: 0.5,
                minHeight: 3,
                backgroundColor: AppColors.segmentedTrack,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
