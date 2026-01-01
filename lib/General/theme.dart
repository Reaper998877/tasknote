import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AppColors {
  static const Color primary = Color(0xFF26C6DA);
  static const Color secondary = Color(0xFF7E57C2);
  static const Color accent = Color(0xFF80DEEA);
  static const Color error = Color(0xFFFF6F61);

  // --- Light Theme Gradient
  static Color lFirstColor = Color(0xFFa7ebf2);
  static Color lSecondColor = Color(0xFF54acbf);
  static Color lThirdColor = Color(0xFF26658c);

  // --- Dark Theme Gradient
  static Color dFirstColor = Color(0xFF26658c);
  static Color dSecondColor = Color(0xFF023859);
  static Color dThirdColor = Color(0xFF011c40);
}

class AppTheme {
  /// ---------- LIGHT THEME ----------
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    cardTheme: CardThemeData(
      color: AppColors.lFirstColor,
      elevation: 5.0,
      shadowColor: AppColors.dThirdColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      tertiary: AppColors.accent,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontFamily: 'poppins',
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        fontFamily: 'inter',
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        fontFamily: 'inter',
        color: Colors.black,
      ),
    ),
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(color: Colors.black),
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontFamily: 'average',
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4.0,
    ),
    iconTheme: IconThemeData(color: AppColors.dThirdColor, size: 24),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary,
        elevation: 4.0,
        textStyle: const TextStyle(
          fontSize: 20,
          fontFamily: 'inter',
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        iconSize: 20,
        foregroundColor: AppColors.lThirdColor,
        textStyle: const TextStyle(
          fontSize: 18,
          fontFamily: 'inter',
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    dialogTheme: DialogThemeData(backgroundColor: AppColors.lFirstColor),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color(0xFFa7ebf2),
      contentTextStyle: TextStyle(
        color: Colors.black, fontFamily: "poppins" , fontSize: 18.0
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.all(Radius.circular(20.0))
      )
    )
  );

  /// ---------- DARK THEME ----------
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    cardTheme: CardThemeData(
      color: AppColors.dThirdColor,
      elevation: 5.0,
      shadowColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      tertiary: AppColors.accent,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontFamily: 'poppins',
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'inter',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        fontFamily: 'inter',
        color: Colors.white,
      ),
    ),
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontFamily: 'average',
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4.0,
    ),
    iconTheme: IconThemeData(color: AppColors.lSecondColor, size: 24),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary,
        elevation: 4.0,
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.5,
          fontFamily: 'inter',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        iconSize: 20,
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(
          fontSize: 18,
          fontFamily: 'inter',
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    dialogTheme: DialogThemeData(backgroundColor: AppColors.lThirdColor),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color(0xFF011c40),
      contentTextStyle: TextStyle(
        color: Colors.white, fontFamily: "poppins" , fontSize: 18.0
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.all(Radius.circular(20.0))
      )
    )
  );

  static LinearGradient lightGradient = LinearGradient(
    begin: AlignmentGeometry.topLeft,
    end: AlignmentGeometry.bottomRight,
    colors: [Color(0xFFa7ebf2), Color(0xFF54acbf), Color(0xFF26658c)],
  );

  static LinearGradient darkGradient = LinearGradient(
    begin: AlignmentGeometry.topLeft,
    end: AlignmentGeometry.bottomRight,
    colors: [Color(0xFF26658c), Color(0xFF023859), Color(0xFF011c40)],
  );

  // Calender Only Theme
  static TextStyle textStyle({
    required Color textColor,
    double fontSize = 20.0,
  }) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: fontSize,
      fontFamily: 'poppins',
      color: textColor,
      // color:
    );
  }

  static BoxDecoration boxDecoration({required Color borderColor}) {
    return BoxDecoration(
      shape: BoxShape.rectangle,
      border: Border.all(color: borderColor),
    );
  }

  static DaysOfWeekStyle daysOfWeekStyle({
    required Color borderColor,
    required Color textColor,
  }) {
    return DaysOfWeekStyle(
      weekdayStyle: textStyle(textColor: textColor),
      weekendStyle: textStyle(textColor: AppColors.error),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        border: Border.all(color: borderColor, width: 2.0),
      ),
    );
  }

  static CalendarStyle calendarStyle({
    required Color textColor,
    required Color borderColor,
  }) {
    return CalendarStyle(
      outsideTextStyle: textStyle(textColor: Colors.grey),
      todayTextStyle: textStyle(textColor: Colors.white), // Fixed visibility
      selectedTextStyle: textStyle(textColor: Colors.white),
      defaultTextStyle: textStyle(textColor: textColor, fontSize: 18),
      weekendTextStyle: textStyle(textColor: AppColors.error, fontSize: 18),

      markerSize: 10,
      markerDecoration: BoxDecoration(
        color: AppColors.secondary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),

      defaultDecoration: boxDecoration(borderColor: borderColor),
      weekendDecoration: boxDecoration(borderColor: borderColor),
      todayDecoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.7),
        shape: BoxShape.rectangle,
        border: Border.all(color: AppColors.primary, width: 3),
      ),
      selectedDecoration: const BoxDecoration(
        color: AppColors.secondary,
        shape: BoxShape.rectangle,
      ),
    );
  }

  static HeaderStyle headerStyle({required Color titleColor}) {
    return HeaderStyle(
      titleCentered: true,
      titleTextStyle: TextStyle(
        color: titleColor,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
        fontSize: 22,
      ),
      formatButtonVisible: false,
    );
  }

  // Input Field Only Theme
  static TextStyle inputTextStyle({
    double? fontSize = 16.0,
    Color color = Colors.white,
  }) {
    return TextStyle(fontSize: fontSize, fontFamily: 'breeserif', color: color);
  }

  static InputDecoration inputDecoration({
    required Color fBColor,
    required Color eBColor,
  }) {
    return InputDecoration(
      isDense: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: fBColor, width: 3),
        borderRadius: BorderRadius.circular(10),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.error, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: eBColor, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // ModalBottomSheet Only Theme
  static RoundedRectangleBorder roundedRectangleBorder({double radius = 20.0}) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
    );
  }
}
