import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class ReportProvider extends ChangeNotifier {
  Map<String, double> _categoryTotals = {};
  double _totalIncome = 0;
  double _totalExpense = 0;

  Map<String, double> get categoryTotals => _categoryTotals;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;

  /// Process transactions for current month
  void generateReport(List<TransactionModel> transactions) {
    final now = DateTime.now();
    final monthlyTx = transactions.where((tx) =>
        tx.date.year == now.year && tx.date.month == now.month);

    _categoryTotals = {};
    _totalIncome = 0;
    _totalExpense = 0;

    for (var tx in monthlyTx) {
      if (tx.type == "Income") {
        _totalIncome += tx.amount;
      } else {
        _totalExpense += tx.amount;
        _categoryTotals[tx.category] =
            (_categoryTotals[tx.category] ?? 0) + tx.amount;
      }
    }

    notifyListeners();
  }

  /// Generate insights
  List<String> getInsights() {
    List<String> insights = [];

    if (_totalIncome > 0) {
      _categoryTotals.forEach((category, amount) {
        final percent = (amount / _totalIncome) * 100;
        insights.add("You spent ${percent.toStringAsFixed(1)}% of income on $category");
      });
    }

    if (_totalExpense > _totalIncome && _totalIncome > 0) {
      insights.add("⚠️ You spent more than your income this month!");
    }

    if (_totalExpense == 0) {
      insights.add("Great job! No expenses recorded this month.");
    }

    return insights;
  }
}
