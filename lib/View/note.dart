import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tasknote/General/common_functions.dart';
import 'package:tasknote/General/constants.dart';
import 'package:tasknote/General/stateless_widgets.dart';
import 'package:tasknote/General/theme.dart';
import 'package:tasknote/Model/Note/m_note.dart';
import 'package:tasknote/Service/share.dart';
import 'package:tasknote/Service/shared_pref.dart';
import 'package:tasknote/View/Add_Edit/add_edit_note.dart';
import 'package:tasknote/View/Add_Edit/add_edit_group.dart';
import 'package:tasknote/View/General_Views/splash.dart';
import 'package:tasknote/View/General_Views/reminder.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  late Stream<List<Note>> _notesStream;

  int gridCount = 2; // 2 - Large Grid, 3 - Small Grid
  String view = "Large Grid";
  String sort = "Created";
  bool sSortView = true;
  String searchQuery = "";

  List<String> selectedNoteUidList = [];
  final TextEditingController searchController = TextEditingController();

  void changeView() {
    switch (view) {
      case "Small Grid":
        setState(() => gridCount = 3);
        break;
      case "Large Grid":
        setState(() => gridCount = 2);
        break;
      default:
    }
    CommonFunctions.logger.d(view);
  }

  @override
  void initState() {
    super.initState();
    _notesStream = noteController.listenToNoteSchema(sort);
    initializeViewType();
    initializeSortType();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void initializeViewType() async {
    final String viewType = await SharedPrefService.getViewType();
    if (viewType != "") {
      setState(() {
        view = viewType;
      });
      changeView();
    }
  }

  void initializeSortType() async {
    final String sortType = await SharedPrefService.getSortType();
    if (sortType != "") {
      setState(() {
        sort = sortType;
      });
      CommonFunctions.logger.d(sort);
      _notesStream = noteController.listenToNoteSchema(sort);
    }
  }

  void navigate(Note note) {
    Navigator.pushNamed(
      context,
      '/add_edit_note',
      arguments: AddEditNoteArgs(edit: true, eNote: note),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<Note>>(
        stream: _notesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "Notes not added yet.\nTap '+' to create one.",
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          List<Note> ungroupedNotesList = snapshot.data!;

          // Filter the list based on search query before rendering
          if (searchQuery.isNotEmpty) {
            ungroupedNotesList = ungroupedNotesList.where((note) {
              final titleLower = note.title.toLowerCase();
              final searchLower = searchQuery.toLowerCase();
              return titleLower.contains(searchLower);
            }).toList();
          }

          return Stack(
            children: [
              Column(
                children: [
                  // Searchbar
                  Visibility(
                    visible: sSortView,
                    child: CSearchbar(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      hintText: "Search notes...",
                      searchQuery: searchQuery,
                      clearSearch: () {
                        searchController.clear();
                        setState(() {
                          searchQuery = "";
                        });
                      },
                    ),
                  ),

                  // Selected note count
                  Visibility(
                    visible: !sSortView,
                    child: SelectedNoteCount(
                      text:
                          "${selectedNoteUidList.length} / ${ungroupedNotesList.length}",
                    ),
                  ),

                  // Sort and View button
                  Visibility(
                    visible: sSortView && ungroupedNotesList.isNotEmpty,
                    child: CActionContainer(
                      onTapSort: () async {
                        final result = await showModalBottomSheet<String>(
                          backgroundColor: Colors.transparent,
                          useSafeArea: true,
                          shape: AppTheme.roundedRectangleBorder(),
                          context: context,
                          builder: (context) => SortViewOD(
                            title: 'Sort By',
                            options: sortOptions,
                            showIcons: false,
                            currentSelected: sort,
                          ),
                        );

                        Future.delayed(Duration(seconds: 2));

                        if (result != null && result.isNotEmpty) {
                          await SharedPrefService.saveSortType(result);
                          if (result != sort) {
                            setState(() {
                              sort = result;
                            });
                            CommonFunctions.logger.d(sort);
                            _notesStream = noteController.listenToNoteSchema(
                              sort,
                            );
                          }
                        }
                      },
                      onTapView: () async {
                        final result = await showModalBottomSheet<String>(
                          useSafeArea: true,
                          shape: AppTheme.roundedRectangleBorder(),
                          context: context,
                          builder: (context) => SortViewOD(
                            title: 'View',
                            options: viewOptions,
                            showIcons: true,
                            currentSelected: view,
                          ),
                        );

                        if (result != null && result.isNotEmpty) {
                          await SharedPrefService.saveViewType(result);
                          if (result != view) {
                            setState(() {
                              view = result;
                            });
                            changeView();
                          }
                        }
                      },
                    ),
                  ),

                  // Empty list when searching
                  if (ungroupedNotesList.isEmpty && searchQuery.isNotEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.dThirdColor,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "No notes found matching\n\"$searchQuery\"",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? Colors.white
                                    : AppColors.dThirdColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Listview
                  if (view == "List" || view == "Title")
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        physics: const BouncingScrollPhysics(),
                        itemCount: ungroupedNotesList.length,
                        itemBuilder: (context, index) {
                          final note = ungroupedNotesList[index];

                          return GestureDetector(
                            onLongPress: selectedNoteUidList.isEmpty
                                ? () {
                                    setState(() {
                                      selectedNoteUidList.add(
                                        note.uid.toString(),
                                      );
                                      sSortView = false;
                                    });
                                  }
                                : null,
                            onTap: selectedNoteUidList.isEmpty
                                // When any note is not selected.
                                ? () => navigate(note)
                                // When any note is selected.
                                : () {
                                    if (selectedNoteUidList.contains(
                                      note.uid.toString(),
                                    )) {
                                      selectedNoteUidList.remove(
                                        note.uid.toString(),
                                      );
                                      if (selectedNoteUidList.isEmpty) {
                                        sSortView = true;
                                      }
                                      setState(() {});
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
                                  selectedNoteUidList.contains(
                                    note.uid.toString(),
                                  )
                                  ? BoxDecoration(
                                      border: Border.all(
                                        color: isDark
                                            ? AppColors.lFirstColor
                                            : AppColors.dThirdColor,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    )
                                  : null,
                              margin: view == "Title"
                                  ? const EdgeInsets.symmetric(vertical: 3.0)
                                  : const EdgeInsets.symmetric(vertical: 6.0),
                              height: view == "Title"
                                  ? CommonFunctions.getHeight(context, 0.08)
                                  : CommonFunctions.getHeight(context, 0.2),
                              child: Card(
                                elevation:
                                    selectedNoteUidList.contains(
                                      note.uid.toString(),
                                    )
                                    ? 0
                                    : 5.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      NoteTitle(title: note.title),
                                      if (view != "Title")
                                        const SizedBox(height: 5.0),
                                      if (view != "Title")
                                        NoteContent(content: note.content),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  // Gridview
                  if ((view == "Small Grid" || view == "Large Grid") &&
                      ungroupedNotesList.isNotEmpty)
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridCount,
                          mainAxisSpacing: view == "Small Grid" ? 6 : 12,
                          crossAxisSpacing: view == "Small Grid" ? 6 : 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: ungroupedNotesList.length,
                        itemBuilder: (context, index) {
                          final note = ungroupedNotesList[index];

                          return GestureDetector(
                            onLongPress: selectedNoteUidList.isEmpty
                                ? () {
                                    setState(() {
                                      selectedNoteUidList.add(
                                        note.uid.toString(),
                                      );
                                      sSortView = false;
                                    });
                                  }
                                : null,
                            onTap: selectedNoteUidList.isEmpty
                                // When any note is not selected.
                                ? () => navigate(note)
                                // When any note is selected.
                                : () {
                                    if (selectedNoteUidList.contains(
                                      note.uid.toString(),
                                    )) {
                                      selectedNoteUidList.remove(
                                        note.uid.toString(),
                                      );
                                      if (selectedNoteUidList.isEmpty) {
                                        sSortView = true;
                                      }
                                      setState(() {});
                                    } else {
                                      setState(() {
                                        selectedNoteUidList.add(
                                          note.uid.toString(),
                                        );
                                      });
                                    }
                                  },
                            child: Card(
                              elevation:
                                  selectedNoteUidList.contains(
                                    note.uid.toString(),
                                  )
                                  ? 0
                                  : 5.0,
                              shape:
                                  selectedNoteUidList.contains(
                                    note.uid.toString(),
                                  )
                                  ? RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: isDark
                                            ? AppColors.lFirstColor
                                            : AppColors.dThirdColor,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    )
                                  : null,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    NoteTitle(title: note.title),
                                    const SizedBox(height: 5.0),
                                    NoteContent(content: note.content),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
              AnimatedOpacity(
                opacity: sSortView ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                child: AnimatedSlide(
                  offset: sSortView ? const Offset(0, 0.1) : const Offset(0, 0),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  child: Align(
                    alignment: AlignmentGeometry.bottomCenter,
                    child: Container(
                      height: CommonFunctions.getHeight(context, 0.070),
                      padding: EdgeInsets.symmetric(
                        horizontal: CommonFunctions.getWidth(context, 0.05),
                      ),
                      margin: EdgeInsets.symmetric(
                        vertical: CommonFunctions.getWidth(context, 0.04),
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.lThirdColor
                            : AppColors.dThirdColor,
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 5.0,
                            spreadRadius: 3.0,
                            color: isDark
                                ? AppColors.primary.withValues(alpha: 0.5)
                                : AppColors.dThirdColor.withValues(alpha: 0.5),
                            blurStyle: BlurStyle.outer,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: .min,
                        mainAxisAlignment: .center,
                        children: [
                          MultiNoteSelectOD(
                            icon: Icons.cancel,
                            text: "Cancel",
                            onTap: () {
                              setState(() {
                                selectedNoteUidList.clear();
                                sSortView = true;
                              });
                            },
                          ),

                          MultiNoteSelectOD(
                            onTap: () async {
                              await showDialog(
                                context: context,
                                builder: (context) {
                                  return DeleteConfirmation(
                                    singleDeletion:
                                        selectedNoteUidList.length > 1
                                        ? false
                                        : true,
                                    yesAction: () async {
                                      await noteController.deleteMultipleNotes(
                                        uidlist: selectedNoteUidList,
                                      );
                                      setState(() {
                                        selectedNoteUidList.clear();
                                        sSortView = true;
                                      });
                                    },
                                  );
                                },
                              );
                            },
                            icon: Icons.delete,
                            text: "Delete",
                          ),

                          MultiNoteSelectOD(
                            onTap: () async {
                              final result = await Navigator.pushNamed(
                                context,
                                '/add_edit_group',
                                arguments: AddEditGroupArgs(
                                  edit: false,
                                  selectedNoteUidList: selectedNoteUidList,
                                ),
                              );

                              if (result.toString() == "Added") {
                                setState(() {
                                  selectedNoteUidList.clear();
                                  sSortView = true;
                                });
                              }
                            },
                            text: "Folder",
                            icon: FontAwesomeIcons.solidFolder,
                          ),

                          if (selectedNoteUidList.length == 1)
                            MultiNoteSelectOD(
                              onTap: () async {
                                Note note = ungroupedNotesList
                                    .where(
                                      (n) => n.uid == selectedNoteUidList.first,
                                    )
                                    .toList()
                                    .first;
                                final result = await ShareService.shareText(
                                  "${note.title}\n${note.content}",
                                );
                                if (result.status ==
                                    ShareResultStatus.success) {
                                  CommonFunctions.logger.d('Sent');
                                  setState(() {
                                    selectedNoteUidList.clear();
                                    sSortView = true;
                                  });
                                }
                              },
                              text: "Share",
                              icon: Icons.share,
                            ),

                          if (selectedNoteUidList.length == 1)
                            MultiNoteSelectOD(
                              onTap: () async {
                                Note note = ungroupedNotesList
                                    .where(
                                      (n) => n.uid == selectedNoteUidList.first,
                                    )
                                    .toList()
                                    .first;
                                await showModalBottomSheet<String>(
                                  useSafeArea: true,
                                  isDismissible: false,
                                  isScrollControlled: true,
                                  shape: AppTheme.roundedRectangleBorder(),
                                  context: context,
                                  builder: (context) =>
                                      ReminderScreen(note: note),
                                );
                                setState(() {
                                  selectedNoteUidList.clear();
                                  sSortView = true;
                                });
                              },
                              text: "Reminder",
                              icon: Icons.notifications,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: sSortView
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/add_edit_note',
                  arguments: AddEditNoteArgs(edit: false),
                );
              },
              child: const Icon(Icons.note_add_rounded),
            )
          : null,
    );
  }
}
