import 'package:flutter/material.dart';
import 'package:menuapp/components/my_button.dart';
import 'package:menuapp/components/my_textfield.dart';
import 'package:menuapp/pages/admin/admin_page.dart';
import 'package:menuapp/pages/home_page.dart';
import 'package:menuapp/services/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  //final void Function()? onTap;
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController restaurantNameController =
      TextEditingController();
  String errorMessage = '';
  void login() async {
    // Get input values
    String username = usernameController.text;
    String password = passwordController.text;
    String restaurantName = restaurantNameController.text;

    // Validate input fields
    if (username.isEmpty || password.isEmpty || restaurantName.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields';
      });
      return;
    }

    try {
      // Call your login service to authenticate the user
      var user = await AuthService().logIn(username, password, restaurantName);

      // If login is successful, navigate to the home page
      if (user['role'] == "user") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else if (user['role'] == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPage()),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Incorrect username, password, or restaurant name';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_open_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            const SizedBox(height: 25),
            Text(
              "Food Order App",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            const SizedBox(height: 25),
            MyTextfield(
              controller: restaurantNameController,
              hintText: "Restaurant name",
              obscureText: false,
            ),
            const SizedBox(height: 10),
            MyTextfield(
              controller: usernameController,
              hintText: "Username",
              obscureText: false,
            ),
            const SizedBox(height: 10),

            MyTextfield(
              controller: passwordController,
              hintText: "Password",
              obscureText: true,
            ),
            const SizedBox(height: 25),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            MyButton(onTap: login, text: "Log In"),
            const SizedBox(height: 10),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Text(
            //       "Not a Member?",
            //       style: TextStyle(
            //         color: Theme.of(context).colorScheme.inversePrimary,
            //       ),
            //     ),
            //     SizedBox(width: 4),
            //     GestureDetector(
            //       onTap: widget.onTap,
            //       child: Text(
            //         "Register Now",
            //         style: TextStyle(
            //           color: Theme.of(context).colorScheme.inversePrimary,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
