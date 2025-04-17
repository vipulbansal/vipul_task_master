import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePicker extends StatelessWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onDateTimeChanged;
  final String label;
  final String? helperText;
  final IconData icon;
  final bool showTime;

  const DateTimePicker({
    Key? key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateTimeChanged,
    this.label = 'Date',
    this.helperText,
    this.icon = Icons.calendar_today,
    this.showTime = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: initialDate,
      builder: (FormFieldState<DateTime> state) {
        // Format the current value
        final dateFormatter = DateFormat('MMM d, y');
        final timeFormatter = DateFormat('h:mm a');
        
        String formattedDate = dateFormatter.format(state.value!);
        String formattedTime = '';
        
        if (showTime) {
          formattedTime = timeFormatter.format(state.value!);
        }
        
        // Create the display text
        String displayText = formattedDate;
        if (showTime) {
          displayText += ' at $formattedTime';
        }
        
        return InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            helperText: helperText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: Icon(icon),
          ),
          child: InkWell(
            onTap: () async {
              // Show date picker
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: state.value!,
                firstDate: firstDate,
                lastDate: lastDate,
              );
              
              if (pickedDate != null) {
                // If not showing time, just use the date
                if (!showTime) {
                  state.didChange(pickedDate);
                  onDateTimeChanged(pickedDate);
                  return;
                }
                
                // If showing time, also show time picker
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(state.value!),
                );
                
                if (pickedTime != null) {
                  // Combine date and time
                  final newDateTime = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                  
                  state.didChange(newDateTime);
                  onDateTimeChanged(newDateTime);
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    displayText,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}