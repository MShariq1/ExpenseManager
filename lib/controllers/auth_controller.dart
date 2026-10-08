import 'package:get/get.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';

class AuthController extends GetxController {
  final AuthRepository repo = AuthRepository();

  Rxn<UserModel> currentUser = Rxn<UserModel>();
  RxBool isLoading = false.obs;

  Future<void> login(String email, String password) async {
    isLoading.value = true;

    final user = await repo.login(email, password);

    isLoading.value = false;

    if (user != null) {
      currentUser.value = user;
      Get.offAll(() => const HomeScreen());
    } else {
      Get.snackbar('Error', 'Invalid email or password');
    }
  }

  Future<void> register(String name, String email, String password) async {
    isLoading.value = true;

    final registered = await repo.register(name, email, password);

    isLoading.value = false;

    if (registered) {
      Get.snackbar('Success', 'User registered successfully');
      Get.off(() => const LoginScreen());
    } else {
      Get.snackbar('Error', 'Email already exists');
    }
  }

  void logout() {
    currentUser.value = null;
    Get.offAll(() => const LoginScreen());
  }
}
