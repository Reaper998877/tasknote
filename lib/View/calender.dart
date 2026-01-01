import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tasknote/General/common_functions.dart';
import 'package:tasknote/General/stateless_widgets.dart';
import 'package:tasknote/General/theme.dart';
import 'package:tasknote/Model/Note/m_note.dart';
import 'package:tasknote/Service/share.dart';
import 'package:tasknote/Service/shared_pref.dart';
import 'package:tasknote/View/Add_Edit/add_edit_note.dart';
import 'package:tasknote/View/General_Views/reminder.dart';
import 'package:tasknote/View/General_Views/splash.dart';

class CalenderNoteScreen extends StatefulWidget {
  const CalenderNoteScreen({super.key});

  @override
  State<CalenderNoteScreen> createState() => _CalenderNoteScreenState();
}

class _CalenderNoteScreenState extends State<CalenderNoteScreen> {
  String sort = "Last updated";
  late Stream<List<Note>> _calNotesStream;

  DateTime _selectedDT = DateTime.now(); // Selected day
  DateTime _focusedDT = DateTime.now(); // Focused day / Current Month

  @override
  void initState() {
    super.initState();
    _calNotesStream = noteController.listenToCalNoteSchema(sort);
    initializeSort();
  }

  void initializeSort() async {
    final String sortType = await SharedPrefService.getCalSortType();
    if (sortType != "") {
      setState(() {
        sort = sortType;
      });
      CommonFunctions.logger.d(sort);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: StreamBuilder<List<Note>>(
          stream: _calNotesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final sortedCalNoteList = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar(
                rowHeight: MediaQuery.sizeOf(context).height / 10,
                daysOfWeekHeight: MediaQuery.sizeOf(context).height / 20,
                focusedDay: _focusedDT,
                pageJumpingEnabled: true,
                selectedDayPredicate: (day) => isSameDay(_selectedDT, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDT = selectedDay;
                    _focusedDT = focusedDay;
                  });

                  showDialog(
                    context: context,
                    builder: (context) {
                      return OptionDialog(
                        todaysDate: noteController.formatDate(_selectedDT),
                        selectedDT: _selectedDT,
                        sortedCalNoteList: sortedCalNoteList,
                      );
                    },
                  );
                },
                eventLoader: (currentDT) {
                  return noteController.getCalNotesForDay(
                    sortedCalNoteList: sortedCalNoteList,
                    current: currentDT,
                  );
                  // Return events for each day if exists.
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDT = focusedDay;
                  });
                },
                firstDay: DateTime.utc(2000, 01, 01),
                lastDay: DateTime.utc(_selectedDT.year + 75, 12, 31),
                calendarFormat: CalendarFormat.month,
                daysOfWeekStyle: AppTheme.daysOfWeekStyle(
                  borderColor: isDark ? Colors.white : Colors.black,
                  textColor: isDark ? AppColors.primary : AppColors.lThirdColor,
                ),

                calendarStyle: AppTheme.calendarStyle(
                  textColor: isDark ? Colors.white : Colors.black,
                  borderColor: isDark ? Colors.grey : Colors.white,
                ),
                headerStyle: AppTheme.headerStyle(
                  titleColor: isDark ? Colors.white : Colors.black,
                ),
                onHeaderTapped: (DateTime d) async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDT,
                    firstDate: DateTime.utc(2000, 01, 01),
                    lastDate: DateTime.utc(d.year + 75, 12, 31),
                  );

                  if (picked != null && picked != _selectedDT) {
                    setState(() {
                      _selectedDT = picked;
                      _focusedDT =
                          picked; // Optional: Update focused day as well
                    });
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class OptionDialog extends StatelessWidget {
  final String todaysDate;
  final DateTime selectedDT;
  final List<Note> sortedCalNoteList;
  const OptionDialog({
    super.key,
    required this.todaysDate,
    required this.selectedDT,
    required this.sortedCalNoteList,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(todaysDate, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Future.delayed(Duration(seconds: 1));
              Navigator.pushNamed(
                context,
                '/add_edit_note',
                arguments: AddEditNoteArgs(
                  edit: false,
                  calNote: true,
                  selected: selectedDT,
                ),
              );
            },
            child: Text("Add Note"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Future.delayed(Duration(seconds: 1));
              showModalBottomSheet(
                context: context,
                isDismissible: false,
                isScrollControlled: true,
                builder: (context) {
                  return ViewNoteDialog(
                    sortedCalNoteList: sortedCalNoteList,
                    selectedDT: selectedDT,
                  );
                },
              );
            },
            child: Text("View Notes"),
          ),
        ],
      ),
    );
  }
}

class ViewNoteDialog extends StatefulWidget {
  final List<Note> sortedCalNoteList;
  final DateTime selectedDT;
  const ViewNoteDialog({
    super.key,
    required this.sortedCalNoteList,
    required this.selectedDT,
  });

  @override
  State<ViewNoteDialog> createState() => _ViewNoteDialogState();
}

class _ViewNoteDialogState extends State<ViewNoteDialog> {
  List<String> selectedNoteUidList = [];
  List<Note> notesForDay = [];
  CommonFunctions cf = CommonFunctions();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final check = noteController
        .getCalNotesForDay(
          sortedCalNoteList: widget.sortedCalNoteList,
          current: widget.selectedDT,
        )
        .isEmpty;
    if (!check) {
      notesForDay = noteController.getCalNotesForDay(
        sortedCalNoteList: widget.sortedCalNoteList,
        current: widget.selectedDT,
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        gradient: isDark ? AppTheme.darkGradient : AppTheme.lightGradient,
      ),
      height: check
          ? CommonFunctions.getHeight(context, 0.2)
          : CommonFunctions.getHeight(context, 0.5),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: CommonFunctions.getWidth(context, 0.1)),
              Expanded(
                child: Text(
                  "Notes",
                  style: theme.textTheme.bodyMedium!.copyWith(fontSize: 20.0),
                  textAlign: TextAlign.start,
                ),
              ),
              Align(
                alignment: AlignmentGeometry.topRight,
                child: Row(
                  spacing: 10.0,
                  children: [
                    // Show selected count
                    if (selectedNoteUidList.isNotEmpty)
                      SelectedNoteCount(
                        text:
                            "${selectedNoteUidList.length} / ${noteController.getCalNotesForDay(sortedCalNoteList: widget.sortedCalNoteList, current: widget.selectedDT).length}",
                      ),

                    // Delete Multiple cal note
                    if (selectedNoteUidList.isNotEmpty)
                      IconButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return DeleteConfirmation(
                                singleDeletion: selectedNoteUidList.length > 1
                                    ? false
                                    : true,
                                yesAction: () async {
                                  await noteController.deleteMultipleNotes(
                                    uidlist: selectedNoteUidList,
                                  );
                                  selectedNoteUidList.clear();
                                },
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.delete),
                      ),
                    // Add calnote
                    if (selectedNoteUidList.isEmpty)
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            '/add_edit_note',
                            arguments: AddEditNoteArgs(
                              edit: false,
                              calNote: true,
                              selected: widget.selectedDT,
                            ),
                          );
                        },
                        icon: Icon(Icons.note_add_rounded),
                      ),
                    // Cancel Dialog
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (selectedNoteUidList.isNotEmpty) {
                          selectedNoteUidList.clear();
                        }
                      },
                      icon: selectedNoteUidList.isEmpty
                          ? Icon(Icons.cancel)
                          : Icon(Icons.cancel, color: theme.colorScheme.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (check) Expanded(child: Center(child: Text("No notes added"))),

          if (!check)
            SizedBox(
              height: CommonFunctions.getHeight(context, 0.4),
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                physics: BouncingScrollPhysics(),

                children: noteController
                    .getCalNotesForDay(
                      sortedCalNoteList: widget.sortedCalNoteList,
                      current: widget.selectedDT,
                    )
                    .map(
                      (note) => GestureDetector(
                        onLongPress: selectedNoteUidList.isEmpty
                            ? () {
                                setState(() {
                                  selectedNoteUidList.add(note.uid.toString());
                                });
                              }
                            : null,
                        onTap: selectedNoteUidList.isEmpty
                            ? () {
                                Navigator.pop(context);
                                // Edit
                                Navigator.pushNamed(
                                  context,
                                  '/add_edit_note',
                                  arguments: AddEditNoteArgs(
                                    edit: true,
                                    eNote: note,
                                    calNote: true,
                                  ),
                                );
                              }
                            : () {
                                // When any note is selected.
                                if (selectedNoteUidList.contains(
                                  note.uid.toString(),
                                )) {
                                  setState(() {
                                    selectedNoteUidList.remove(
                                      note.uid.toString(),
                                    );
                                  });
                                } else {
                                  setState(() {
                                    selectedNoteUidList.add(
                                      note.uid.toString(),
                                    );
                                  });
                                }
                              },
                        child: Container(
                          decoration:
                              selectedNoteUidList.contains(note.uid.toString())
                              ? BoxDecoration(
                                  border: Border.all(
                                    color: cf.isDark
                                        ? AppColors.lFirstColor
                                        : AppColors.dThirdColor,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                )
                              : null,
                          margin: EdgeInsets.symmetric(vertical: 6.0),
                          height: CommonFunctions.getHeight(context, 0.2),

                          child: Stack(
                            children: [
                              SizedBox(
                                width: CommonFunctions.getWidth(context, 1),
                                child: Card(
                                  elevation:
                                      selectedNoteUidList.contains(
                                        note.uid.toString(),
                                      )
                                      ? 0
                                      : 5.0,
                                  child: Padding(
                                    padding: EdgeInsetsGeometry.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: CommonFunctions.getWidth(
                                            context,
                                            0.65,
                                          ),
                                          child: NoteTitle(title: note.title),
                                        ),
                                        SizedBox(height: 5.0),
                                        NoteContent(content: note.content),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: Row(
                                  mainAxisSize: .min,
                                  mainAxisAlignment: .end,
                                  children: [
                                    // Note Reminder
                                    if (selectedNoteUidList.length == 1 &&
                                        selectedNoteUidList.contains(
                                          note.uid.toString(),
                                        ))
                                      IconButton(
                                        onPressed: () async {
                                          await showModalBottomSheet<String>(
                                            useSafeArea: true,
                                            isDismissible: false,
                                            isScrollControlled: true,
                                            shape:
                                                AppTheme.roundedRectangleBorder(),
                                            context: context,
                                            builder: (context) =>
                                                ReminderScreen(note: note),
                                          );
                                          setState(() {
                                            selectedNoteUidList.clear();
                                          });
                                          Navigator.pop(context);
                                        },
                                        icon: Icon(Icons.notifications),
                                      ),
                                    // Share note
                                    if (selectedNoteUidList.length == 1 &&
                                        selectedNoteUidList.contains(
                                          note.uid.toString(),
                                        ))
                                      IconButton(
                                        onPressed: () async {
                                          final result =
                                              await ShareService.shareText(
                                                "${note.title}\n${note.content}",
                                              );
                                          if (result.status ==
                                              ShareResultStatus.success) {
                                            CommonFunctions.logger.d('Sent');
                                            setState(() {
                                              selectedNoteUidList.clear();
                                            });
                                            Navigator.pop(context);
                                          }
                                        },
                                        icon: Icon(Icons.share),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
