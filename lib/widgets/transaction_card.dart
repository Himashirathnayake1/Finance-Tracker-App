import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onDelete;


  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onDelete,

  });

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat("yyyy-MM-dd").format(transaction.date);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              transaction.type == "Income" ? Colors.green : Colors.red,
          child: Icon(
            transaction.type == "Income"
                ? Icons.arrow_downward
                : Icons.arrow_upward,
            color: Colors.white,
          ),
        ),
        title: Text(
          "LKR ${transaction.amount.toStringAsFixed(2)} - ${transaction.category}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("$dateFormatted • ${transaction.description}"),

        trailing: PopupMenuButton<String>(
          onSelected: (value) {
           if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'delete', child: Text("Delete")),
              ],
        ),
      ),
    );
  }
}
