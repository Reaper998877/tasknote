import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static final logger = Logger();

  // Save theme mode
  static Future<void> saveMode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mode', value);
  }

  // Get theme mode
  static Future<String> getMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('mode') ?? "";
  }

  // Save notes view type
  static Future<void> saveViewType(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes_view_type', value);
  }

  // Get notes view type
  static Future<String> getViewType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('notes_view_type') ?? "";
  }

  // Save notes sort type
  static Future<void> saveSortType(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes_sort_type', value);
  }

  // Get notes sort type
  static Future<String> getSortType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('notes_sort_type') ?? "";
  }

  // Save cal notes sort type
  static Future<void> saveCalSortType(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cal_notes_sort_type', value);
  }

  // Get cal notes sort type
  static Future<String> getCalSortType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('cal_notes_sort_type') ?? "";
  }

  // Save group sort type
  static Future<void> saveGroupSortType(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('group_sort_type', value);
  }

  // Get group sort type
  static Future<String> getGroupSortType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('group_sort_type') ?? "";
  }

  // Save login status
  static Future<void> saveLoginInfo(bool value, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('login_status', value);
    await prefs.setString('email', email);
  }

  // Get login status
  static Future<Map<String, dynamic>> getLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    bool status = prefs.getBool('login_status') ?? false;
    String email = prefs.getString('email') ?? "";
    return {"status": status, "email": email};
  }
}
