import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uni_proj/forgot_password.dart';
import 'package:uni_proj/screens/register_screen.dart';
import 'package:uni_proj/services/auth_service.dart';
import 'package:uni_proj/widgets/app_button.dart';
import 'package:uni_proj/widgets/app_textfield.dart';


class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> items = ['One', 'Two', 'Three', 'Four', 'One', 'Two', 'Three', 'Four'];
    final List<String> users = ['Ali', 'Ahmed', 'Sara', 'John', 'Ali', 'Ahmed', 'Sara', 'John'];
    final firstNameController = TextEditingController();

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
            //     crossAxisSpacing: 50,
            //     mainAxisSpacing: 100,
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
            //   ],
            // )
            // GridView.count(
            //   crossAxisCount: 1,
            //   children: [
            //     Container(color: Colors.red),
            //     Container(color: Colors.blue),
            //     Container(color: Colors.green),
            //     Container(color: Colors.orange),
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
                    const SizedBox(height: 50),

                    // Logo
                    // Image.asset(
                    //   'assets/images/delete_warning_icon.png',
                    //   height: 100,
                    // ),
                    Image.network(
                      "https://thumbs.dreamstime.com/b/golden-bird-expansive-wings-takes-flight-against-vibrant-blue-sky-scene-evokes-sense-freedom-wonder-sample-jpeg-364733156.jpg",
                      height: 100,
                      fit: BoxFit.fill,
                    ),

                    const SizedBox(height: 31),

                    AppTextField(
                      controller: firstNameController,
                      hintText: "First Name",
                      prefixIcon: Icons.person_outline,
                      obscureText: true,
                    ),

SizedBox(height: 20,),
                    AppTextField(
                      hintText: 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.number,
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
                      title: "Abdur Rehman",
                      backgroundColor: Colors.green,
                      textColor: Colors.black,
                      borderRadius: 20,
                      onPressed: () {
                        print("Abdur Rehman");
                      },
                    
                    ),

                    AppButton(
                      title: 'Login',
                      // backgroundColor: Colors.red,
                      textColor: Colors.white,
                      borderRadius: 20,
                      onPressed: () async {
                        // final user = await AuthService().login(
                        //   email: 'ali@test.com',
                        //   password: '123456',
                        // );

                        // if (user != null) {
                        //   debugPrint('Login success: ${user.name}');
                        // } else {
                        //   debugPrint('Invalid email or password');
                        // }
                      },
                    ),

                    // const Spacer(),

                    // Register text at bottom
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
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
