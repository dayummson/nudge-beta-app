import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nudge_1/firebase/firestore/firestore_client.dart';

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

  /// Example: update a user's displayName field
  Future<void> updateDisplayName(String uid, String displayName) async {
    await userRef(
      uid,
    ).set({'displayName': displayName}, SetOptions(merge: true));
  }

  /// Create a user document with an email field. Uses `uid` as document id.
  Future<void> createUser(String uid, {required String email}) async {
    await userRef(uid).set({'email': email}, SetOptions(merge: true));
  }
}
