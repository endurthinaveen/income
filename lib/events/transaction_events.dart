import '../entities/transaction.dart';

abstract class TransactionEvent {}

class LoadTransactions extends TransactionEvent {}

class AddTransaction extends TransactionEvent {
  final TransactionEntity transaction;

  AddTransaction(this.transaction);
}
