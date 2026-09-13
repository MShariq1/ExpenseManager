import 'package:get/get.dart';
import '../models/expense_model.dart';
import '../repositories/expense_repository.dart';
import 'auth_controller.dart';

class ExpenseController extends GetxController {
  final ExpenseRepository repo = ExpenseRepository();
  final AuthController authController = Get.find<AuthController>();

  RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;
  RxBool isLoading = false.obs;

  Future<void> loadExpenses() async {
    final user = authController.currentUser.value;
    if (user == null) return;

    isLoading.value = true;
    expenses.value = await repo.getExpenses(user.id);
    isLoading.value = false;
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required String location,
    required String expenseDate,
  }) async {
    final user = authController.currentUser.value;
    if (user == null) return;

    await repo.addExpense(
      userId: user.id,
      title: title,
      amount: amount,
      location: location,
      expenseDate: expenseDate,
    );

    await loadExpenses();
  }

  Future<void> updateExpense({
    required int id,
    required String title,
    required double amount,
    required String location,
    required String expenseDate,
  }) async {
    await repo.updateExpense(
      id: id,
      title: title,
      amount: amount,
      location: location,
      expenseDate: expenseDate,
    );

    await loadExpenses();
  }

  Future<void> filterExpenses({
    required String startDate,
    required String endDate,
    required String location,
  }) async {
    final user = authController.currentUser.value;
    if (user == null) return;

    isLoading.value = true;

    expenses.value = await repo.filterExpenses(
      userId: user.id,
      startDate: startDate,
      endDate: endDate,
      location: location,
    );

    isLoading.value = false;
  }
}