import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tasknote/General/common_functions.dart';
import 'package:tasknote/General/constants.dart';
import 'package:tasknote/General/stateless_widgets.dart';
import 'package:tasknote/General/theme.dart';
import 'package:tasknote/Model/Group/m_group.dart';
import 'package:tasknote/Model/Note/m_note.dart';
import 'package:tasknote/Service/shared_pref.dart';
import 'package:tasknote/View/Add_Edit/add_edit_group.dart';
import 'package:tasknote/View/Add_Edit/add_edit_note.dart';
import 'package:tasknote/View/General_Views/splash.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  late Stream<List<Group>> _groupStream;
  late Stream<List<Note>> _notesStream;
  final TextEditingController searchController = TextEditingController();
  String sort = "Created";
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _groupStream = groupController.listenToGroupSchema(sort);
    _notesStream = noteController.listenToGroupedNoteSchema();
    initializeSortType();
  }

  void initializeSortType() async {
    final String sortType = await SharedPrefService.getGroupSortType();
    if (sortType != "") {
      setState(() {
        sort = sortType;
      });
      CommonFunctions.logger.d(sort);
      _groupStream = groupController
          .listenToGroupSchema(sort)
          .asBroadcastStream();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<Group>>(
        stream: _groupStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "Folders not added yet.\nTap '+' to create one.",
                style: theme.textTheme.bodyMedium,
              ),
            );
          }
          List<Group> originalGroupList = snapshot.data!;
          List<Group> sortedGroupList = groupController.sortGroups(
            sort,
            originalGroupList,
          );

          // Filter the list based on search query before rendering
          if (searchQuery.isNotEmpty) {
            sortedGroupList = sortedGroupList.where((group) {
              final gNameLower = group.gName.toLowerCase();
              final searchLower = searchQuery.toLowerCase();
              return gNameLower.contains(searchLower);
            }).toList();
          }

          return Column(
            children: [
              // Searchbar
              CSearchbar(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                hintText: "Search folders...",
                searchQuery: searchQuery,
                clearSearch: () {
                  searchController.clear();
                  setState(() {
                    searchQuery = "";
                  });
                },
              ),

              // Sort button
              Visibility(
                visible: sortedGroupList.isNotEmpty,
                child: CActionContainer(
                  showViewButton: false,
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

                    if (result != null && result.isNotEmpty) {
                      await SharedPrefService.saveGroupSortType(result);
                      if (result != sort) {
                        setState(() {
                          sort = result;
                        });
                        CommonFunctions.logger.d(sort);

                        // _groupStream = groupNotesController.listenToGroupSchema(
                        //   sort,
                        // );
                      }
                    }
                  },
                ),
              ),

              // Empty list when searching
              if (sortedGroupList.isEmpty && searchQuery.isNotEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 60,
                          color: isDark ? Colors.white : AppColors.dThirdColor,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "No folders found matching\n\"$searchQuery\"",
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

              StreamBuilder(
                stream: _notesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // When groups exists but all are empty.
                    return Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: CommonFunctions.getWidth(context, 0.04),
                          vertical: CommonFunctions.getWidth(context, 0.02),
                        ),
                        itemCount: sortedGroupList.length,
                        itemBuilder: (context, index) {
                          final group = sortedGroupList[index];
                          return Container(
                            margin: EdgeInsets.only(
                              top: CommonFunctions.getWidth(context, 0.04),
                            ),
                            child: Card(
                              elevation: 5.0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ExpansionTile(
                                  expandedCrossAxisAlignment: .start,
                                  splashColor: isDark
                                      ? AppColors.dSecondColor.withValues(
                                          alpha: 0.5,
                                        )
                                      : AppColors.lSecondColor.withValues(
                                          alpha: 0.5,
                                        ),
                                  childrenPadding: EdgeInsets.all(10.0),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide.none,
                                  ),
                                  leading: const CircleAvatar(
                                    child: Icon(FontAwesomeIcons.solidFolder),
                                  ),
                                  title: Text(
                                    group.gName,
                                    style: theme.textTheme.bodyMedium!.copyWith(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Notes: ${group.noteCount}",
                                    style: theme.textTheme.bodyMedium!.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                  // This is the content that appears when expanded
                                  children: [
                                    Text(
                                      "Description: ${group.description!}",
                                      style: theme.textTheme.bodyMedium!
                                          .copyWith(fontSize: 14),
                                    ),
                                    GroupActionBar(
                                      // Add note inside existing group
                                      onTapAddNote: () async {
                                        Navigator.pushNamed(
                                          context,
                                          '/add_edit_note',
                                          arguments: AddEditNoteArgs(
                                            edit: false,
                                            groupNote: true,
                                            groupId: group.id,
                                          ),
                                        );
                                      },
                                      // Edit group info
                                      onTapEditGroup: () async {
                                        await Navigator.pushNamed(
                                          context,
                                          '/add_edit_group',
                                          arguments: AddEditGroupArgs(
                                            edit: true,
                                            eGroup: group,
                                          ),
                                        );
                                      },
                                      // Delete group
                                      onTapDeleteGroup: () async {
                                        await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return DeleteConfirmation(
                                              singleDeletion: true,
                                              item: "folder",
                                              nCount: group.noteCount,
                                              yesAction: () async {
                                                // Delete notes inside group
                                                await noteController
                                                    .deleteMultipleNotes(
                                                      uidlist:
                                                          group.notesUidsList!,
                                                    );
                                                // Delete group
                                                await groupController
                                                    .deleteGroup(group.id);
                                              },
                                            );
                                          },
                                        );
                                      },
                                      // Ungroup notes and delete group
                                      onTapUngroup: () async {
                                        // Hidden because emptyGroup = true
                                      },
                                      emptyGroup:
                                          true, // show or hide Ungroup button
                                    ),
                                    Container(
                                      height: CommonFunctions.getHeight(
                                        context,
                                        0.1,
                                      ),
                                      padding: EdgeInsets.only(top: 8),
                                      child: Center(
                                        child: Text(
                                          "Empty folder\nClick on Add Note to add one.",
                                          style: theme.textTheme.bodyMedium,
                                          textAlign: .center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }

                  // When groups exists and they have notes inside it.
                  return Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: CommonFunctions.getWidth(context, 0.04),
                        vertical: CommonFunctions.getWidth(context, 0.02),
                      ),
                      itemCount: sortedGroupList.length,
                      itemBuilder: (context, index) {
                        final group = sortedGroupList[index];

                        // Contains notes where grouped = true
                        List<Note> groupedNotesList = snapshot.data!;

                        List<Note> notes = groupedNotesList
                            .where((n) => group.notesUidsList!.contains(n.uid))
                            .toList();
                        return Container(
                          margin: EdgeInsets.only(
                            top: CommonFunctions.getWidth(context, 0.04),
                          ),
                          child: Card(
                            elevation: 5.0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ExpansionTile(
                                expandedCrossAxisAlignment: .start,
                                splashColor: isDark
                                    ? AppColors.dSecondColor.withValues(
                                        alpha: 0.5,
                                      )
                                    : AppColors.lSecondColor.withValues(
                                        alpha: 0.5,
                                      ),
                                childrenPadding: EdgeInsets.all(10.0),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide.none,
                                ),
                                leading: const CircleAvatar(
                                  child: Icon(FontAwesomeIcons.solidFolder),
                                ),
                                title: Text(
                                  group.gName,
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(
                                  "Notes: ${group.noteCount}",
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                                // This is the content that appears when expanded
                                children: [
                                  Text(
                                    "Description: ${group.description!}",
                                    style: theme.textTheme.bodyMedium!.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                  GroupActionBar(
                                    // Add note inside existing group
                                    onTapAddNote: () async {
                                      Navigator.pushNamed(
                                        context,
                                        '/add_edit_note',
                                        arguments: AddEditNoteArgs(
                                          edit: false,
                                          groupNote: true,
                                          groupId: group.id,
                                        ),
                                      );
                                    },
                                    // Edit group info
                                    onTapEditGroup: () async {
                                      await Navigator.pushNamed(
                                        context,
                                        '/add_edit_group',
                                        arguments: AddEditGroupArgs(
                                          edit: true,
                                          eGroup: group,
                                        ),
                                      );
                                    },
                                    // Delete group
                                    onTapDeleteGroup: () async {
                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return DeleteConfirmation(
                                            singleDeletion: true,
                                            item: "folder",
                                            nCount: group.noteCount,
                                            yesAction: () async {
                                              // Delete notes inside group
                                              await noteController
                                                  .deleteMultipleNotes(
                                                    uidlist:
                                                        group.notesUidsList!,
                                                  );
                                              // Delete group
                                              await groupController.deleteGroup(
                                                group.id,
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                    // Remove notes and delete group
                                    onTapUngroup: () async {
                                      // Show confirmation dialog
                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return RemoveConfirmation(
                                            yesAction: () async {
                                              // Ungroup notes
                                              await noteController.unGroupNotes(
                                                uidList: group.notesUidsList!,
                                                gName: group.gName,
                                              );
                                              // Delete group
                                              await groupController.deleteGroup(
                                                group.id,
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                    emptyGroup: notes
                                        .isEmpty, // show or hide Ungroup button
                                  ),
                                  if (notes.isNotEmpty)
                                    ...notes.map(
                                      (note) => GestureDetector(
                                        onTap: () {
                                          // Edit note
                                          Navigator.pushNamed(
                                            context,
                                            '/add_edit_note',
                                            arguments: AddEditNoteArgs(
                                              edit: true,
                                              eNote: note,
                                              groupId: group.id,
                                              groupNote: true,
                                            ),
                                          );
                                        },

                                        onLongPress: () async {
                                          // Show confirmation dialog
                                          // Remove single note from group
                                          await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return RemoveConfirmation(
                                                delete: false,
                                                yesAction: () async {
                                                  // make grouped = false
                                                  await noteController
                                                      .unGroupNotes(
                                                        uidList: [
                                                          note.uid.toString(),
                                                        ],
                                                        gName: group.gName,
                                                      );
                                                  // Update group object
                                                  await noteController
                                                      .removeNoteFromGroup(
                                                        groupId: group.id,
                                                        noteUid: note.uid
                                                            .toString(),
                                                      );
                                                },
                                              );
                                            },
                                          );
                                        },

                                        child: Stack(
                                          children: [
                                            Container(
                                              width: CommonFunctions.getWidth(
                                                context,
                                                1,
                                              ),
                                              height: CommonFunctions.getHeight(
                                                context,
                                                0.11,
                                              ),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 6.0,
                                                  ),
                                              child: Card(
                                                color: isDark
                                                    ? AppColors.dSecondColor
                                                    : AppColors.primary,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    12.0,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: .start,
                                                    children: [
                                                      NoteTitle(
                                                        title: note.title,
                                                      ),
                                                      const SizedBox(
                                                        height: 5.0,
                                                      ),
                                                      NoteContent(
                                                        content: note.content,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Delete single note from a group
                                            Positioned(
                                              right: 0,
                                              top: 10,
                                              child: IconButton(
                                                onPressed: () async {
                                                  await showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return DeleteConfirmation(
                                                        singleDeletion: true,
                                                        yesAction: () async {
                                                          // Remove note from group
                                                          await noteController
                                                              .removeNoteFromGroup(
                                                                groupId:
                                                                    group.id,
                                                                noteUid: note
                                                                    .uid
                                                                    .toString(),
                                                              );
                                                          // Delete note
                                                          await noteController
                                                              .deleteNote(
                                                                note.id,
                                                              );
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                                icon: Icon(Icons.delete),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (notes.isEmpty)
                                    Container(
                                      height: CommonFunctions.getHeight(
                                        context,
                                        0.1,
                                      ),
                                      padding: EdgeInsets.only(top: 8),
                                      child: Center(
                                        child: Text(
                                          "Empty folder\nClick on Add Note to add one.",
                                          style: theme.textTheme.bodyMedium,
                                          textAlign: .center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(
            context,
            '/add_edit_group',
            arguments: AddEditGroupArgs(edit: false, selectedNoteUidList: []),
          );
        },
        child: const Icon(FontAwesomeIcons.solidFolder),
      ),
    );
  }
}
