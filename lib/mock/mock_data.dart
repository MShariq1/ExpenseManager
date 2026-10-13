import '../models/expense_model.dart';
import '../models/user_model.dart';

// MOCK DATA VERSION
// Local in-memory data used while the real DB/API code is commented out.
// Data resets when the app restarts.
class MockData {


  static final List<Map<String, dynamic>> users = [
    {
      'id': 1,
      'name': 'Student One',
      'email': 'student@example.com',
      'password': '123456',
    },
    {
      'id': 2,
      'name': 'Demo User',
      'email': 'demo@example.com',
      'password': 'password',
    },
    {
      'id': 3,
      'name': 'Test User',
      'email': 'test@gmail.com',
      'password': '123456',
    },
  ];

  static final List<ExpenseModel> expenses = [
    ExpenseModel(
      id: 1,
      userId: 1,
      title: 'Lunch',
      amount: 450,
      location: 'Campus Cafe',
      expenseDate: '2026-09-05',
    ),
    ExpenseModel(
      id: 2,
      userId: 1,
      title: 'Books',
      amount: 1200,
      location: 'Book Store',
      expenseDate: '2026-09-12',
    ),
    ExpenseModel(
      id: 3,
      userId: 1,
      title: 'Bus Pass',
      amount: 300,
      location: 'Main Terminal',
      expenseDate: '2026-09-20',
    ),
    ExpenseModel(
      id: 4,
      userId: 2,
      title: 'Coffee',
      amount: 250,
      location: 'Demo Cafe',
      expenseDate: '2026-09-08',
    ),
    ExpenseModel(
      id: 5,
      userId: 3,
      title: 'Notebook',
      amount: 180,
      location: 'Stationery Shop',
      expenseDate: '2026-09-10',
    ),
    ExpenseModel(
      id: 6,
      userId: 3,
      title: 'Snacks',
      amount: 220,
      location: 'Campus Canteen',
      expenseDate: '2026-09-18',
    ),
  ];

  static int nextUserId() {
    if (users.isEmpty) return 1;

    return users
            .map((user) => user['id'] as int)
            .reduce((value, element) => value > element ? value : element) +
        1;
  }

  static int nextExpenseId() {
    if (expenses.isEmpty) return 1;

    return expenses
            .map((expense) => expense.id)
            .reduce((value, element) => value > element ? value : element) +
        1;
  }

  static UserModel userFromMockMap(Map<String, dynamic> user) {
    return UserModel(
      id: user['id'] as int,
      name: user['name'] as String,
      email: user['email'] as String,
    );
  }
}
