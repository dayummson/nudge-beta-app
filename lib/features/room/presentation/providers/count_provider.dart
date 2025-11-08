import 'package:flutter/foundation.dart';

// A tiny, framework-agnostic counter using ValueNotifier. This avoids
// Riverpod configuration issues and provides a simple observable counter
// that the UI can listen to with a ValueListenableBuilder.
final ValueNotifier<int> counter = ValueNotifier<int>(0);
