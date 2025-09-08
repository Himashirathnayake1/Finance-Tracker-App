import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String type; // "Income" or "Expense"
  final String description;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    required this.description,
  });

  /// Convert Firestore doc → TransactionModel
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      type: data['type'] ?? '',
      description: data['description'] ?? '',
    );
  }

  /// Convert TransactionModel → JSON (for saving in Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'type': type,
      'description': description,
    };
  }
}
