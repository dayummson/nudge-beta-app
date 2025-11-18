import 'package:shared_preferences/shared_preferences.dart';

/// Simple helper to persist the user's currently selected room id.
/// Key: 'selected_room_id'
class RoomSelection {
  static const _key = 'selected_room_id';

  /// Returns the saved room id or null if none set.
  static Future<String?> getSelectedRoomId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  /// Persist the selected room id.
  static Future<void> setSelectedRoomId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, id);
  }

  /// Clears the saved selection.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
