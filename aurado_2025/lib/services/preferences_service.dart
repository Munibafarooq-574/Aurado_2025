import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String themeColorKey = 'themeColor';
  static const String languageKey = 'language';
  static const String taskPriorityKey = 'taskPriority';
  static const String taskSortingKey = 'taskSorting';
  static const String notificationsKey = 'notifications';
  static const String syncWithCloudKey = 'syncWithCloud';

  Future<void> savePreferences({
    required String themeColor,
    required String language,
    required String taskPriority,
    required String taskSorting,
    required bool notifications,
    required bool syncWithCloud,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeColorKey, themeColor);
    await prefs.setString(languageKey, language);
    await prefs.setString(taskPriorityKey, taskPriority);
    await prefs.setString(taskSortingKey, taskSorting);
    await prefs.setBool(notificationsKey, notifications);
    await prefs.setBool(syncWithCloudKey, syncWithCloud);
  }

  Future<Map<String, dynamic>> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      themeColorKey: prefs.getString(themeColorKey) ?? '#fbeee6',
      languageKey: prefs.getString(languageKey) ?? 'English',
      taskPriorityKey: prefs.getString(taskPriorityKey) ?? 'High',
      taskSortingKey: prefs.getString(taskSortingKey) ?? 'By Due Date',
      notificationsKey: prefs.getBool(notificationsKey) ?? false,
      syncWithCloudKey: prefs.getBool(syncWithCloudKey) ?? false,
    };
  }
}
