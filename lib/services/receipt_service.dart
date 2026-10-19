import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/receipt_model.dart';

/// Handles all Firestore + Storage operations for receipts.
class ReceiptService {
  static final CollectionReference _receiptsRef =
      FirebaseFirestore.instance.collection('receipts');

  /// Saves a new receipt document to Firestore.
  static Future<void> saveReceipt(ReceiptModel receipt) async {
    await _receiptsRef.add(receipt.toMap());
  }

  /// Streams all receipts belonging to a given user, newest first.
  static Stream<List<ReceiptModel>> streamUserReceipts(String userId) {
    return _receiptsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ReceiptModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Deletes a receipt by its Firestore document id.
  static Future<void> deleteReceipt(String id) async {
    await _receiptsRef.doc(id).delete();
  }

  /// Uploads the receipt image to Firebase Storage and returns its download URL.
  /// Returns null (silently) if the upload fails, so saving the receipt data
  /// never blocks on image upload issues.
  static Future<String?> uploadReceiptImage(String userId, File imageFile) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('receipts')
          .child(userId)
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }
}
