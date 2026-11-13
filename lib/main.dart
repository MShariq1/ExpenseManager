import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:uni_proj/controllers/auth_controller.dart';
import 'package:uni_proj/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp();

  debugPrint('Background message: ${message.messageId}');
}

void handleNotificationTap(RemoteMessage message) {
  debugPrint('Notification tapped: ${message.data}');

  // Add navigation here when your destination screens are ready.
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Reads the Android configuration generated from google-services.json.
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  FirebaseMessaging.onMessage.listen((message) {
    debugPrint('Foreground title: ${message.notification?.title}');
    debugPrint('Foreground body: ${message.notification?.body}');
    debugPrint('Foreground data: ${message.data}');
  });

  FirebaseMessaging.onMessageOpenedApp.listen(handleNotificationTap);

  Get.put(AuthController());
  runApp(const MyApp());

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Permission: ${settings.authorizationStatus}');

    final token = await messaging.getToken();
    debugPrint('FCM TOKEN: $token');

    messaging.onTokenRefresh.listen((newToken) {
      debugPrint('NEW FCM TOKEN: $newToken');

      // Later: update this device's token on your backend.
    });

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      handleNotificationTap(initialMessage);
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [const Text('Hello World'), const Text('second text')],
            ),
            // Text('Login', style: Theme.of(context).textTheme.headlineLarge),
            // Text(
            //   'Enter your email and password',
            //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
            // ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.access_alarm),
      ),
    );
  }
}

// ThemeData = full app styling
// ColorScheme = app color palette
// fromSeed = generate full palette from one color
// seedColor = your main brand color
