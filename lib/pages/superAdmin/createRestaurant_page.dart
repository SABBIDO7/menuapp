import 'package:flutter/material.dart';
import 'package:menuapp/components/my_button.dart';
import 'package:menuapp/components/my_drawer.dart';
import 'package:menuapp/components/my_textfield.dart';
import 'package:menuapp/pages/superAdmin/superAdmin_page.dart';
import 'package:menuapp/services/auth/auth_service.dart';

class CreaterestaurantPage extends StatefulWidget {
  const CreaterestaurantPage({super.key});

  @override
  State<CreaterestaurantPage> createState() => _CreaterestaurantPageState();
}

class _CreaterestaurantPageState extends State<CreaterestaurantPage> {
  final TextEditingController restaurantNameController =
      TextEditingController();
  String errorMessage = '';
  void createRestaurant() async {
    String restaurantName =
        restaurantNameController.text.trim(); // Remove whitespace

    if (restaurantName.isEmpty) {
      setState(() {
        errorMessage = "Restaurant name cannot be empty.";
      });
      return;
    }

    String result = await AuthService().createRestaurant(restaurantName);

    if (result == "Success") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SuperadminPage()),
      );
    } else {
      setState(() {
        errorMessage = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create a Restaurant"),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
      drawer: MyDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            const SizedBox(height: 25),
            Text(
              "Create a Restaurant",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            const SizedBox(height: 25),

            MyTextfield(
              controller: restaurantNameController,
              hintText: "Restaurant Name",
              obscureText: false,
            ),

            const SizedBox(height: 25),

            MyButton(onTap: createRestaurant, text: "Create Restaurant"),
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
          ],
        ),
      ),
    );
  }
}
