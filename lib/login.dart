import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uni_proj/forgot_password.dart';
import 'package:uni_proj/services/auth_service.dart';
import 'package:uni_proj/widgets/app_button.dart';
import 'package:uni_proj/widgets/app_textfield.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> items = ['One', 'Two', 'Three', 'Four'];
    final List<String> users = ['Ali', 'Ahmed', 'Sara', 'John'];

    return Scaffold(
      body: SafeArea(
        child:
            // ListView.builder(
            //   itemCount: users.length,
            //   itemBuilder: (context, index) {
            //     return ListTile(
            //       leading: const Icon(Icons.person),
            //       title: Text(users[index]),
            //     );
            //   },
            // ),
            // GridView.builder(
            //   itemCount: items.length,
            //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //     crossAxisCount: 2,
            //     crossAxisSpacing: 10,
            //     mainAxisSpacing: 10,
            //   ),
            //   itemBuilder: (context, index) {
            //     return Container(
            //       color: Colors.blue,
            //       child: Center(
            //         child: Text(
            //           items[index],
            //           style: const TextStyle(color: Colors.white),
            //         ),
            //       ),
            //     );
            //   },
            // )
            //         ListView(
            //   children: const [
            //     ListTile(
            //       leading: Icon(Icons.person),
            //       title: Text('User 1'),
            //       subtitle: Text('user1@gmail.com'),
            //     ),
            //     ListTile(
            //       leading: Icon(Icons.person),
            //       title: Text('User 2'),
            //       subtitle: Text('user2@gmail.com'),
            //     ),
            //   ],
            // )
            // GridView.count(
            //   crossAxisCount: 3,
            //   children: [
            //     Container(color: Colors.red),
            //     Container(color: Colors.blue),
            //     Container(color: Colors.green),
            //     Container(color: Colors.orange),
            //   ],
            // )
            
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Logo
                    // Image.asset(
                    //   'assets/images/logo.jpeg',
                    //   height: 100,
                    // ),
                    Image.network(
                      'https://thumbs.dreamstime.com/b/round-logo-sample-design-vector-illustration-white-background-148034726.jpg',
                      height: 100,
                      fit: BoxFit.fill,
                    ),

                    const SizedBox(height: 40),

                    AppTextField(
                      hintText: 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      controller: TextEditingController(),
                    ),

                    const SizedBox(height: 16),
                    AppTextField(
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      controller: TextEditingController(),
                    ),

                    const SizedBox(height: 16),

                    // Forgot button
                    Align(
                      alignment: .centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPassword(),
                            ),
                          );
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => const ForgotPassword(),
                          //   ),
                          // );
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    AppButton(
                      title: 'Login',
                      // backgroundColor: Colors.red,
                      textColor: Colors.white,
                      borderRadius: 20,
                      onPressed: () async {
                        final user = await AuthService().login(
                          email: 'ali@test.com',
                          password: '123456',
                        );

                        if (user != null) {
                          debugPrint('Login success: ${user.name}');
                        } else {
                          debugPrint('Invalid email or password');
                        }
                      },
                    ),

                    // const Spacer(),

                    // Register text at bottom
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        SizedBox(width: 40),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Register'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
