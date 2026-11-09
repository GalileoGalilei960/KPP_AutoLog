import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_settings.dart';

abstract class SettingsRepository {
  Future<UserSettings> getSettings();
  Future<void> saveSettings(UserSettings settings);
}

class LocalSettingsRepository implements SettingsRepository {
  static const String _settingsKey = 'user_settings_v1';

  @override
  Future<UserSettings> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_settingsKey);
      if (dataStr != null && dataStr.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(dataStr);
        return UserSettings.fromJson(data);
      }
    } catch (_) {}
    return const UserSettings();
  }

  @override
  Future<void> saveSettings(UserSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
    } catch (_) {}
  }
}
