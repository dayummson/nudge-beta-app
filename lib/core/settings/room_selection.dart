import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple helper to persist the user's currently selected room id.
/// Key: 'selected_room_id'
class RoomSelection {
  static const _key = 'selected_room_id';

  /// Notifier that emits the currently selected room id. Use this to listen
  /// for selection changes in the UI so widgets update immediately.
  static final ValueNotifier<String?> selectedRoom = ValueNotifier(null);

  /// Returns the saved room id or null if none set. Also updates the
  /// [selectedRoom] notifier with the loaded value.
  static Future<String?> getSelectedRoomId() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    // update notifier so listeners refresh
    selectedRoom.value = value;
    return value;
  }

  /// Persist the selected room id and notify listeners.
  static Future<void> setSelectedRoomId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, id);
    selectedRoom.value = id;
  }

  /// Clears the saved selection and notifies listeners.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    selectedRoom.value = null;
  }
}
