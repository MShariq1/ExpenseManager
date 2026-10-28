import 'package:get/get.dart';
import '../models/expense_model.dart';
import '../network/api_client.dart';
import '../repositories/expense_repository.dart';
import 'auth_controller.dart';

class ExpenseController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  late final ExpenseRepository repo = ExpenseRepository(authController.api);
  final expenses = <ExpenseModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final error = ''.obs;
  int _generation = 0;
  void clear() {
    _generation++;
    expenses.clear();
    error.value = '';
    isLoading.value = false;
  }

  Future<void> loadExpenses() async {
    final user = authController.currentUser.value;
    if (user == null) return;
    final generation = ++_generation;
    isLoading.value = true;
    error.value = '';
    try {
      final result = await repo.getExpenses(user.id);
      if (!isClosed && generation == _generation) expenses.assignAll(result);
    } catch (e) {
      if (!isClosed && generation == _generation) error.value = _message(e);
    } finally {
      if (!isClosed && generation == _generation) isLoading.value = false;
    }
  }

  String _message(Object e) =>
      e is ApiException ? e.message : 'Unexpected response. Please try again.';
  Future<bool> saveExpense({
    int? id,
    required String title,
    required double amount,
    required String location,
    required String expenseDate,
  }) async {
    final user = authController.currentUser.value;
    if (user == null || isSaving.value) return false;
    isSaving.value = true;
    try {
      await repo.save(
        id: id,
        userId: user.id,
        title: title,
        amount: amount,
        location: location,
        expenseDate: expenseDate,
      );
      if (isClosed || authController.currentUser.value != user) return false;
      await loadExpenses();
      return true;
    } catch (e) {
      if (!isClosed) Get.snackbar('Save failed', _message(e));
      return false;
    } finally {
      if (!isClosed) isSaving.value = false;
    }
  }

  Future<void> filterExpenses({
    required String startDate,
    required String endDate,
    required String location,
  }) async {
    if (startDate.compareTo(endDate) > 0) {
      Get.snackbar('Invalid dates', 'Start date must be before end date.');
      return;
    }
    await loadExpenses();
    if (isClosed || error.value.isNotEmpty) return;
    expenses.assignAll(
      expenses
          .where(
            (e) =>
                e.expenseDate.compareTo(startDate) >= 0 &&
                e.expenseDate.compareTo(endDate) <= 0 &&
                e.location.toLowerCase().contains(location.toLowerCase()),
          )
          .toList(),
    );
  }
}
