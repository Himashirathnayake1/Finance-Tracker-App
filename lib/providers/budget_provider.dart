import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'auth_provider.dart';
import '../models/transaction_model.dart';

class BudgetProvider extends ChangeNotifier {
  double? _monthlyBudget;
  double _spent = 0.0;

  double? get monthlyBudget => _monthlyBudget;
  double get spent => _spent;
  double get remaining => (_monthlyBudget ?? 0) - _spent;

  /// Get month-year key like "2025-09"
  String _getMonthKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}";
  }

  /// Load budget for current month
  Future<void> loadBudget(List<TransactionModel> transactions) async {
    final user = AuthProvider().currentUser;
    if (user == null) return;

    final monthKey = _getMonthKey(DateTime.now());

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('budget')
        .doc(monthKey);

    final doc = await docRef.get();
    if (doc.exists) {
      _monthlyBudget = doc.data()?['amount']?.toDouble();
    } else {
      _monthlyBudget = null;
    }

    // calculate spent this month
    _spent = transactions
        .where((tx) =>
            tx.date.year == DateTime.now().year &&
            tx.date.month == DateTime.now().month &&
            tx.type == "Expense") // only expenses reduce budget
        .fold(0.0, (sum, tx) => sum + tx.amount);

    notifyListeners();
  }

  /// Save budget for current month
  Future<void> setBudget(double amount) async {
    final user = AuthProvider().currentUser;
    if (user == null) return;

    final monthKey = _getMonthKey(DateTime.now());

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('budget')
        .doc(monthKey)
        .set({'amount': amount});

    _monthlyBudget = amount;
    notifyListeners();
  }
}
