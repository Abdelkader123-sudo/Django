// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');

  return '$year-$month-$day $hour:$minute';
}

class AnalyticsSearchForm extends StatelessWidget {
  final int selectedGrandeur;
  final DateTime start;
  final DateTime end;

  final ValueChanged<int> onGrandeurChanged;
  final ValueChanged<DateTime> onStartChanged;
  final ValueChanged<DateTime> onEndChanged;
  final VoidCallback onSearch;

  const AnalyticsSearchForm({
    super.key,
    required this.selectedGrandeur,
    required this.start,
    required this.end,
    required this.onGrandeurChanged,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              initialValue: selectedGrandeur,
              decoration: const InputDecoration(
                labelText: 'Grandeur',
              ),
              items: const [
                DropdownMenuItem(
                  value: 1,
                  child: Text('Temperature'),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text('Humidity'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  onGrandeurChanged(value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: ValueKey(start),
              readOnly: true,
              initialValue: _formatDateTime(start),
              decoration: const InputDecoration(
                labelText: 'Start DateTime',
                prefixIcon: Icon(Icons.schedule),
              ),
              onTap: () async {
                final picked = await _pickDateTime(context, start);

                if (!context.mounted) {
                  return;
                }

                if (picked != null) {
                  onStartChanged(picked);
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: ValueKey(end),
              readOnly: true,
              initialValue: _formatDateTime(end),
              decoration: const InputDecoration(
                labelText: 'End DateTime',
                prefixIcon: Icon(Icons.schedule),
              ),
              onTap: () async {
                final picked = await _pickDateTime(context, end);

                if (!context.mounted) {
                  return;
                }

                if (picked != null) {
                  onEndChanged(picked);
                }
              },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onSearch,
              icon: const Icon(Icons.search),
              label: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<DateTime?> _pickDateTime(
  BuildContext context,
  DateTime initial,
) async {
  if (!context.mounted) {
    return null;
  }

  final date = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
  );

  if (date == null) {
    return null;
  }

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(
      hour: initial.hour,
      minute: initial.minute,
    ),
  );

  if (time == null) {
    return null;
  }

  return DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
}