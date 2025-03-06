import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:menuapp/pages/home_page.dart';
import 'package:menuapp/services/auth/login_or_register.dart';
import 'package:menuapp/firebase_options.dart';
import 'package:menuapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Firebase initialization failed: $e");
  }
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          ); // Show loading indicator while checking session
        } else {
          bool isLoggedIn = snapshot.data ?? false;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: isLoggedIn ? const HomePage() : LoginOrRegister(),
            theme: Provider.of<ThemeProvider>(context).themeData,
          );
        }
      },
    );
  }
}
