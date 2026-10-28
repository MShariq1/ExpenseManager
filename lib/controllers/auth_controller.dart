import 'package:get/get.dart';
import '../models/user_model.dart';
import '../network/api_client.dart';
import '../repositories/auth_repository.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import 'expense_controller.dart';

class AuthController extends GetxController {
  final ApiClient api;
  late final AuthRepository repo = AuthRepository(api);
  AuthController({ApiClient? api}) : api = api ?? ApiClient();
  final currentUser = Rxn<UserModel>();
  final isLoading = false.obs;

  Future<void> login(String email, String password) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final user = await repo.login(email, password);
      if (isClosed) return;
      currentUser.value = user;
      Get.offAll(() => const HomeScreen());
    } catch (error) {
      if (!isClosed) Get.snackbar('Login failed', _message(error));
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  Future<void> register(String name, String email, String password) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      await repo.register(name, email, password);
      if (isClosed) return;
      Get.off(() => const LoginScreen());
      Get.snackbar('Success', 'Registered. Sign in with your new account.');
    } catch (error) {
      if (!isClosed) Get.snackbar('Registration failed', _message(error));
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  String _message(Object error) => error is ApiException
      ? error.message
      : 'Unexpected response. Please try again.';
  void logout() {
    currentUser.value = null;
    if (Get.isRegistered<ExpenseController>()) {
      Get.find<ExpenseController>().clear();
      Get.delete<ExpenseController>();
    }
    Get.offAll(() => const LoginScreen());
  }

  @override
  void onClose() {
    api.close();
    super.onClose();
  }
}
