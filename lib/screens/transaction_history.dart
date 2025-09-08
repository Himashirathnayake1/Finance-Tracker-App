import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_card.dart';
import '../widgets/filter_bar.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String? selectedCategory;
  DateTime? startDate;
  DateTime? endDate;



  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction History"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
            onPressed: () {
              setState(() {});// rebuild UI & refetch stream
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Refreshing transactions..."),
                  backgroundColor: Colors.green[400],
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          //  Filter Bar (Category + Date Range)
          FilterBar(
            categories: transactionProvider.categories,
            selectedCategory: selectedCategory,
            onCategoryChanged: (value) {
              setState(() => selectedCategory = value);
              transactionProvider.applyFilters(
                category: selectedCategory,
                startDate: startDate,
                endDate: endDate,
              );
            },
            onDateRangeSelected: (start, end) {
              setState(() {
                startDate = start;
                endDate = end;
              });
              transactionProvider.applyFilters(
                category: selectedCategory,
                startDate: startDate,
                endDate: endDate,
              );
            },
          ),

          // Transactions List
          Expanded(
            child: StreamBuilder(
              stream: transactionProvider.getUserTransactionsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          "No transactions yet",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final transactions = transactionProvider.filteredTransactions(snapshot.data!);

                if (transactions.isEmpty) {
                  return const Center(child: Text("No transactions match your filters."));
                }

                return ListView.separated(
                  itemCount: transactions.length,
                  separatorBuilder: (_, __) => const Divider(height: 0, thickness: 0.5),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return TransactionCard(
                      transaction: tx,
                      onDelete: () async {
                        await transactionProvider.deleteTransaction(tx.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Transaction deleted"),
                            backgroundColor: Colors.green[400],),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

    );
  }
}
