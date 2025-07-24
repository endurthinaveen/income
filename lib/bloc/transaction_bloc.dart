import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entities/transaction.dart';
import '../events/transaction_events.dart';
import '../state/transction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  static const _storageKey = 'transactions';

  TransactionBloc() : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
  }

  /// Loads the list of transactions from SharedPreferences
  Future<void> _onLoadTransactions(
      LoadTransactions event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        final List<TransactionEntity> transactions =
        decoded.map((e) => TransactionEntity.fromJson(e)).toList();
        emit(TransactionsLoaded(transactions));
      } else {
        emit(TransactionsLoaded([])); // ✅ Removed const
      }
    } catch (e) {
      emit(TransactionError('Failed to load transactions: $e')); // ✅ Ensure TransactionError exists
    }
  }
  /// Adds a new transaction, updates SharedPreferences and emits new state
  Future<void> _onAddTransaction(
      AddTransaction event, Emitter<TransactionState> emit) async {
    final prefs = await SharedPreferences.getInstance();

    if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      final updatedTransactions = List<TransactionEntity>.from(currentState.transactions)
        ..insert(0, event.transaction);

      // Save to SharedPreferences
      final jsonList = updatedTransactions.map((e) => e.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));

      emit(TransactionsLoaded(updatedTransactions));
    }
  }
}
