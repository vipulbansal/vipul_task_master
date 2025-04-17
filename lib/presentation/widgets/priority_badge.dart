import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/task_model.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriorityModel priority;
  final bool isCompleted;
  final bool showLabel;
  final double height;

  const PriorityBadge({
    Key? key,
    required this.priority,
    this.isCompleted = false,
    this.showLabel = true,
    this.height = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _getBackgroundColor(context),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPriorityIcon(),
            size: height * 0.7,
            color: _getTextColor(context),
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              _getPriorityLabel(),
              style: TextStyle(
                fontSize: height * 0.6,
                color: _getTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    if (isCompleted) {
      return Colors.grey.withOpacity(0.3);
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    switch (priority) {
      case TaskPriorityModel.high:
        return isDarkMode ? Colors.red.shade800 : Colors.red.shade100;
      case TaskPriorityModel.medium:
        return isDarkMode ? Colors.orange.shade800 : Colors.orange.shade100;
      case TaskPriorityModel.low:
        return isDarkMode ? Colors.green.shade800 : Colors.green.shade100;
    }
  }

  Color _getTextColor(BuildContext context) {
    if (isCompleted) {
      return Colors.grey;
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    switch (priority) {
      case TaskPriorityModel.high:
        return isDarkMode ? Colors.red.shade200 : Colors.red.shade700;
      case TaskPriorityModel.medium:
        return isDarkMode ? Colors.orange.shade200 : Colors.orange.shade700;
      case TaskPriorityModel.low:
        return isDarkMode ? Colors.green.shade200 : Colors.green.shade700;
    }
  }

  IconData _getPriorityIcon() {
    switch (priority) {
      case TaskPriorityModel.high:
        return Icons.flag;
      case TaskPriorityModel.medium:
        return Icons.flag;
      case TaskPriorityModel.low:
        return Icons.flag;
    }
  }

  String _getPriorityLabel() {
    switch (priority) {
      case TaskPriorityModel.high:
        return 'High';
      case TaskPriorityModel.medium:
        return 'Medium';
      case TaskPriorityModel.low:
        return 'Low';
    }
  }
}