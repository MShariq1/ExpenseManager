import '../network/api_client.dart';

class ExpenseModel {
  final int id;
  final int userId;
  final String title;
  final double amount;
  final String location;
  final String expenseDate;

  ExpenseModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.location,
    required this.expenseDate,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    final id = int.tryParse('${map['id']}');
    final userId = int.tryParse('${map['user_id']}');
    final amount = double.tryParse('${map['amount']}');
    final date = map['expense_date'];
    if (id == null ||
        id <= 0 ||
        userId == null ||
        userId <= 0 ||
        amount == null ||
        !amount.isFinite ||
        map['title'] is! String ||
        (map['location'] != null && map['location'] is! String) ||
        date is! String ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date) ||
        DateTime.tryParse(date)?.toIso8601String().substring(0, 10) != date) {
      throw const ApiException('Invalid expense response.');
    }
    return ExpenseModel(
      id: id,
      userId: userId,
      title: map['title'],
      amount: amount,
      location: map['location'] ?? '',
      expenseDate: date,
    );
  }
}
