import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tasknote/General/common_functions.dart';
import 'package:tasknote/General/constants.dart';
import 'package:tasknote/General/notifiers.dart';
import 'package:tasknote/General/theme.dart';

// Only used in - ProfileScreen ############################################################
class CDivider extends StatelessWidget {
  final ThemeData theme;
  const CDivider({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 60, // Indent to align with the text, skipping the icon
      endIndent: 16,
      color: theme.colorScheme.outlineVariant,
    );
  }
}

class CMenuItem extends StatelessWidget {
  final BuildContext context;
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? textColor;
  final Widget? tWidget;
  const CMenuItem({
    super.key,
    required this.context,
    required this.icon,
    required this.title,
    this.onTap,
    this.textColor,
    this.tWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          color: isDark ? colorScheme.primary : AppColors.lThirdColor,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          fontFamily: 'inter',
        ),
      ),
      trailing: tWidget,
      // : Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
    );
  }
}

class BackupOrLogOut extends StatelessWidget {
  final bool isBackUp;
  final VoidCallback? yesAction;
  const BackupOrLogOut({super.key, required this.isBackUp, this.yesAction});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisSize: .min,
        children: [
          Icon(isBackUp ? Icons.backup_rounded : Icons.logout_rounded),
          SizedBox(width: 10.0),
          Text(isBackUp ? "BackUp" : "LogOut"),
        ],
      ),
      content: Text(
        isBackUp
            ? "BackUp is started\nKeep internet on."
            : "Are you sure you want to log out?",
      ),
      actions: [
        isBackUp
            ? Center(child: CircularProgressIndicator())
            : Row(
                mainAxisAlignment: .end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      yesAction!();
                    },
                    child: Text("Yes"),
                  ),
                ],
              ),
      ],
    );
  }
}

class DownloadDialog extends StatelessWidget {
  const DownloadDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisSize: .min,
        children: [
          Icon(Icons.downloading),
          SizedBox(width: 10.0),
          Text("Download"),
        ],
      ),
      content: Text("Data download started.\n\nKeep internet on."),
      actions: [Center(child: CircularProgressIndicator())],
    );
  }
}

// Only used in - NoteScreen ############################################################
class MultiNoteSelectOD extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  const MultiNoteSelectOD({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: CommonFunctions.getWidth(context, 0.15),
        child: Column(
          crossAxisAlignment: .center,
          mainAxisSize: .min,
          spacing: 5.0,
          children: [
            Icon(icon, color: Colors.white),
            Text(
              text,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: Colors.white,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Only used in - HomeScreen ############################################################
class CBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const CBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Access the current theme data
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final items = [
      {
        'icon': FontAwesomeIcons.noteSticky,
        'label': 'Notes',
        'filled': FontAwesomeIcons.solidNoteSticky,
      },
      {
        'icon': FontAwesomeIcons.solidCalendar,
        'label': 'Calender',
        'filled': Icons.calendar_month_rounded,
      },
      {
        'icon': FontAwesomeIcons.folder,
        'label': 'Folder',
        'filled': FontAwesomeIcons.solidFolder,
      },
      {
        'icon': FontAwesomeIcons.user,
        'label': 'Account',
        'filled': FontAwesomeIcons.solidUser,
      },
    ];

    // Dynamic Colors based on Theme
    // Use the primary background color for the overall container background
    final Color containerBackgroundColor = isDark
        ? AppColors.dThirdColor
        : AppColors.lThirdColor;
    final Color activeColor = theme.primaryColor; // Teal (0xFF26C6DA)

    // Creates a light wash of the primary color for the active tab background
    // Dark mode wash is more opaque (0.2) against the dark background.
    // Light mode wash is less opaque (0.15) against the white background.
    final Color activeTabBackground = activeColor.withValues(
      alpha: isDark ? 0.2 : 0.15,
    );

    // Inactive colors
    final Color inactiveIconColor = isDark ? Colors.white70 : Colors.white54;
    final Color inactiveTextColor = isDark ? Colors.white70 : Colors.white54;

    return Container(
      // NOTE: CommonFunctions.getHeight is not defined here, keeping it as is.
      // height: CommonFunctions.getHeight(context, 0.095),
      height: 75, // Using a fixed height as a placeholder
      padding: const EdgeInsets.only(bottom: 5.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
        // Use the defined card/container color
        color: containerBackgroundColor,
        boxShadow: [
          BoxShadow(
            // Shadow color adapts to be darker on light theme, lighter on dark theme
            color: isDark
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.dThirdColor.withValues(alpha: 0.5),
            blurRadius: 10.0,
            spreadRadius: 1.0,
            offset: const Offset(0, -4), // Shadow on top side
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isActive = index == currentIndex;

          return GestureDetector(
            onTap: () => onTabSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                // Apply the theme-consistent active background
                color: isActive ? activeTabBackground : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    items[index][isActive ? 'filled' : 'icon'] as IconData,
                    // Active icon uses Primary (Teal)
                    color: isActive ? activeColor : inactiveIconColor,
                    size: 27,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[index]['label'] as String,
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 12,
                      // Active text uses Secondary (Purple) for better contrast/pop
                      color: isActive ? activeColor : inactiveTextColor,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Only used in - GroupsScreen ############################################################
class GroupActionBar extends StatelessWidget {
  final VoidCallback onTapAddNote;
  final VoidCallback onTapEditGroup;
  final VoidCallback onTapDeleteGroup;
  final VoidCallback onTapUngroup;
  final bool emptyGroup;
  const GroupActionBar({
    super.key,
    required this.onTapAddNote,
    required this.onTapEditGroup,
    required this.onTapDeleteGroup,
    required this.onTapUngroup,
    required this.emptyGroup,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: .centerLeft,
            end: .centerRight,
            colors: isDark
                ? [
                    Color(0xFF011c40),
                    Color(0xFF023859).withValues(alpha: 0.9),
                    Color(0xFF011c40),
                  ]
                : [
                    Color(0xFF54acbf),
                    Color(0xFFa7ebf2).withValues(alpha: 0.9),
                    Color(0xFF54acbf),
                  ],
          ),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : AppColors.dSecondColor.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Add note inside existing group
            TextButton.icon(
              onPressed: onTapAddNote,
              label: Text("Add Note"),
              icon: Icon(Icons.note_add),
            ),

            const SizedBox(width: 8),

            const Spacer(),
            // Edit group info
            IconButton(onPressed: onTapEditGroup, icon: Icon(Icons.edit)),
            // Delete group
            IconButton(
              onPressed: onTapDeleteGroup,
              icon: Icon(Icons.folder_delete_rounded),
            ),
            if (emptyGroup == false)
              // Remove all notes from group
              IconButton(onPressed: onTapUngroup, icon: Icon(Icons.folder_off)),
          ],
        ),
      ),
    );
  }
}

class RemoveConfirmation extends StatelessWidget {
  final VoidCallback yesAction;
  final bool? delete;
  const RemoveConfirmation({
    super.key,
    required this.yesAction,
    this.delete = true,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Remove"),
      content: delete!
          ? Text(
              "Are you sure you want to remove all notes from this folder?\nFolder will be deleted",
              textAlign: TextAlign.start,
            )
          : Text("Are you sure you want to remove this note from folder?"),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                yesAction();
              },
              child: Text("Yes"),
            ),
          ],
        ),
      ],
    );
  }
}

// Used in - AddEditNoteScreen, AddEditGroupScreen ############################################################
class CTextFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputFormatter? textInputFormatter;

  const CTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.textInputFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.value == ThemeMode.dark;
    return TextFormField(
      controller: controller,
      keyboardType: label == "Content" || label == "Description"
          ? TextInputType.multiline
          : TextInputType.text,
      maxLines: label == "Content" || label == "Description" ? null : 1,
      style: AppTheme.inputTextStyle(),
      cursorColor: isDark ? AppColors.primary : AppColors.dThirdColor,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        return null;
      },
      inputFormatters: label == "Content" ? null : [?textInputFormatter],
      decoration: AppTheme.inputDecoration(
        fBColor: isDark ? AppColors.lFirstColor : AppColors.dFirstColor,
        eBColor: isDark ? AppColors.primary : AppColors.dThirdColor,
      ),
    );
  }
}

// Used in - NoteScreen, GroupsScreen ############################################################
// OD - Options Display
class SortViewOD extends StatelessWidget {
  final bool showIcons;
  final String title;
  final List<String> options;
  final String currentSelected;
  const SortViewOD({
    super.key,
    required this.title,
    required this.options,
    required this.showIcons,
    required this.currentSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      height: CommonFunctions.getHeight(context, 0.34),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        color: isDark ? AppColors.dThirdColor : AppColors.lThirdColor,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.displayLarge!.copyWith(
              fontSize: 25.0,
              color: isDark ? Colors.white : Colors.white,
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: options.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: showIcons
                      ? Icon(viewOptionsIcons[index], color: Colors.white)
                      : null,
                  title: Text(
                    options[index],
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: isDark ? Colors.white : Colors.white,
                    ),
                  ),
                  trailing: currentSelected == options[index]
                      ? Icon(Icons.check_circle, color: theme.primaryColor)
                      : null,
                  onTap: () {
                    Navigator.pop(context, options[index]);
                  },
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  height: 1,
                  thickness: 0.5,
                  color: isDark
                      ? theme.colorScheme.outlineVariant
                      : Colors.grey,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CActionContainer extends StatelessWidget {
  final VoidCallback onTapSort;
  final VoidCallback? onTapView;
  final bool showViewButton;
  const CActionContainer({
    super.key,
    required this.onTapSort,
    this.onTapView,
    this.showViewButton = true,
  });

  @override
  Widget build(BuildContext context) {
    // Access the current theme data
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Fallback for CommonFunctions that is not provided
    final double defaultWidth = CommonFunctions.getWidth(context, 1);
    final double marginHorizontal = defaultWidth * 0.1;
    final double marginVertical = defaultWidth * 0.04;
    final double buttonWidth = defaultWidth * 0.35;

    // Theme-specific colors
    final Color containerColor = isDark
        ? AppColors.dThirdColor
        : AppColors.lThirdColor;

    // Shadow color uses primary color for an attractive glow
    final Color shadowColor = isDark
        ? AppColors.primary.withValues(alpha: 0.5)
        : AppColors.dThirdColor.withValues(alpha: 0.5);

    return Container(
      height: CommonFunctions.getHeight(context, 0.048),
      margin: EdgeInsets.symmetric(
        horizontal: marginHorizontal,
        vertical: marginVertical,
      ),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            blurRadius: 7.0,
            spreadRadius: 2.0,
            color: shadowColor,
            blurStyle:
                BlurStyle.normal, // Using normal style for a cleaner glow
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: buttonWidth,
            child: TextButton.icon(
              onPressed: () async {
                onTapSort();
              },
              label: Text(
                "Sort By",
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: const Icon(Icons.sort_rounded, color: Colors.white),
              style: TextButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
              ),
            ),
          ),
          if (showViewButton)
            const VerticalDivider(
              color: Colors.white,
              indent: 8,
              endIndent: 8,
              thickness: 1.5,
            ),
          if (showViewButton)
            SizedBox(
              width:
                  buttonWidth, // Original: CommonFunctions.getWidth(context, 0.35)
              child: TextButton.icon(
                onPressed: () async {
                  if (showViewButton) {
                    onTapView!();
                  }
                },
                iconAlignment: IconAlignment.end,
                label: Text(
                  "View",
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: const Icon(Icons.view_agenda, color: Colors.white),
                style: TextButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Used in - NoteScreen, CalenderScreen, GroupScreen ############################################################
class NoteTitle extends StatelessWidget {
  final String title;
  const NoteTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class NoteContent extends StatelessWidget {
  final String content;
  const NoteContent({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Text(
        content,
        overflow: TextOverflow.clip,
        style: theme.textTheme.bodySmall!.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

// Used in - NoteScreen, CalenderScreen ############################################################
class SelectedNoteCount extends StatelessWidget {
  final String text;
  const SelectedNoteCount({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.all(Radius.circular(20.0)),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        color: isDark ? AppColors.lSecondColor : AppColors.dThirdColor,
        child: Text(
          text,
          style: theme.textTheme.bodyMedium!.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

// Used in - NoteScreen, GroupScreen ############################################################
class CSearchbar extends StatelessWidget {
  final void Function(String)? onChanged;
  final TextEditingController controller;
  final String hintText;
  final String searchQuery;
  final VoidCallback clearSearch;
  const CSearchbar({
    super.key,
    this.onChanged,
    required this.controller,
    required this.hintText,
    required this.searchQuery,
    required this.clearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.only(
        left: CommonFunctions.getWidth(context, 0.07),
        right: CommonFunctions.getWidth(context, 0.07),
        top: CommonFunctions.getWidth(context, 0.06),
        bottom: CommonFunctions.getWidth(context, 0.02),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: AlignmentGeometry.centerLeft,
          end: AlignmentGeometry.centerRight,
          colors: isDark
              ? [Color(0xFF26658c), Color(0xFF023859), Color(0xFF011c40)]
              : [Color(0xFFa7ebf2), Color(0xFF54acbf), Color(0xFF26658c)],
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        inputFormatters: [FilteringTextInputFormatter.allow(titlePattern)],
        style: AppTheme.inputTextStyle().copyWith(
          color: isDark ? Colors.white : AppColors.dThirdColor,
          fontFamily: 'poppins',
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: 'poppins',
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade900,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? AppColors.lFirstColor : AppColors.dThirdColor,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: clearSearch,
                )
              : null,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDark ? AppColors.lFirstColor : AppColors.dFirstColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDark ? AppColors.lFirstColor : AppColors.dThirdColor,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 5,
          ),
        ),
      ),
    );
  }
}

// Used in - NoteScreen, CalenderScreen, GroupScreen, AddEditNoteScreen, AddEditGroupScreen ############################################################
class DeleteConfirmation extends StatelessWidget {
  final bool singleDeletion;
  final VoidCallback yesAction;
  final String? item;
  final int? nCount;
  const DeleteConfirmation({
    super.key,
    required this.singleDeletion,
    required this.yesAction,
    this.item = "note",
    this.nCount = 0
  });

  @override
  Widget build(BuildContext context) {
    String msg;
    if (item == "note") {
      msg = singleDeletion
          ? "Are you sure you want to delete this note?"
          : "Are you sure you want to delete the selected notes?";
    } else {
      if(nCount! > 1){
        msg =
          "Are you sure you want to delete this folder?\nAll notes inside this folder will be deleted.";
      }else if(nCount! == 1){
        msg =
          "Are you sure you want to delete this folder?\nNote inside this folder will be deleted.";
      }else{// nCount is 0
        msg =
          "Are you sure you want to delete this folder?";
      }
      
    }
    return AlertDialog(
      title: Text("Delete"),
      content: Text(msg, textAlign: TextAlign.start),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                yesAction();
              },
              child: Text("Yes"),
            ),
          ],
        ),
      ],
    );
  }
}

// Used in GroupController, Authentication, AuthScreen, ProfileScreen
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> scaffoldMessenger(
  BuildContext context,
  String message,
) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      margin: EdgeInsets.all(20.0),
      content: Text(message),
    ),
  );
}
