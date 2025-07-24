import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/transaction_bloc.dart';
import '../state/transction_state.dart';
import '../entities/transaction.dart';

class PaiChatScreen extends StatelessWidget {
  const PaiChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expense Distribution")),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionsLoaded) {
            final transactions = state.transactions;

            final incomeTransactions = transactions.where((t) => t.isIncome).toList();
            final expenseTransactions = transactions.where((t) => !t.isIncome).toList();

            final double totalIncome = incomeTransactions.fold(0.0, (sum, t) => sum + t.amount);
            final double totalExpense = expenseTransactions.fold(0.0, (sum, t) => sum + t.amount);
            final double balance = totalIncome - totalExpense;

            final List<PieChartSectionData> pieSections = [
              PieChartSectionData(
                color: Colors.green,
                value: totalIncome,
                title: 'Income\n₹${totalIncome.toStringAsFixed(0)}',
                radius: 90,
                titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              PieChartSectionData(
                color: Colors.red,
                value: totalExpense,
                title: 'Expense\n₹${totalExpense.toStringAsFixed(0)}',
                radius: 90,
                titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "Income vs Expense",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 300,
                    child: PieChart(
                      PieChartData(
                        sections: pieSections,
                        centerSpaceRadius: 40,
                        sectionsSpace: 6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Divider(thickness: 1),
                  const SizedBox(height: 20),
                  _buildSummaryRow("Total Income", totalIncome, Colors.green),
                  const SizedBox(height: 10),
                  _buildSummaryRow("Total Expense", totalExpense, Colors.red),
                  const SizedBox(height: 10),
                  _buildSummaryRow("Balance", balance, balance >= 0 ? Colors.blue : Colors.red),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildSummaryRow(String title, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        Text(
          "₹${amount.toStringAsFixed(2)}",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
