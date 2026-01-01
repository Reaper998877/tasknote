import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:tasknote/General/common_functions.dart';
import 'package:tasknote/General/constants.dart';
import 'package:tasknote/General/notifiers.dart';
import 'package:tasknote/General/stateless_widgets.dart';
import 'package:tasknote/General/theme.dart';
import 'package:tasknote/Model/Group/m_group.dart';
import 'package:tasknote/View/General_Views/splash.dart';

class AddEditGroup extends StatefulWidget {
  // When Edit
  final bool edit;
  final Group? eGroup;

  // When Add
  final List<String>? selectedNoteUidList;

  const AddEditGroup({
    super.key,
    required this.edit,
    this.eGroup,
    this.selectedNoteUidList,
  });

  @override
  State<AddEditGroup> createState() => _AddEditGroupState();
}

class _AddEditGroupState extends State<AddEditGroup> {
  late String title, decorColor, formButtonText;
  late TextEditingController cName, cDescription;
  late DateTime createdAt, updatedAt;

  final _formKey = GlobalKey<FormState>();

  Color displayColor = Color(0xff000000);

  @override
  void initState() {
    super.initState();
    if (widget.edit) {
      title = "Edit Folder";
      formButtonText = "Save";
      cName = TextEditingController(text: widget.eGroup!.gName);
      cDescription = TextEditingController(text: widget.eGroup!.description);
      createdAt = widget.eGroup!.createdAt;
      updatedAt = widget.eGroup!.updatedAt;
      decorColor = widget.eGroup!.decorColor.toString();
      displayColor = Color(int.parse("0x$decorColor"));
    } else {
      title = "Add Folder";
      formButtonText = "Add";
      cName = TextEditingController();
      cDescription = TextEditingController();
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
          actions: widget.edit
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
                                item: "folder",
                                yesAction: () async {
                                  // Delete notes inside group
                                  await noteController.deleteMultipleNotes(
                                    uidlist: widget.eGroup!.notesUidsList!,
                                  );
                                  // Delete group
                                  await groupController.deleteGroup(
                                    widget.eGroup!.id,
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
                          "Name",
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: isDark
                                ? AppColors.primary
                                : AppColors.dThirdColor,
                          ),
                        ),
                        CTextFormField(
                          controller: cName,
                          label: "Name",
                          textInputFormatter: FilteringTextInputFormatter.allow(
                            titlePattern,
                          ),
                        ),
                        SizedBox(
                          height: CommonFunctions.getHeight(context, 0.030),
                        ),
                        Text(
                          "Description",
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: isDark
                                ? AppColors.primary
                                : AppColors.dThirdColor,
                          ),
                        ),
                        CTextFormField(
                          controller: cDescription,
                          label: "Description",
                        ),
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
                                final group = Group(
                                  gName: cName.text.toString().trim(),
                                  description: cDescription.text
                                      .toString()
                                      .trim(),
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now(),
                                  decorColor: decorColor,
                                );

                                if (widget.edit) {
                                  group.createdAt = widget.eGroup!.createdAt;
                                  group.noteCount = widget.eGroup!.noteCount;
                                  group.notesUidsList =
                                      widget.eGroup!.notesUidsList;

                                  // Edit feature
                                  bool updated = await groupController
                                      .checkAndUpdateGroup(
                                        eGroup: widget.eGroup!,
                                        nGroup: group,
                                        context: context,
                                      );
                                  if (updated) {
                                    Navigator.pop(context, "Edited");
                                  }
                                } else {
                                  group.noteCount =
                                      widget.selectedNoteUidList!.length;
                                  group.notesUidsList =
                                      widget.selectedNoteUidList!;

                                  // Add feature
                                  bool added = await groupController
                                      .checkAndAddGroup(group, context);

                                  await noteController.groupSelectedNotes(
                                    uidList: widget.selectedNoteUidList!,
                                    gName: group.gName,
                                  );
                                  if (added) {
                                    Navigator.pop(context, "Added");
                                  }
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

class AddEditGroupArgs {
  // When Edit
  final bool edit;
  final Group? eGroup;

  // When Add
  final List<String>? selectedNoteUidList;

  AddEditGroupArgs({required this.edit, this.eGroup, this.selectedNoteUidList});
}
