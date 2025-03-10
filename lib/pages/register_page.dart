import 'package:flutter/material.dart';
import 'package:menuapp/components/my_button.dart';
import 'package:menuapp/components/my_textfield.dart';
import 'package:menuapp/pages/admin/admin_page.dart';
import 'package:menuapp/services/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  //final void Function()? onTap;
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController restaurantNameController =
      TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String errorMessage = '';
  Future<Map<String, String>> userRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      "restaurantName": prefs.getString('restaurantName') ?? "empty",
      "role": prefs.getString('role') ?? "user",
    };
  }

  void register() async {
    // Get input values
    String username = usernameController.text;
    String password = passwordController.text;
    Map<String, String> info = await userRole();
    String restaurantName = info["restaurantName"] as String;
    //String role = info["role"] as String;

    // Validate input fields
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields';
      });
      return;
    }

    try {
      // Call your login service to authenticate the user
      var user = await AuthService().signUp(
        username,
        password,
        restaurantName,
        "user",
      );

      // If login is successful, navigate to the home page
      if (user == "Success") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPage()),
        );
      } else {
        setState(() {
          errorMessage = user;
        });
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
              "Create a User",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            const SizedBox(height: 25),

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
            const SizedBox(height: 10),

            MyTextfield(
              controller: confirmPasswordController,
              hintText: "Confirm password",
              obscureText: true,
            ),
            const SizedBox(height: 25),

            MyButton(onTap: register, text: "Register"),
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
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Text(
            //       "Already have an account?",
            //       style: TextStyle(
            //         color: Theme.of(context).colorScheme.inversePrimary,
            //       ),
            //     ),
            //     SizedBox(width: 4),
            //     GestureDetector(
            //       onTap: widget.onTap,
            //       child: Text(
            //         "Login now",
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
