import 'package:cloud_firestore/cloud_firestore.dart';

/// Simple singleton wrapper around [FirebaseFirestore.instance].
/// Use `FirestoreClient.instance.firestore` to access the client.
class FirestoreClient {
  FirestoreClient._() {
    // Try to enable local persistence and set a reasonable cache size.
    // This is done once when the singleton is first accessed.
    try {
      FirebaseFirestore.instance.settings = Settings(
        persistenceEnabled: true,
        // 100 MB cache; adjust as needed
        cacheSizeBytes: 100 * 1024 * 1024,
      );
      _persistenceEnabled = true;
    } catch (e) {
      // On platforms where persistence can't be enabled or settings were
      // already applied, this may throw; swallow and optionally log.
      // Avoid using print in production — keeping it informational here.
      // ignore: avoid_print
      print('Firestore persistence could not be enabled: $e');
      _persistenceEnabled = false;
    }
  }

  static final FirestoreClient _instance = FirestoreClient._();

  static FirestoreClient get instance => _instance;

  bool _persistenceEnabled = false;

  /// Whether local persistence was enabled successfully when the client
  /// was initialized. This can be used by services to decide whether to
  /// operate in offline-first or fallback modes.
  bool get persistenceEnabled => _persistenceEnabled;

  FirebaseFirestore get firestore => FirebaseFirestore.instance;
}
