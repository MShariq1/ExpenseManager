// REAL DB CODE COMMENTED FOR NOW
// import '../db/database_service.dart';
import '../mock/mock_data.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  Future<List<ExpenseModel>> getExpenses(int userId) async {
    // MOCK DATA VERSION
    final userExpenses = MockData.expenses
        .where((expense) => expense.userId == userId)
        .toList();

    userExpenses.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));

    return userExpenses;

    // REAL DB CODE COMMENTED FOR NOW
    // final conn = await DatabaseService.getConnection();
    //
    // final result = await conn.execute(
    //   '''
    //   SELECT * FROM expenses
    //   WHERE user_id = :userId
    //   ORDER BY expense_date DESC
    //   ''',
    //   {'userId': userId},
    // );
    //
    // await conn.close();
    //
    // return result.rows
    //     .map((row) => ExpenseModel.fromMap(row.assoc()))
    //     .toList();
  }

  Future<void> addExpense({
    required int userId,
    required String title,
    required double amount,
    required String location,
    required String expenseDate,
  }) async {
    // MOCK DATA VERSION
    MockData.expenses.add(
      ExpenseModel(
        id: MockData.nextExpenseId(),
        userId: userId,
        title: title,
        amount: amount,
        location: location,
        expenseDate: expenseDate,
      ),
    );

    // REAL DB CODE COMMENTED FOR NOW
    // final conn = await DatabaseService.getConnection();
    //
    // await conn.execute(
    //   '''
    //   INSERT INTO expenses(user_id, title, amount, location, expense_date)
    //   VALUES(:userId, :title, :amount, :location, :expenseDate)
    //   ''',
    //   {
    //     'userId': userId,
    //     'title': title,
    //     'amount': amount,
    //     'location': location,
    //     'expenseDate': expenseDate,
    //   },
    // );
    //
    // await conn.close();
  }

  Future<void> updateExpense({
    required int id,
    required String title,
    required double amount,
    required String location,
    required String expenseDate,
  }) async {
    // MOCK DATA VERSION
    final index = MockData.expenses.indexWhere((expense) => expense.id == id);

    if (index == -1) return;

    final oldExpense = MockData.expenses[index];
    MockData.expenses[index] = ExpenseModel(
      id: oldExpense.id,
      userId: oldExpense.userId,
      title: title,
      amount: amount,
      location: location,
      expenseDate: expenseDate,
    );

    // REAL DB CODE COMMENTED FOR NOW
    // final conn = await DatabaseService.getConnection();
    //
    // await conn.execute(
    //   '''
    //   UPDATE expenses
    //   SET title = :title,
    //       amount = :amount,
    //       location = :location,
    //       expense_date = :expenseDate
    //   WHERE id = :id
    //   ''',
    //   {
    //     'id': id,
    //     'title': title,
    //     'amount': amount,
    //     'location': location,
    //     'expenseDate': expenseDate,
    //   },
    // );
    //
    // await conn.close();
  }

  Future<void> deleteExpense(int id) async {
    // MOCK DATA VERSION
    MockData.expenses.removeWhere((expense) => expense.id == id);

    // REAL DB CODE COMMENTED FOR NOW
    // final conn = await DatabaseService.getConnection();
    //
    // await conn.execute(
    //   '''
    //   DELETE FROM expenses
    //   WHERE id = :id
    //   ''',
    //   {'id': id},
    // );
    //
    // await conn.close();
  }

  Future<List<ExpenseModel>> filterExpenses({
    required int userId,
    required String startDate,
    required String endDate,
    required String location,
  }) async {
    // MOCK DATA VERSION
    final filteredExpenses = MockData.expenses.where((expense) {
      final matchesUser = expense.userId == userId;
      final matchesDate =
          expense.expenseDate.compareTo(startDate) >= 0 &&
          expense.expenseDate.compareTo(endDate) <= 0;
      final matchesLocation =
          location.isEmpty ||
          expense.location.toLowerCase().contains(location.toLowerCase());

      return matchesUser && matchesDate && matchesLocation;
    }).toList();

    filteredExpenses.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));

    return filteredExpenses;

    // REAL DB CODE COMMENTED FOR NOW
    // final conn = await DatabaseService.getConnection();
    //
    // final result = await conn.execute(
    //   '''
    //   SELECT * FROM expenses
    //   WHERE user_id = :userId
    //   AND expense_date BETWEEN :startDate AND :endDate
    //   AND location LIKE :location
    //   ORDER BY expense_date DESC
    //   ''',
    //   {
    //     'userId': userId,
    //     'startDate': startDate,
    //     'endDate': endDate,
    //     'location': '%$location%',
    //   },
    // );
    //
    // await conn.close();
    //
    // return result.rows
    //     .map((row) => ExpenseModel.fromMap(row.assoc()))
    //     .toList();
  }
}
