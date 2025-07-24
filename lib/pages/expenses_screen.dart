import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../bloc/transaction_bloc.dart';
import '../entities/transaction.dart';
import '../events/transaction_events.dart';

class ExpenseEntryScreen extends StatefulWidget {
  const ExpenseEntryScreen({super.key});

  @override
  State<ExpenseEntryScreen> createState() => _ExpenseEntryScreenState();
}

class _ExpenseEntryScreenState extends State<ExpenseEntryScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String selectedCategory = '';
  String selectedWallet = '';
  DateTime selectedDate = DateTime.now();
  File? _pickedImage;


  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); // Or ImageSource.camera

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade600,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text('Expense', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Text("How much?", style: TextStyle(color: Colors.white, fontSize: 18)),
          Text(
            "₹${amountController.text.isEmpty ? '0' : amountController.text}",
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Amount"),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory.isEmpty ? null : selectedCategory,
                    items: ['Food', 'Shopping', 'Travel', 'Utilities']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => setState(() => selectedCategory = value ?? ''),
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedWallet.isEmpty ? null : selectedWallet,
                    items: ['Cash', 'Card', 'UPI']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => setState(() => selectedWallet = value ?? ''),
                    decoration: const InputDecoration(labelText: 'Wallet'),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.attachment, color: Colors.grey),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _pickedImage != null ? "Image selected" : "Add attachment",
                              style: TextStyle(
                                color: _pickedImage != null ? Colors.green : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (_pickedImage != null)
                            const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Repeat", style: TextStyle(fontSize: 16)),
                      Switch(value: false, onChanged: null),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Date", style: TextStyle(fontSize: 16)),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                        onPressed: () => _pickDate(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _submitExpense,
                    child: const Text("Continue"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _submitExpense() async {
    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0 || selectedCategory.isEmpty || selectedWallet.isEmpty) return;

    final transaction = TransactionEntity(
      title: selectedCategory,
      subtitle: descriptionController.text.isEmpty ? 'No description' : descriptionController.text,
      time: DateFormat('hh:mm a').format(selectedDate),

      amount: amount,
      isIncome: false,
      icon: Icons.shopping_cart,
      color: Colors.red,
      category: '',
      dateTime: selectedDate,
    );

    context.read<TransactionBloc>().add(AddTransaction(transaction));
    Navigator.pop(context);
  }

}
