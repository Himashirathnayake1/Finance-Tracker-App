import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import 'auth_provider.dart';

class TransactionProvider extends ChangeNotifier {
  //  Added "All" option
  final categories = const ["All", "Food", "Travel", "Salary", "Shopping", "Bills", "Other"];

  String? _categoryFilter;
  DateTime? _startDate;
  DateTime? _endDate;

  String? get categoryFilter => _categoryFilter;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  /// Firestore stream for user transactions
  Stream<List<TransactionModel>> getUserTransactionsStream() {
    final user = AuthProvider().currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList());
  }

  /// Apply filters
  void applyFilters({String? category, DateTime? startDate, DateTime? endDate}) {
    //  If category is "All", treat it as no filter
    _categoryFilter = (category == "All") ? null : category;
    _startDate = startDate;
    _endDate = endDate;
    notifyListeners();
  }

  /// Filtered list in memory
  List<TransactionModel> filteredTransactions(List<TransactionModel> all) {
    return all.where((tx) {
      final matchesCategory = _categoryFilter == null || tx.category == _categoryFilter;
      final matchesStart = _startDate == null || !tx.date.isBefore(_startDate!);
      final matchesEnd = _endDate == null || !tx.date.isAfter(_endDate!);
      return matchesCategory && matchesStart && matchesEnd;
    }).toList();
  }

  /// Add new transaction
  Future<String?> addTransaction({
    required double amount,
    required String category,
    required DateTime date,
    required String type,
    String? description,
  }) async {
    try {
      final user = AuthProvider().currentUser;
      if (user == null) return "User not logged in";

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .doc();

      final transaction = TransactionModel(
        id: docRef.id,
        amount: amount,
        category: category,
        date: date,
        type: type,
        description: description ?? "",
      );

      await docRef.set(transaction.toFirestore());
      notifyListeners();
      return null;
    } on FirebaseException catch (e) {
      return "Firestore error: ${e.message ?? e.code}";
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  /// Delete transaction
  Future<String?> deleteTransaction(String id) async {
    try {
      final user = AuthProvider().currentUser;
      if (user == null) return "User not logged in";

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .doc(id)
          .delete();

      notifyListeners();
      return null;
    } on FirebaseException catch (e) {
      return e.message ?? "Firestore error occurred";
    } catch (e) {
      return "Unexpected error: $e";
    }
  }
}
