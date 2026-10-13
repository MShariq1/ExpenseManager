import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../widgets/app_button.dart';
import '../widgets/app_textfield.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController auth = Get.find<AuthController>();

  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void loginUser() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    auth.login(emailController.text.trim(), passwordController.text.trim());
  }

  void user(String name) {
    print('User name is $name');
  }

  void addNumbers(int a, int b) {
    print(a + b);
  }

  int square(int number) {
    return number * number;
  }

  void ifCondition(int marks) {

    if (marks >= 50) {
      print('Pass');
    } else {
      print('Fail');
    }
  }

  void multipleIfConditions() {
    int marks = 65;

    if (marks >= 90) {
      print('Grade A+');
    } else if (marks >= 80) {
      print('Grade A');
    } else if (marks >= 70) {
      print('Grade B');
    } else {
      print('Fail');
    }


    if (marks >= 90) {
      print('Grade A+');
    }

    if (marks >= 80) {
      print('Grade A');
    }
  }

  void nestedIfConditions() {
    int age = 20;
    bool hasCNIC = true;

    if (age >= 18) {
      if (hasCNIC) {
        print('You can vote');
      } else {
        print('CNIC required');
      }
    } else {
      print('You are under age');
    }

    if (age >= 18 && hasCNIC) {
      print('You can vote');
    }

    if (age >= 18 || hasCNIC) {
      print('You can vote');
    }
  }

  void Loop() {
    for (int i = 0; i <= 5; i++) {
      print(i);
    }
  }

  void LoopByList() {
    List<String> names = ['Ali', 'Ahmed', 'Salman'];

    for (int i = 1; i <= names.length; i++) {
      print(names[i]);
    }
  }

  void whileLoop() {
    int i = 1;

    while (i <= 5) {
      print(i);
      i++;
    }
  }

  void doWhileLoop() {
    int i = 1;

    do {
      print(i);
      i++;
    } while (i <= 5);
  }

  void findLargestNumber() {
    List<int> numbers = [10, 5, 30, 2, 50];

    int largest = numbers[0];

    for (int i = 1; i < numbers.length; i++) {
      if (numbers[i] > largest) {
        largest = numbers[i];
      }
    }

    print('Largest number is $largest');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: emailController,
                  hintText: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter email';
                    }

                    if (!GetUtils.isEmail(value.trim())) {
                      return 'Please enter valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 40),

                AppTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter password';
                    }

                    if (value.trim().length < 6) {
                      return 'Password must be at least 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 100),

                Obx(() {
                  return AppButton(
                    title: 'Login',
                    backgroundColor: Colors.blue,
                    textColor: Colors.white,
                    borderRadius: 20,
                    isLoading: auth.isLoading.value,
                    onPressed: loginUser,
                  );
                }),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {
                    // Get.to(() => const RegisterScreen());
                    ifCondition(52);
                  },
                  child: const Text('Create Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
