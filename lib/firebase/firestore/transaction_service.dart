import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/foundation.dart';
import 'package:nudge_1/firebase/firestore/firestore_client.dart';
import 'package:nudge_1/features/room/domain/entities/transaction.dart';
import 'package:nudge_1/features/room/domain/entities/category.dart' as domain;
import 'package:nudge_1/features/room/domain/entities/place_location.dart';

class TransactionService {
  TransactionService();

  final firestore.FirebaseFirestore _firestore =
      FirestoreClient.instance.firestore;

  String get _collection => 'rooms';

  /// Create a transaction in Firestore as a subcollection under a room
  Future<void> createTransaction({
    required String roomId,
    required Transaction transaction,
  }) async {
    debugPrint(
      '💰 Creating transaction in Firestore: ${transaction.id} for room: $roomId',
    );

    // Convert transaction to Firestore format
    final transactionData = {
      'id': transaction.id,
      'description': transaction.description,
      'category': transaction.category.toJson(),
      'amount': transaction.amount,
      'location': transaction.location != null
          ? {
              'lat': transaction.location!.lat,
              'lng': transaction.location!.lng,
              'address': transaction.location!.address,
            }
          : null,
      'hashtags': transaction.hashtags,
      'createdAt': firestore.Timestamp.fromDate(transaction.createdAt),
      'updatedAt': transaction.updatedAt != null
          ? firestore.Timestamp.fromDate(transaction.updatedAt!)
          : null,
      'type': transaction.type.name,
      'isSynced': true,
      'lastUpdatedAt': firestore.Timestamp.fromDate(transaction.lastUpdatedAt),
    };

    await _firestore
        .collection(_collection)
        .doc(roomId)
        .collection('transactions')
        .doc(transaction.id)
        .set(transactionData);

    debugPrint('✅ Transaction created in Firestore successfully');
  }

  /// Update a transaction in Firestore
  Future<void> updateTransaction({
    required String roomId,
    required Transaction transaction,
  }) async {
    debugPrint(
      '📝 Updating transaction in Firestore: ${transaction.id} for room: $roomId',
    );

    final transactionData = {
      'id': transaction.id,
      'description': transaction.description,
      'category': transaction.category.toJson(),
      'amount': transaction.amount,
      'location': transaction.location != null
          ? {
              'lat': transaction.location!.lat,
              'lng': transaction.location!.lng,
              'address': transaction.location!.address,
            }
          : null,
      'hashtags': transaction.hashtags,
      'createdAt': firestore.Timestamp.fromDate(transaction.createdAt),
      'updatedAt': transaction.updatedAt != null
          ? firestore.Timestamp.fromDate(transaction.updatedAt!)
          : null,
      'type': transaction.type.name,
      'isSynced': true,
      'lastUpdatedAt': firestore.Timestamp.fromDate(transaction.lastUpdatedAt),
    };

    await _firestore
        .collection(_collection)
        .doc(roomId)
        .collection('transactions')
        .doc(transaction.id)
        .update(transactionData);

    debugPrint('✅ Transaction updated in Firestore successfully');
  }

  /// Delete a transaction from Firestore
  Future<void> deleteTransaction({
    required String roomId,
    required String transactionId,
  }) async {
    debugPrint(
      '🗑️ Deleting transaction from Firestore: $transactionId for room: $roomId',
    );

    await _firestore
        .collection(_collection)
        .doc(roomId)
        .collection('transactions')
        .doc(transactionId)
        .delete();

    debugPrint('✅ Transaction deleted from Firestore successfully');
  }

  /// Get all transactions for a room from Firestore
  Future<List<Transaction>> getRoomTransactions(String roomId) async {
    debugPrint('📋 Getting transactions for room: $roomId from Firestore');

    final snapshot = await _firestore
        .collection(_collection)
        .doc(roomId)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .get();

    final transactions = snapshot.docs.map((doc) {
      final data = doc.data();
      return Transaction(
        id: data['id'],
        description: data['description'],
        category: domain.Category.fromJson(data['category']),
        amount: data['amount'],
        location: data['location'] != null
            ? PlaceLocation(
                lat: data['location']['lat'],
                lng: data['location']['lng'],
                address: data['location']['address'],
              )
            : null,
        hashtags: List<String>.from(data['hashtags'] ?? []),
        createdAt: (data['createdAt'] as firestore.Timestamp).toDate(),
        updatedAt: data['updatedAt'] != null
            ? (data['updatedAt'] as firestore.Timestamp).toDate()
            : null,
        type: data['type'] == 'income'
            ? TransactionType.income
            : TransactionType.expense,
        isSynced: true,
        lastUpdatedAt: (data['lastUpdatedAt'] as firestore.Timestamp).toDate(),
      );
    }).toList();

    debugPrint(
      '✅ Retrieved ${transactions.length} transactions from Firestore',
    );
    return transactions;
  }

  /// Stream transactions for a room from Firestore
  Stream<List<Transaction>> watchRoomTransactions(String roomId) {
    debugPrint('👀 Watching transactions for room: $roomId from Firestore');

    return _firestore
        .collection(_collection)
        .doc(roomId)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Transaction(
              id: data['id'],
              description: data['description'],
              category: domain.Category.fromJson(data['category']),
              amount: data['amount'],
              location: data['location'] != null
                  ? PlaceLocation(
                      lat: data['location']['lat'],
                      lng: data['location']['lng'],
                      address: data['location']['address'],
                    )
                  : null,
              hashtags: List<String>.from(data['hashtags'] ?? []),
              createdAt: (data['createdAt'] as firestore.Timestamp).toDate(),
              updatedAt: data['updatedAt'] != null
                  ? (data['updatedAt'] as firestore.Timestamp).toDate()
                  : null,
              type: data['type'] == 'income'
                  ? TransactionType.income
                  : TransactionType.expense,
              isSynced: true,
              lastUpdatedAt: (data['lastUpdatedAt'] as firestore.Timestamp)
                  .toDate(),
            );
          }).toList();
        });
  }
}
