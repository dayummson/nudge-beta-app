import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nudge_1/firebase/firestore/firestore_client.dart';

class RoomService {
  RoomService();

  final FirebaseFirestore _firestore = FirestoreClient.instance.firestore;

  String get _collection => 'rooms';

  DocumentReference<Map<String, dynamic>> roomRef(String roomId) =>
      _firestore.collection(_collection).doc(roomId);

  /// Create a shared room in Firestore
  Future<void> createSharedRoom({
    required String roomId,
    required String name,
    required String ownerId,
    required List<String> users,
  }) async {
    debugPrint(
      '🏠 Creating shared room: $roomId, name: $name, owner: $ownerId, users: $users',
    );
    await roomRef(roomId).set({
      'name': name,
      'ownerId': ownerId,
      'users': users,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    debugPrint('✅ Shared room created successfully in Firestore');
  }

  /// Update room users
  Future<void> updateRoomUsers(String roomId, List<String> users) async {
    await roomRef(
      roomId,
    ).update({'users': users, 'updatedAt': FieldValue.serverTimestamp()});
  }
}
