import 'package:flutter/material.dart';
import 'package:menuapp/components/my_button.dart';
import 'package:menuapp/components/my_drawer.dart';
import 'package:menuapp/components/my_textfield.dart';
import 'package:menuapp/pages/admin/admin_page.dart';
import 'package:menuapp/services/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatecategoriesPage extends StatefulWidget {
  const CreatecategoriesPage({super.key});

  @override
  State<CreatecategoriesPage> createState() => _CreatecategoriesPageState();
}

class _CreatecategoriesPageState extends State<CreatecategoriesPage> {
  String errorMessage = "";
  final TextEditingController categoryNameController = TextEditingController();
  Future<String> getRestaurantName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('restaurantName') ?? "None";
  }

  void createCategory() async {
    // Get input values

    String info = await getRestaurantName();
    String restaurantName = info;
    String category = categoryNameController.text;
    // Validate input fields
    if (category.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields';
      });
      return;
    }

    try {
      // Call your login service to authenticate the user
      var categoryRequest = await AuthService().createCategory(
        category,
        restaurantName,
      );

      // If login is successful, navigate to the home page
      if (categoryRequest == "Success") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPage()),
        );
      } else {
        setState(() {
          errorMessage = categoryRequest;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Category"),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
      drawer: MyDrawer(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            const SizedBox(height: 25),
            Text(
              "Create A Category",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            const SizedBox(height: 25),
            MyTextfield(
              controller: categoryNameController,
              hintText: "Category name",
              obscureText: false,
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
            MyButton(onTap: createCategory, text: "Create Category"),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
