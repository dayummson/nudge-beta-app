import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Service for managing device-specific account restrictions.
///
/// This ensures that only one user account can be created per device,
/// preventing account proliferation and maintaining data integrity.
class DeviceService {
  static const String _deviceHasAccountKey = 'device_has_account';
  static const String _deviceAccountIdKey = 'device_account_id';

  /// Checks if this device already has an associated user account.
  Future<bool> hasDeviceAccount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_deviceHasAccountKey) ?? false;
  }

  /// Gets the account ID associated with this device.
  Future<String?> getDeviceAccountId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_deviceAccountIdKey);
  }

  /// Marks this device as having an account and associates it with the given account ID.
  ///
  /// This should be called when a user successfully creates or links an account on this device.
  Future<void> markDeviceHasAccount(String accountId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_deviceHasAccountKey, true);
    await prefs.setString(_deviceAccountIdKey, accountId);

    debugPrint('📱 Device marked as having account: $accountId');
  }

  /// Clears the device account association.
  ///
  /// This should be called when a user signs out or deletes their account.
  Future<void> clearDeviceAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceHasAccountKey);
    await prefs.remove(_deviceAccountIdKey);

    debugPrint('📱 Device account association cleared');
  }

  /// Checks if the given account ID matches the device account.
  ///
  /// Returns true if the account ID matches the stored device account ID,
  /// or if no device account is stored (allowing first account creation).
  Future<bool> isAccountAllowedOnDevice(String accountId) async {
    final deviceAccountId = await getDeviceAccountId();
    if (deviceAccountId == null) {
      // No device account set yet, allow this account
      return true;
    }
    return deviceAccountId == accountId;
  }
}
