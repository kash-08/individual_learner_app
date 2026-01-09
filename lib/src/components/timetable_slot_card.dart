import 'package:flutter/material.dart';
import '../models/timetable_model.dart';

class TimetableSlotCard extends StatelessWidget {
  final TimetableSlot slot;
  final Function(bool) onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TimetableSlotCard({
    super.key,
    required this.slot,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(slot.colorHex.substring(1, 7),
        radix: 16) + 0xFF000000);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: slot.isCompleted
              ? Colors.green.withOpacity(0.5)
              : color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: slot.isCompleted,
                        onChanged: (value) => onToggleComplete(value ?? false),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slot.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: slot.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (slot.description.isNotEmpty)
                              Text(
                                slot.description,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.grey),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${slot.startTime.format(context)} - ${slot.endTime.format(context)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 12),
                if (slot.isRecurring)
                  Row(
                    children: [
                      Icon(
                        Icons.repeat,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getRecurringText(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (slot.isRecurring) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: slot.recurringDays.map((day) {
                  return Chip(
                    label: Text(_getDayName(day)),
                    labelStyle: const TextStyle(fontSize: 10),
                    backgroundColor: color.withOpacity(0.1),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: slot.isCompleted ? 1.0 : 0.0,
              backgroundColor: Colors.grey[200],
              color: slot.isCompleted ? Colors.green : color,
              minHeight: 4,
            ),
          ],
        ),
      ),
    );
  }

  String _getRecurringText() {
    if (slot.recurringEndDate != null) {
      return 'Until ${slot.recurringEndDate!.day}/${slot.recurringEndDate!.month}';
    }
    return 'Weekly';
  }

  String _getDayName(int dayNumber) {
    switch (dayNumber) {
      case 1: return 'M';
      case 2: return 'T';
      case 3: return 'W';
      case 4: return 'T';
      case 5: return 'F';
      case 6: return 'S';
      case 7: return 'S';
      default: return '';
    }
  }
}