import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:tasknote/General/notifiers.dart';
import 'package:tasknote/Service/shared_pref.dart';

class CommonFunctions {
  static final logger = Logger();
  final isDark = themeNotifier.value == ThemeMode.dark;

  // Internet Checker
  static Future<bool> checkInternet() async {
    // We use 'hasInternetAccess' for a one-time check
    bool result = await InternetConnection().hasInternetAccess;
    return result;
  }

  // Get screen Height and Width
  static double getHeight(BuildContext context, double h) {
    return MediaQuery.sizeOf(context).height * h;
  }

  static double getWidth(BuildContext context, double w) {
    return MediaQuery.sizeOf(context).width * w;
  }

  // Switch From light to dark mode and vice versa
  static void toggleTheme() {
    if (themeNotifier.value == ThemeMode.light) {
      themeNotifier.value = ThemeMode.dark;
      SharedPrefService.saveMode("dark");
    } else {
      themeNotifier.value = ThemeMode.light;
      SharedPrefService.saveMode("light");
    }
  }

  // Created and Updated format
  static String formatCustom(DateTime dt, {bool short = false}) {
    String day = dt.day.toString().padLeft(2, '0');
    String month = dt.month.toString().padLeft(2, '0');
    String year = dt.year.toString().substring(2); // last two digits

    int hour = dt.hour % 12;
    if (hour == 0) hour = 12;

    String minute = dt.minute.toString().padLeft(2, '0');
    String period = dt.hour >= 12 ? 'pm' : 'am';

    if (short) {
      // Output - 8 Dec 7.30 pm
      return "${dt.day.toString()} ${DateFormat('MMM').format(dt)} $hour.$minute $period";
    } else {
      // Output - 08/12/25 7.30 pm
      return "$day/$month/$year $hour.$minute $period";
    }
  }

}