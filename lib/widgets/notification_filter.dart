import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Baris filter "Semua / Belum dibaca / Dibaca".
///
/// Tab aktif memakai biru solid; tab lain putih dengan border abu-abu.
class NotificationFilterBar extends StatelessWidget {
  const NotificationFilterBar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = ['Semua', 'Belum dibaca', 'Dibaca'];

    return Row(
      children: List.generate(labels.length, (index) {
        final selected = selectedIndex == index;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == labels.length - 1 ? 0 : AppSpacing.md,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.textStrong,
                      fontSize: 9,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
