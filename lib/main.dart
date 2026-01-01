import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tasknote/Controller/c_reminder.dart';
import 'package:tasknote/General/notifiers.dart';
import 'package:tasknote/General/routes.dart';
import 'package:tasknote/General/theme.dart';
import 'package:tasknote/Service/shared_pref.dart';
import 'package:tasknote/View/General_Views/splash.dart';
import 'package:tasknote/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  initializeTaskController();
  initializeTheme();
  runApp(const MyApp());
}

void initializeTheme() async {
  String mode = await SharedPrefService.getMode();
  if (mode == "dark") {
    themeNotifier.value = ThemeMode.dark;
  } else if (mode == "light") {
    themeNotifier.value = ThemeMode.light;
  } else {
    return;
  }
}

void initializeTaskController() async {
  // Initialize the Controller (and Notification Plugin) before app starts
  await ReminderController().initialize();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TaskNote',
          themeMode: mode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          onGenerateRoute: (settings) => Routes.generateRoute(settings),
          home: const SplashScreen(),
        );
      },
    );
  }
}
