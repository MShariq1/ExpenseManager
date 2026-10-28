import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/expense_controller.dart';
import 'add_update_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ExpenseController expenseController = Get.put(ExpenseController());
  final AuthController authController = Get.find<AuthController>();
  final filterStartController = TextEditingController(text: '2026-09-01');
  final filterEndController = TextEditingController(text: '2026-09-30');

  @override
  void initState() {
    super.initState();
    expenseController.loadExpenses();
  }

  @override
  void dispose() {
    filterStartController.dispose();
    filterEndController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> pickFilterDate({
    required BuildContext context,
    required TextEditingController controller,
  }) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (mounted && selectedDate != null) {
      controller.text = formatDate(selectedDate);
    }
  }

  Widget buildFilterPickerField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: const Icon(Icons.keyboard_arrow_down),
        ),
      ),
    );
  }

  void openFilterDialog() {
    Get.defaultDialog(
      title: 'Filter Expenses',
      content: Builder(
        builder: (dialogContext) {
          return Column(
            children: [
              buildFilterPickerField(
                context: dialogContext,
                controller: filterStartController,
                label: 'Start Date',
                icon: Icons.calendar_month,
                onTap: () {
                  pickFilterDate(
                    context: dialogContext,
                    controller: filterStartController,
                  );
                },
              ),

              buildFilterPickerField(
                context: dialogContext,
                controller: filterEndController,
                label: 'End Date',
                icon: Icons.calendar_month,
                onTap: () {
                  pickFilterDate(
                    context: dialogContext,
                    controller: filterEndController,
                  );
                },
              ),
            ],
          );
        },
      ),
      textConfirm: 'Apply',
      textCancel: 'Cancel',
      onConfirm: () async {
        await expenseController.filterExpenses(
          startDate: filterStartController.text.trim(),
          endDate: filterEndController.text.trim(),
          location: '',
        );

        if (mounted) Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = authController.currentUser.value;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${user?.name ?? ''}'),
        actions: [
          IconButton(
            onPressed: openFilterDialog,
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: expenseController.loadExpenses,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: authController.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddUpdateExpenseScreen());
        },
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (expenseController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (expenseController.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(expenseController.error.value),
                TextButton(
                  onPressed: expenseController.loadExpenses,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (expenseController.expenses.isEmpty) {
          return const Center(child: Text('No expenses found'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: expenseController.expenses.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            final expense = expenseController.expenses[index];

            return InkWell(
              onTap: () {
                Get.to(() => AddUpdateExpenseScreen(expense: expense));
              },
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Amount: ${expense.amount}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Location: ${expense.location}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Date: ${expense.expenseDate}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Tap to update',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
