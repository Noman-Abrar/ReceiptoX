import 'package:cloud_firestore/cloud_firestore.dart';

/// Structured representation of a scanned receipt, stored in Firestore
/// under the `receipts` collection.
class ReceiptModel {
  final String id;
  final String userId;
  final String vendor;
  final double amount;
  final DateTime date;
  final String category;
  final String rawText;
  final String? imageUrl;
  final DateTime createdAt;

  ReceiptModel({
    required this.id,
    required this.userId,
    required this.vendor,
    required this.amount,
    required this.date,
    required this.category,
    required this.rawText,
    this.imageUrl,
    required this.createdAt,
  });

  factory ReceiptModel.fromMap(String id, Map<String, dynamic> map) {
    return ReceiptModel(
      id: id,
      userId: map['userId'] ?? '',
      vendor: map['vendor'] ?? 'Unknown Vendor',
      amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : 0.0,
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: map['category'] ?? 'Other',
      rawText: map['rawText'] ?? '',
      imageUrl: map['imageUrl'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'vendor': vendor,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'category': category,
      'rawText': rawText,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
