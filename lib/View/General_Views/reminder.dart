import 'package:flutter/material.dart';
import 'package:tasknote/Controller/c_reminder.dart';
import 'package:tasknote/General/common_functions.dart';
import 'package:tasknote/General/theme.dart';
import 'package:tasknote/Model/Note/m_note.dart';
import 'package:tasknote/Model/m_reminder.dart';

class ReminderScreen extends StatefulWidget {
  final Note note;
  const ReminderScreen({super.key, required this.note});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final ReminderController _reminderController = ReminderController();

  // UI Logic: Pick Date and Time
  // ignore: unused_element
  Future<void> _pickDateAndTimeAndSchedule() async {
    // 1. Pick Date
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    // 2. Pick Time
    if (!mounted) return;
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    // 3. Combine
    final DateTime scheduledTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // 4. Create Model and Call Controller
    Reminder newTask = Reminder(
      title: widget.note.title,
      content: widget.note.content,
      reminderTime: scheduledTime,
    );

    await _reminderController.scheduleTaskReminder(newTask);

    if (!mounted) return;
    CommonFunctions.logger.d("Reminder set for $scheduledTime");
    Navigator.pop(context);
  }

  // UI Logic: Pin to Status Bar
  Future<void> _handlePinTask() async {
    Reminder newTask = Reminder(
      title: widget.note.title,
      content: widget.note.content,
    );
    await _reminderController.pinTaskToStatusBar(newTask);

    if (!mounted) return;
    CommonFunctions.logger.d("Note pinned to status bar!");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      height: CommonFunctions.getHeight(context, 0.45),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        color: isDark ? AppColors.dThirdColor : AppColors.lThirdColor,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Reminder Type",
                  style: theme.textTheme.bodyLarge!.copyWith(
                    fontSize: 25.0,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.cancel,
                  color: isDark ? AppColors.primary : Colors.white,
                ),
              ),
            ],
          ),
          Divider(thickness: 2.0, color: Colors.white),
          SizedBox(
            height: CommonFunctions.getHeight(context, 0.22),
            child: SingleChildScrollView(
              child: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: "Title:\n",
                      style: theme.textTheme.bodyMedium!.copyWith(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: widget.note.title,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: "\nContent:\n",
                      style: theme.textTheme.bodyMedium!.copyWith(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: widget.note.content,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: .spaceEvenly,
              children: [
                // Expanded(
                //   child: ElevatedButton.icon(
                //     onPressed: _pickDateAndTimeAndSchedule,
                //     icon: const Icon(Icons.alarm),
                //     label: const Text("Alarm"),
                //   ),
                // ),
                // SizedBox(width: CommonFunctions.getWidth(context, 0.1)),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handlePinTask,
                    icon: const Icon(Icons.push_pin),
                    label: const Text("Pin"),
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
