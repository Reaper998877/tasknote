import 'package:flutter/material.dart';
import 'package:tasknote/General/common_functions.dart';
import 'package:tasknote/General/stateless_widgets.dart';
import 'package:tasknote/General/theme.dart';
import 'package:tasknote/View/calender.dart';
import 'package:tasknote/View/groups.dart';
import 'package:tasknote/View/note.dart';
import 'package:tasknote/View/profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    NoteScreen(),
    CalenderNoteScreen(),
    GroupsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  Future<void> _checkInternetConnection() async {
    // Now you can use await here
    if (await CommonFunctions.checkInternet()) {
      CommonFunctions.logger.d("Connected");
    } else {
      CommonFunctions.logger.d("Disconnected");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppTheme.darkGradient : AppTheme.lightGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(child: _screens[_selectedIndex]),
        bottomNavigationBar: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          child: AnimatedSlide(
            offset: const Offset(0, 0.1),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            child: CBottomNavBar(
              currentIndex: _selectedIndex,
              onTabSelected: (index) => setState(() => _selectedIndex = index),
            ),
          ),
        ),
      ),
    );
  }
}
