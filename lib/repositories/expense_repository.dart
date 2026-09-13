import '../db/database_service.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  Future<List<ExpenseModel>> getExpenses(int userId) async {
    final conn = await DatabaseService.getConnection();

    final result = await conn.execute(
      '''
      SELECT * FROM expenses
      WHERE user_id = :userId
      ORDER BY expense_date DESC
      ''',
      {'userId': userId},
    );

    await conn.close();

    return result.rows
        .map((row) => ExpenseModel.fromMap(row.assoc()))
        .toList();
  }

  Future<void> addExpense({
    required int userId,
    required String title,
    required double amount,
    required String location,
    required String expenseDate,
  }) async {
    final conn = await DatabaseService.getConnection();

    await conn.execute(
      '''
      INSERT INTO expenses(user_id, title, amount, location, expense_date)
      VALUES(:userId, :title, :amount, :location, :expenseDate)
      ''',
      {
        'userId': userId,
        'title': title,
        'amount': amount,
        'location': location,
        'expenseDate': expenseDate,
      },
    );

    await conn.close();
  }

  Future<void> updateExpense({
    required int id,
    required String title,
    required double amount,
    required String location,
    required String expenseDate,
  }) async {
    final conn = await DatabaseService.getConnection();

    await conn.execute(
      '''
      UPDATE expenses
      SET title = :title,
          amount = :amount,
          location = :location,
          expense_date = :expenseDate
      WHERE id = :id
      ''',
      {
        'id': id,
        'title': title,
        'amount': amount,
        'location': location,
        'expenseDate': expenseDate,
      },
    );

    await conn.close();
  }

  Future<List<ExpenseModel>> filterExpenses({
    required int userId,
    required String startDate,
    required String endDate,
    required String location,
  }) async {
    final conn = await DatabaseService.getConnection();

    final result = await conn.execute(
      '''
      SELECT * FROM expenses
      WHERE user_id = :userId
      AND expense_date BETWEEN :startDate AND :endDate
      AND location LIKE :location
      ORDER BY expense_date DESC
      ''',
      {
        'userId': userId,
        'startDate': startDate,
        'endDate': endDate,
        'location': '%$location%',
      },
    );

    await conn.close();

    return result.rows
        .map((row) => ExpenseModel.fromMap(row.assoc()))
        .toList();
  }
}