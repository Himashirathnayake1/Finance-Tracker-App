import 'package:finance_tracker_app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Monthly Budget"),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: transactionProvider.getUserTransactionsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data!;
          budgetProvider.loadBudget(transactions);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Input field to set budget
                Row(
                  children: [
                    Expanded(
                      child:  CustomTextField(
            controller: _controller,
            label: "Enter Monthly Budget",
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            icon: Icons.attach_money,
          ),

                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final amount = double.tryParse(_controller.text);
                        if (amount != null) {
                          await budgetProvider.setBudget(amount);
                          _controller.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Budget set successfully")),
                          );
                        }
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Budget Progress
                if (budgetProvider.monthlyBudget != null)
                  Column(
                    children: [
                      Text(
                        "Budget: Rs.${budgetProvider.monthlyBudget!.toStringAsFixed(2)}",style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 10),
                      Text(
                        "Spent: Rs.${budgetProvider.spent.toStringAsFixed(2)}",style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red)
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Remaining: Rs.${budgetProvider.remaining.toStringAsFixed(2)}",
                        style: Theme.of(context).textTheme.bodyLarge
                      ),
                      const SizedBox(height: 25),

                      // Progress bar
                      LinearProgressIndicator(
                        value: budgetProvider.monthlyBudget! > 0
                            ? budgetProvider.spent / budgetProvider.monthlyBudget!
                            : 0,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          budgetProvider.spent > budgetProvider.monthlyBudget!
                              ? Colors.red
                              : Colors.green,
                        ),
                        minHeight: 12,
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
