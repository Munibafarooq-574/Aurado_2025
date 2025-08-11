import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class PreferencesProvider extends ChangeNotifier {
  String themeColor = '#fbeee6';
  String language = 'English';
  String taskPriority = 'High';
  String taskSorting = 'By Due Date';
  bool notifications = false;
  bool syncWithCloud = false;

  final _service = PreferencesService();

  static const Map<String, String> colorThemes = {
    'Default Beige': '#fbeee6',
    'Soft Petal Pink': '#F2D2BD', // #66f
    'Soft Yellow': '#FFF3C6',
    'Mauve': '#EAB8D1',
    'Algae Green' : '#B1E5CC',
  };

  // Add this getter here:
  String get themeColorName {
    return colorThemes.entries
        .firstWhere(
          (e) => e.value.toLowerCase() == themeColor.toLowerCase(),
      orElse: () => const MapEntry('Default Beige', '#fbeee6'),
    )
        .key;
  }


  Future<void> loadPreferences() async {
    final data = await _service.loadPreferences();
    themeColor = data[PreferencesService.themeColorKey] ?? '#fbeee6';
    language = data[PreferencesService.languageKey];
    taskPriority = data[PreferencesService.taskPriorityKey];
    taskSorting = data[PreferencesService.taskSortingKey];
    notifications = data[PreferencesService.notificationsKey];
    syncWithCloud = data[PreferencesService.syncWithCloudKey];
    notifyListeners();
  }

  Future<void> updatePreferences({
    String? themeColor,
    String? language,
    String? taskPriority,
    String? taskSorting,
    bool? notifications,
    bool? syncWithCloud,
  }) async {
    this.themeColor = themeColor ?? this.themeColor;
    this.language = language ?? this.language;
    this.taskPriority = taskPriority ?? this.taskPriority;
    this.taskSorting = taskSorting ?? this.taskSorting;
    this.notifications = notifications ?? this.notifications;
    this.syncWithCloud = syncWithCloud ?? this.syncWithCloud;

    await _service.savePreferences(
      themeColor: this.themeColor,
      language: this.language,
      taskPriority: this.taskPriority,
      taskSorting: this.taskSorting,
      notifications: this.notifications,
      syncWithCloud: this.syncWithCloud,
    );

    notifyListeners();
  }
}
