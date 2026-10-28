import '../models/expense_model.dart';
import '../network/api_client.dart';

class ExpenseRepository {
  final ApiClient api;
  ExpenseRepository(this.api);
  Future<List<ExpenseModel>> getExpenses(int userId) async {
    final data = await api.request(
      'GET',
      'expenses',
      query: {'userId': '$userId'},
    );
    if (data is! List) throw const ApiException('Expected an expense list.');
    return data.map((item) => ExpenseModel.fromMap(objectData(item))).toList();
  }

  Future<void> save({
    int? id,
    required int userId,
    required String title,
    required double amount,
    required String location,
    required String expenseDate,
  }) async {
    final data = objectData(
      await api.request(
        id == null ? 'POST' : 'PUT',
        id == null ? 'expenses' : 'expenses/$id',
        body: {
          'userId': userId,
          'title': title,
          'amount': amount,
          'location': location.isEmpty ? null : location,
          'expenseDate': expenseDate,
        },
      ),
    );
    if (data['id'] is! num) {
      throw const ApiException(
        'Save response is missing the expense ID. Refresh before retrying.',
      );
    }
  }
}
