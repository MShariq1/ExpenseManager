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
                    Get.to(() => const RegisterScreen());
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
