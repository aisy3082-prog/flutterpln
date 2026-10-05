import 'package:flutter/material.dart';

import '../services/history_service.dart';
import '../utils/constants.dart';
import 'state_views.dart';

/// Conditional rendering untuk empat kondisi data:
/// loading, ada data, tidak ada data, dan error.
///
/// Tidak perlu membuat halaman terpisah untuk tiap kondisi; cukup pilih
/// branch berdasarkan `result`.
class AsyncStateBuilder<T> extends StatelessWidget {
  const AsyncStateBuilder({
    super.key,
    required this.result,
    required this.builder,
    this.onRetry,
    this.emptyTitle = 'Data tidak tersedia',
    this.emptyDescription = 'Belum ada data untuk ditampilkan.',
    this.emptyIcon = Icons.inbox_outlined,
    this.wrapEmptyInCard = false,
  });

  final DataResult<T> result;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback? onRetry;
  final String emptyTitle;
  final String emptyDescription;
  final IconData emptyIcon;
  final bool wrapEmptyInCard;

  @override
  Widget build(BuildContext context) {
    switch (result.status) {
      case DataStatus.loading:
        return const LoadingStateView();
      case DataStatus.error:
        return ErrorStateView(
          message:
              result.errorMessage ?? 'Terjadi kesalahan. Silakan coba lagi.',
          onRetry: onRetry ?? () {},
        );
      case DataStatus.empty:
        return _empty(context);
      case DataStatus.success:
        final data = result.data;
        if (data == null) {
          return _empty(context);
        }
        return builder(context, data);
    }
  }

  Widget _empty(BuildContext context) {
    final view = EmptyStateView(
      title: emptyTitle,
      description: emptyDescription,
      icon: emptyIcon,
    );
    if (!wrapEmptyInCard) {
      return view;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: EmptyStateCard(
        title: emptyTitle,
        description: emptyDescription,
        icon: emptyIcon,
      ),
    );
  }
}

/// Card putih dengan border yang konsisten untuk membungkus empty state
/// pada halaman status.
class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.inbox_outlined,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: EmptyStateView(title: title, description: description, icon: icon),
    );
  }
}
