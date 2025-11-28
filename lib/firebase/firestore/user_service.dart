import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nudge_1/firebase/firestore/firestore_client.dart';
import 'package:nudge_1/features/auth/domain/entities/user.dart' as domain_user;

class UserService {
  UserService();

  final FirebaseFirestore _firestore = FirestoreClient.instance.firestore;

  String get _collection => 'users';

  DocumentReference<Map<String, dynamic>> userRef(String uid) =>
      _firestore.collection(_collection).doc(uid);

  /// Stream the user document as a map (or null if absent)
  Stream<Map<String, dynamic>?> userStream(String uid) {
    return userRef(uid).snapshots().map((snap) => snap.data());
  }

  /// Create or update a complete user document
  Future<void> createOrUpdateUser(domain_user.User user) async {
    debugPrint('👤 Creating/updating user in Firestore: ${user.id}');
    debugPrint('🖼️ User profilePhotoUrl: ${user.profilePhotoUrl}');

    final userData = {
      'id': user.id,
      'email': user.email,
      'username': user.username,
      'displayName': user.displayName,
      'phoneNumber': user.phoneNumber,
      'profilePhotoUrl': user.profilePhotoUrl,
      'createdAt': user.createdAt != null
          ? Timestamp.fromDate(user.createdAt!)
          : FieldValue.serverTimestamp(),
      'lastUpdatedAt': FieldValue.serverTimestamp(),
      'isSynced': true,
    };

    debugPrint('📝 User data to save: $userData');
    await userRef(user.id).set(userData, SetOptions(merge: true));
    debugPrint('✅ User data synced to Firestore successfully');
  }

  /// Get user data from Firestore
  Future<domain_user.User?> getUser(String uid) async {
    debugPrint('🔍 Getting user data from Firestore: $uid');
    final doc = await userRef(uid).get();

    if (!doc.exists || doc.data() == null) {
      debugPrint('❌ User document not found');
      return null;
    }

    final data = doc.data()!;
    debugPrint('📝 Retrieved user data: ${data['displayName']}');
    debugPrint('🖼️ Retrieved profilePhotoUrl: ${data['profilePhotoUrl']}');

    return domain_user.User(
      id: data['id'] ?? uid,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      displayName: data['displayName'] ?? '',
      phoneNumber: data['phoneNumber'],
      profilePhotoUrl: data['profilePhotoUrl'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Example: update a user's displayName field
  Future<void> updateDisplayName(String uid, String displayName) async {
    await userRef(uid).set({
      'displayName': displayName,
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Get a user's display name
  Future<String?> getDisplayName(String uid) async {
    debugPrint('🔍 Getting display name for user: $uid');
    final doc = await userRef(uid).get();
    final displayName = doc.data()?['displayName'] as String?;
    debugPrint('📝 Retrieved display name: $displayName');
    return displayName;
  }

  /// Set a user's display name (alias for updateDisplayName)
  Future<void> setDisplayName(String uid, String displayName) async {
    debugPrint('💾 Setting display name for user $uid: $displayName');
    await updateDisplayName(uid, displayName);
    debugPrint('✅ Display name set successfully');
  }

  /// Create a user document with an email field. Uses `uid` as document id.
  Future<void> createUser(String uid, {required String email}) async {
    await userRef(uid).set({
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdatedAt': FieldValue.serverTimestamp(),
      'isSynced': true,
    }, SetOptions(merge: true));
  }
}
