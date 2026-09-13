import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/expense_controller.dart';
import '../models/expense_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_textfield.dart';
import 'places_screen.dart';

class AddUpdateExpenseScreen extends StatefulWidget {
  final ExpenseModel? expense;

  const AddUpdateExpenseScreen({
    super.key,
    this.expense,
  });

  @override
  State<AddUpdateExpenseScreen> createState() => _AddUpdateExpenseScreenState();
}

class _AddUpdateExpenseScreenState extends State<AddUpdateExpenseScreen> {
  final ExpenseController expenseController = Get.find<ExpenseController>();

  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final locationController = TextEditingController();
  final dateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final expense = widget.expense;

    if (expense != null) {
      titleController.text = expense.title;
      amountController.text = expense.amount.toString();
      locationController.text = expense.location;
      dateController.text = expense.expenseDate;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    locationController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(dateController.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (selectedDate != null) {
      dateController.text =
          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> pickLocation() async {
    final selectedPlace = await Get.to<String>(() => const PlacesScreen());

    if (selectedPlace != null && selectedPlace.isNotEmpty) {
      locationController.text = selectedPlace;
    }
  }

  Future<void> saveExpense() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final expense = widget.expense;

    if (expense == null) {
      await expenseController.addExpense(
        title: titleController.text.trim(),
        amount: double.parse(amountController.text.trim()),
        location: locationController.text.trim(),
        expenseDate: dateController.text.trim(),
      );
    } else {
      await expenseController.updateExpense(
        id: expense.id,
        title: titleController.text.trim(),
        amount: double.parse(amountController.text.trim()),
        location: locationController.text.trim(),
        expenseDate: dateController.text.trim(),
      );
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.expense != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdate ? 'Update Expense' : 'Add Expense'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: titleController,
                  hintText: 'Title',
                  prefixIcon: Icons.title,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter title';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: amountController,
                  hintText: 'Amount',
                  prefixIcon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter amount';
                    }

                    if (double.tryParse(value.trim()) == null) {
                      return 'Please enter valid amount';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                GestureDetector(
                  onTap: pickLocation,
                  child: AbsorbPointer(
                    child: AppTextField(
                      controller: locationController,
                      hintText: 'Location',
                      prefixIcon: Icons.location_on_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please select location';
                        }
                        return null;
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                GestureDetector(
                  onTap: pickDate,
                  child: AbsorbPointer(
                    child: AppTextField(
                      controller: dateController,
                      hintText: 'Expense Date',
                      prefixIcon: Icons.calendar_month,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please select date';
                        }
                        return null;
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                AppButton(
                  title: isUpdate ? 'Update Expense' : 'Add Expense',
                  backgroundColor: Colors.blue,
                  textColor: Colors.white,
                  borderRadius: 20,
                  onPressed: saveExpense,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}