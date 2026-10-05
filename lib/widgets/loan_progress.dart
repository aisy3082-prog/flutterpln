import 'package:flutter/material.dart';

import '../state/loan_state.dart';

class LoanProgress extends StatelessWidget {
  const LoanProgress({super.key, required this.status});

  final LoanStatus status;

  static const Color _active = Color(0xFF0B75D1);
  static const Color _inactive = Color(0xFFD3D8DE);

  static const List<IconData> _icons = [
    Icons.description_outlined,
    Icons.hourglass_empty,
    Icons.check_circle_outline,
    Icons.directions_car,
    Icons.check,
  ];

  @override
  Widget build(BuildContext context) {
    final activeIndex = status.index;

    return SizedBox(
      height: 62,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(LoanStatus.values.length * 2 - 1, (index) {
          if (index.isOdd) {
            final lineIndex = index ~/ 2;
            final completed = lineIndex < activeIndex;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(top: 19, left: 2, right: 2),
                color: completed ? _active : _inactive,
              ),
            );
          }

          final stageIndex = index ~/ 2;
          final isCompleted = stageIndex < activeIndex;
          final isActive = stageIndex == activeIndex;
          final circleColor = isCompleted || isActive ? _active : _inactive;

          return Expanded(
            child: Column(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                    border: isActive
                        ? Border.all(color: _active, width: 2)
                        : null,
                  ),
                  child: Icon(
                    _icons[stageIndex],
                    color: isCompleted || isActive
                        ? Colors.white
                        : const Color(0xFF7D8791),
                    size: 17,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    LoanStatus.values[stageIndex].label,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isCompleted || isActive
                          ? _active
                          : const Color(0xFF7D8791),
                      fontSize: 7,
                      height: 1.1,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
