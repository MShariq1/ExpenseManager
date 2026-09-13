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

  factory ExpenseModel.fromMap(Map<String, String?> map) {
    return ExpenseModel(
      id: int.parse(map['id'] ?? '0'),
      userId: int.parse(map['user_id'] ?? '0'),
      title: map['title'] ?? '',
      amount: double.parse(map['amount'] ?? '0'),
      location: map['location'] ?? '',
      expenseDate: map['expense_date'] ?? '',
    );
  }
}