import 'package:finance_tracker_app/screens/add_transaction_screen.dart';
import 'package:finance_tracker_app/screens/budget_screen.dart';
import 'package:finance_tracker_app/screens/login_screen.dart';
import 'package:finance_tracker_app/screens/reports_screen.dart';
import 'package:finance_tracker_app/screens/transaction_history.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  /// summary card widget for income, expenses, balance
  Widget summaryCard(
    BuildContext context,
    String title,
    double amount,
    List<Color> gradientColors,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                title == "Total Income"
                    ? Icons.arrow_upward
                    : title == "Total Expenses"
                    ? Icons.arrow_downward
                    : Icons.account_balance_wallet,
                size:
                    MediaQuery.of(context).size.width * 0.08, 
            
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
               
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "LKR ${amount.toStringAsFixed(2)}",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
               
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// quick action button widget for add transaction, view history, budget, reports
  Widget quickButton(String title, IconData icon, VoidCallback onTap,BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.green.withOpacity(0.2), 
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          color: Colors.green.withOpacity(
            0.1,
          ), 
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,  size: MediaQuery.of(context).size.width * 0.08
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("No user logged in")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),

        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: Text(
                        "Logout",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      content: Text(
                        "Are you sure you want to log out?",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            "Cancel",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            ).logout();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          child: const Text("Logout"),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('transactions')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.green[400]));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_balance_wallet_outlined),
                    const SizedBox(height: 16),
                    Text(
                      "No transactions yet",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Start tracking your income and expenses\nby adding your first transaction.",
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddTransactionScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add Your First Transaction"),
                    ),
                  ],
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Something went wrong. Please try again later.",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DashboardScreen(),
                          ),
                        ),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }
// Calculate totals
          double income = 0;
          double expenses = 0;

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;

            // Safe parsing of amount
            final rawAmount = data['amount'];
            final amount =
                (rawAmount is int)
                    ? rawAmount.toDouble()
                    : (rawAmount is double ? rawAmount : 0.0);

            if (data['type'] == 'Income') {
              income += amount;
            } else if (data['type'] == 'Expense') {
              expenses += amount;
            }
          }

          final balance = income - expenses;
//UI
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                summaryCard(context, "Total Income", income, [
                  Colors.green.shade700,
                  const Color.fromARGB(255, 111, 241, 118),
                ]),
                summaryCard(context, "Total Expenses", expenses, [
                  const Color.fromARGB(255, 241, 118, 116),
                  Colors.red.shade700,
                ]),

                summaryCard(context, "Balance", balance, [
                  Colors.blue.shade700,
                  const Color.fromARGB(255, 108, 177, 233),
                ]),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),

                Row(
                  children: [
                    quickButton("Add Transaction", Icons.add, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddTransactionScreen(),
                        ),
                      );
                    }, context),
                    const SizedBox(width: 12),
                    quickButton("View History", Icons.list, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TransactionHistoryScreen(),
                        ),
                      );
                    }, context),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    quickButton("Budget", Icons.pie_chart, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BudgetScreen()),
                      );
                    }, context),
                    const SizedBox(width: 12),
                    quickButton("Reports", Icons.bar_chart, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportsScreen(),
                        ),
                      );
                      
                    }, context),
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
