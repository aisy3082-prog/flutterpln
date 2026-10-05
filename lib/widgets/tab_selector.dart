import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Tab selector reusable (Perjalanan/Energi, BBM/Listrik, dan sejenisnya).
class TabSelector extends StatelessWidget {
  const TabSelector({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.segmentedTrack,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Row(
        children: List.generate(
          labels.length,
          (index) => Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(index),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectedIndex == index
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  labels[index],
                  style: TextStyle(
                    color: selectedIndex == index
                        ? Colors.white
                        : const Color(0xFF5C6670),
                    fontSize: 10,
                    fontWeight: selectedIndex == index
                        ? FontWeight.w600
                        : FontWeight.w400,
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
