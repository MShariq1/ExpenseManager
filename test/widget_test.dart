import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:uni_proj/controllers/auth_controller.dart';
import 'package:uni_proj/main.dart';

void main() {
  tearDown(() => Get.reset());
  testWidgets('login validates fields and opens registration', (tester) async {
    Get.put(AuthController());
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();
    expect(find.text('Please enter email'), findsOneWidget);
    expect(find.text('Please enter password'), findsOneWidget);
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();
    expect(find.text('Register'), findsWidgets);
  });
}
