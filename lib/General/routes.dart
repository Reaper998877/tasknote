import 'package:flutter/material.dart';
import 'package:tasknote/View/Add_Edit/add_edit_group.dart';
import 'package:tasknote/View/Add_Edit/add_edit_note.dart';
import 'package:tasknote/View/General_Views/auth.dart';
import 'package:tasknote/View/General_Views/home.dart';

class Routes {
  static SlideTransition slideTransition(
    Animation<double> animation,
    Widget child,
  ) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0), // slide from right
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));

    return SlideTransition(position: slideAnimation, child: child);
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
        return PageRouteBuilder(
          pageBuilder: (_, _, _) => const HomeScreen(),
          transitionsBuilder: (_, animation, _, child) {
            return slideTransition(animation, child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        );

      case '/add_edit_note':
        final args = settings
            .arguments; // This retrieves whatever data you sent using the arguments: parameter.

        if (args is! AddEditNoteArgs) {
          throw Exception('Invalid or missing AddEditNoteArgs!');
        }

        return PageRouteBuilder(
          pageBuilder: (_, _, _) => AddEditNoteScreen(
            edit: args.edit,
            eNote: args.eNote,
            calNote: args.calNote,
            selected: args.selected,
            groupNote: args.groupNote,
            groupId: args.groupId,
          ),
          transitionsBuilder: (_, animation, _, child) {
            return slideTransition(animation, child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        );

      case '/auth':
        return PageRouteBuilder(
          pageBuilder: (_, _, _) => const AuthScreen(),
          transitionsBuilder: (_, animation, _, child) {
            return slideTransition(animation, child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        );

      case '/add_edit_group':
        final args = settings
            .arguments; // This retrieves whatever data you sent using the arguments: parameter.

        if (args is! AddEditGroupArgs) {
          throw Exception('Invalid or missing AddEditGroupArgs!');
        }
        return PageRouteBuilder(
          pageBuilder: (_, _, _) => AddEditGroup(
            edit: args.edit,
            eGroup: args.eGroup,
            selectedNoteUidList: args.selectedNoteUidList,
          ),
          transitionsBuilder: (_, animation, _, child) {
            return slideTransition(animation, child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        );

      default:
        return PageRouteBuilder(
          pageBuilder: (_, _, _) => const HomeScreen(),
          transitionsBuilder: (_, animation, _, child) {
            return slideTransition(animation, child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
    }
  }
}
