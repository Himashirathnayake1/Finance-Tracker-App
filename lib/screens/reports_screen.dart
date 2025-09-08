import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../providers/report_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<ReportProvider>(context);
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Financial Reports & Insights"),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: transactionProvider.getUserTransactionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading reports: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No transactions available to generate reports."),
            );
          }

          final transactions = snapshot.data!;
          reportProvider.generateReport(transactions);

          final insights = reportProvider.getInsights();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Pie Chart
                const SectionTitle("Category-wise Spending"),
                const SizedBox(height: 200, child: _CategoryPieChart()),

                const SizedBox(height: 24),

                // Bar Chart
                const SectionTitle("Income vs Expense"),
                const SizedBox(height: 200, child: _IncomeExpenseBarChart()),

                const SizedBox(height: 24),

                // Insights
                const SectionTitle("Insights"),
                if (insights.isEmpty)
                  const Text("No insights available yet."),
                ...insights.map(
                  (msg) => ListTile(
                    leading: const Icon(Icons.lightbulb, color: Colors.amber),
                    title: Text(msg, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

///  Reusable Section Title
class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

///  Pie Chart
class _CategoryPieChart extends StatelessWidget {
  const _CategoryPieChart();

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<ReportProvider>(context);

    if (reportProvider.categoryTotals.isEmpty) {
      return const Center(child: Text("No expenses recorded."));
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 30,
        sections: reportProvider.categoryTotals.entries.map((entry) {
          return PieChartSectionData(
            value: entry.value,
            title: "${entry.key}\n${entry.value.toStringAsFixed(0)}",
            radius: 60,
            titleStyle: Theme.of(context).textTheme.bodyMedium,
          );
        }).toList(),
      ),
    );
  }
}

///  Bar Chart
class _IncomeExpenseBarChart extends StatelessWidget {
  const _IncomeExpenseBarChart();

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<ReportProvider>(context);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return const Text("Income");
                  case 1:
                    return const Text("Expense");
                  default:
                    return const SizedBox();
                }
              },
            ),
          ),
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: reportProvider.totalIncome,
                color: Colors.green,
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: reportProvider.totalExpense,
                color: Colors.red,
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
