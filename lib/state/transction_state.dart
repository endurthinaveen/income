import '../entities/transaction.dart';

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionsLoaded extends TransactionState {
  final List<TransactionEntity> transactions;

  TransactionsLoaded(this.transactions);

  double get totalIncome =>
      transactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense =>
      transactions.where((t) => !t.isIncome).fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;
}

class TransactionError extends TransactionState {
  final String message;

  TransactionError(this.message);
}
