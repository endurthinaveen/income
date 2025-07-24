import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:personal_expenses_tracker/pages/pai_chat_screen.dart';
import 'package:personal_expenses_tracker/pages/transactions_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/transaction_bloc.dart';
import '../entities/transaction.dart';
import '../events/transaction_events.dart';
import '../state/transction_state.dart';
import 'expenses_screen.dart';
import 'income_screen.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedTab = 'Today';
  DateTime selectedDate = DateTime.now();
  int _currentIndex = 0;
  bool _isExpanded = false;




  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTransactions());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                if (state is TransactionsLoaded) {
                  return _buildSummary(state.totalIncome, state.totalExpense); // ✅ CORRECT
                }
                return const CircularProgressIndicator();
              },
            ),

            _buildChartPlaceholder(),
            _buildTabBar(),
            _buildRecentTransactionHeader(),
            Expanded(
              child: BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  if (state is TransactionsLoaded) {
                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: state.transactions
                          .reversed
                          .take(5)
                          .map((t) => _buildTransactionTile(
                        t.title,
                        t.subtitle,
                        t.time,
                        (t.isIncome ? '+' : '-') + '₹${t.amount}',
                        t.icon,
                        t.color,
                      ))
                          .toList(),

                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            )

          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: 'income',
            backgroundColor: const Color(0xFF00A86B), // same green
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const IncomeEntryScreen()),
              );
              context.read<TransactionBloc>().add(LoadTransactions());
            },
            child: Image.asset(
              'assets/images/in.png',
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 20),
          FloatingActionButton(
            heroTag: 'expense',
            backgroundColor: const Color(0xFFD32F2F), // same red
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExpenseEntryScreen()),
              );
              context.read<TransactionBloc>().add(LoadTransactions());
            },
            child: Image.asset(
              'assets/images/out.png',
              width: 24,
              height: 24,
            ),
          ),

        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == _currentIndex) return;

          setState(() => _currentIndex = index);

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TransactionsScreen(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaiChatScreen(),
              ),
            );
          }
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Transaction'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Budget'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),

    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage('assets/images/avatar.png'),
        ),
        GestureDetector(
          onTap: () => _selectMonth(context), // ✅ CONNECTED HERE
          child: Row(
            children: [
              Text(
                DateFormat.yMMMM().format(selectedDate), // shows "July 2024"
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
        const Icon(
          Icons.notifications,
          color: Colors.deepPurple, // Or any color you want
        ),

      ],
    ),
  );


  Widget _buildSummary(double income, double expense) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Center align content
      children: [
        const Text(
          "Account Balance",
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          "₹${income - expense}",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const IncomeEntryScreen()),
                  );
                  context.read<TransactionBloc>().add(LoadTransactions());
                },
                child: _buildSummaryCard(
                  "Income",
                  "₹$income",
                  "assets/images/in.png",
                  const Color(0xFF00A86B),
                ),
              ),
            ),

            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                "Expenses",
                "₹$expense",
                "assets/images/out.png",
                const Color(0xFFD32F2F), // Dark red background
              ),
            ),


          ],
        ),

      ],
    ),
  );


  Widget _buildChartPlaceholder() => Column(
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text("Spend Frequency", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
      const SizedBox(height: 12),
      Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text("[Line Chart Placeholder]")),
      ),
    ],
  );

  Widget _buildTabBar() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ['Today', 'Week', 'Month', 'Year'].map((label) {
        final isSelected = selectedTab == label;
        return GestureDetector(
          onTap: () => setState(() => selectedTab = label),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.deepPurple : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );

  Widget _buildRecentTransactionHeader() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Recent Transaction", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TransactionsScreen()),
            );
          },
          child: const Text(
            "See All",
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    ),

  );
  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Select Month',
      fieldLabelText: 'Month',
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget _buildSummaryCard(String title, String amount, String imagePath, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 20,
            child: Image.asset(
              imagePath,
              width: 22,
              height: 22,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.white)),
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          )
        ],
      ),
    );
  }



  Widget _buildTransactionTile(String title, String subtitle, String time, String amount, IconData icon, Color color) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 1,
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text("$subtitle • $time"),
      trailing: Text(
        amount,
        style: TextStyle(fontWeight: FontWeight.bold, color: color),
      ),
    ),
  );
}