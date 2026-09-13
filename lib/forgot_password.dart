import 'package:flutter/material.dart';
import 'package:uni_proj/widgets/app_button.dart';
import 'package:uni_proj/widgets/app_textfield.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Enter your email address and we will send you a reset link.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 32),

              AppTextField(
                hintText: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                controller: TextEditingController(),
              ),

              const SizedBox(height: 24),

              AppButton(
                title: 'Send Reset Link',
                backgroundColor: Colors.blue,
                textColor: Colors.white,
                borderRadius: 20,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reset link sent successfully'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}