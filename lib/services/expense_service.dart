import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expense.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _expenses =>
      _firestore.collection('expenses');

  Future<void> addExpense(Expense expense) async {
    await _expenses.add(expense.toFirestore());
  }

  Future<void> updateExpense(Expense expense) async {
    await _expenses
        .doc(expense.id)
        .update(expense.toFirestore());
  }

  Future<void> deleteExpense(String id) async {
    await _expenses.doc(id).delete();
  }

  Stream<List<Expense>> getExpenses() {
    return _expenses
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(Expense.fromFirestore)
              .toList(),
        );
  }
}