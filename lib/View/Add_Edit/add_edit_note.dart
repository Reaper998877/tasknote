import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:tasknote/General/common_functions.dart';
import 'package:tasknote/General/constants.dart';
import 'package:tasknote/General/notifiers.dart';
import 'package:tasknote/General/stateless_widgets.dart';
import 'package:tasknote/General/theme.dart';
import 'package:tasknote/Model/Note/m_note.dart';
import 'package:tasknote/View/General_Views/splash.dart';

class AddEditNoteScreen extends StatefulWidget {
  final bool edit;
  final Note? eNote;
  // For Calender
  final bool? calNote;
  final DateTime? selected;
  // For Group
  final bool? groupNote;
  final int? groupId;

  const AddEditNoteScreen({
    super.key,
    required this.edit,
    this.eNote,
    this.calNote,
    this.selected,
    this.groupNote,
    this.groupId,
  });

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  late String title, decorColor, formButtonText;
  late TextEditingController cTitle, cContent;
  late DateTime createdAt, updatedAt;

  final _formKey = GlobalKey<FormState>();

  Color displayColor = Color(0xff000000);

  @override
  void initState() {
    super.initState();
    if (widget.edit) {
      title = "Edit Note";
      formButtonText = "Save";
      cTitle = TextEditingController(text: widget.eNote!.title);
      cContent = TextEditingController(text: widget.eNote!.content);
      createdAt = widget.eNote!.createdAt;
      updatedAt = widget.eNote!.updatedAt;
      decorColor = widget.eNote!.decorColor.toString();
      displayColor = Color(int.parse("0x$decorColor"));
    } else {
      title = "Add Note";
      formButtonText = "Add";
      cTitle = TextEditingController();
      cContent = TextEditingController();
      createdAt = DateTime.now();
      updatedAt = DateTime.now();
      decorColor = defaultColor;
      displayColor = Color(int.parse("0x$decorColor"));
    }
  }

  // Function to open the color picker dialog
  void openColorPicker() {
    // Use a temporary variable to hold the color while the user is picking,
    // so the main widget doesn't update until they confirm "GOT IT".
    Color tempPickedColor = displayColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Decoration Color'),
          content: SingleChildScrollView(
            // The actual color picker widget from the external package
            child: ColorPicker(
              pickerColor: displayColor, // Initial color
              onColorChanged: (color) {
                // Update the temporary color as the user moves the slider/wheel
                tempPickedColor = color;
              },
              colorPickerWidth: 300.0,
              pickerAreaHeightPercent: 0.8,
              enableAlpha: true, // Allow transparency picking
              displayThumbColor: true,
              paletteType: PaletteType.hsv,
              labelTypes: const [], // Only show the main picker UI
              pickerAreaBorderRadius: BorderRadius.circular(16.0),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'GOT IT',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                // 2. Update the state variable with the confirmed color
                setState(() {
                  displayColor = tempPickedColor;
                });
                decorColor = displayColor.toHexString().toString();

                // 3. debugPrint the decorColor
                CommonFunctions.logger.d(decorColor);

                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = themeNotifier.value == ThemeMode.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppTheme.darkGradient : AppTheme.lightGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(title),
          actions: widget.edit && widget.groupNote == false
              ? [
                  PopupMenuButton<String>(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                        onTap: () async {
                          debugPrint('Delete pressed');
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return DeleteConfirmation(
                                singleDeletion: true,
                                yesAction: () async {
                                  await noteController.deleteNote(
                                    widget.eNote!.id,
                                  );
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ]
              : null,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (widget.edit)
                    Stack(
                      children: [
                        Align(
                          alignment: AlignmentGeometry.topLeft,
                          child: Text(
                            "Last updated\n${CommonFunctions.formatCustom(updatedAt, short: true)}",
                            style: theme.textTheme.bodySmall!.copyWith(
                              color: isDark
                                  ? AppColors.primary
                                  : AppColors.dThirdColor,
                            ),
                          ),
                        ),
                        Align(
                          alignment: AlignmentGeometry.topRight,
                          child: Text(
                            textAlign: TextAlign.end,
                            "Created\n${CommonFunctions.formatCustom(createdAt)}",
                            style: theme.textTheme.bodySmall!.copyWith(
                              color: isDark
                                  ? AppColors.primary
                                  : AppColors.dThirdColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: CommonFunctions.getHeight(context, 0.050)),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Title",
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: isDark
                                ? AppColors.primary
                                : AppColors.dThirdColor,
                          ),
                        ),
                        CTextFormField(
                          controller: cTitle,
                          label: "Title",
                          textInputFormatter: FilteringTextInputFormatter.allow(
                            titlePattern,
                          ),
                        ),
                        SizedBox(
                          height: CommonFunctions.getHeight(context, 0.030),
                        ),
                        Text(
                          "Content",
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: isDark
                                ? AppColors.primary
                                : AppColors.dThirdColor,
                          ),
                        ),
                        CTextFormField(controller: cContent, label: "Content"),
                        SizedBox(
                          height: CommonFunctions.getHeight(context, 0.030),
                        ),
                        Text(
                          "Color",
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: isDark
                                ? AppColors.primary
                                : AppColors.dThirdColor,
                          ),
                        ),
                        InkWell(
                          onTap: openColorPicker,
                          child: Container(
                            width: CommonFunctions.getHeight(context, 0.1),
                            height: CommonFunctions.getHeight(context, 0.055),
                            padding: EdgeInsets.all(3.0),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.primary
                                    : AppColors.dThirdColor,
                                width: 2,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: displayColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: CommonFunctions.getHeight(context, 0.090),
                        ),
                        Align(
                          alignment: AlignmentGeometry.center,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final note = Note(
                                  title: cTitle.text.toString().trim(),
                                  content: cContent.text.toString().trim(),
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now(),
                                  decorColor: decorColor,
                                );

                                // Calender note logic
                                if (widget.calNote!) {
                                  if (widget.edit == false) {
                                    // add
                                    note.calNote = true;
                                    note.selectedD = widget.selected;
                                  } else {
                                    // edit
                                    note.calNote = widget.eNote!.calNote;
                                    note.selectedD = widget.eNote!.selectedD;
                                  }
                                }

                                // Note inside existing group logic
                                if (widget.groupNote!) {
                                  note.grouped = true;
                                }

                                if (widget.edit) {
                                  note.createdAt = widget.eNote!.createdAt;

                                  // Edit feature
                                  await noteController.updateNote(
                                    eNote: widget.eNote!,
                                    nNote: note,
                                  );
                                  Navigator.pop(context);
                                } else {
                                  // Add feature
                                  String noteUid = await noteController.addNote(
                                    note,
                                  );
                                  CommonFunctions.logger.d(noteUid);

                                  // Add note id in group.notesIdList
                                  if (widget.groupNote!) {
                                    await noteController.addNoteToExistingGroup(
                                      groupId: widget.groupId!,
                                      noteUid: noteUid,
                                    );
                                  }

                                  Navigator.pop(context);
                                }
                              }
                            },
                            child: Text(formButtonText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddEditNoteArgs {
  final bool edit;
  final Note? eNote;
  final bool? calNote;
  final DateTime? selected;
  final bool? groupNote;
  final int? groupId;

  AddEditNoteArgs({
    required this.edit,
    this.eNote,
    this.calNote = false,
    this.selected,
    this.groupNote = false,
    this.groupId = 0,
  });
}
