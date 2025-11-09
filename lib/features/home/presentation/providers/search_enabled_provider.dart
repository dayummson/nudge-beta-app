import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier for managing search enabled state
class SearchEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Toggle search enabled state
  void toggle() => state = !state;

  /// Set search enabled state
  void setEnabled(bool enabled) => state = enabled;
}

/// Provider for managing search enabled state
///
/// Controls whether the search functionality is enabled/visible in the home screen.
/// Defaults to false (search disabled).
final searchEnabledProvider = NotifierProvider<SearchEnabledNotifier, bool>(
  SearchEnabledNotifier.new,
);
