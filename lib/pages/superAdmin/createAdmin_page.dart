import 'package:flutter/material.dart';
import 'package:menuapp/components/my_button.dart';
import 'package:menuapp/components/my_drawer.dart';
import 'package:menuapp/components/my_textfield.dart';
import 'package:menuapp/pages/superAdmin/superAdmin_page.dart';
import 'package:menuapp/services/auth/auth_service.dart';

class CreateadminPage extends StatefulWidget {
  const CreateadminPage({super.key});

  @override
  State<CreateadminPage> createState() => _CreateadminPageState();
}

class _CreateadminPageState extends State<CreateadminPage> {
  String? selectedRestaurant;
  List<String> restaurants = [];
  final TextEditingController restaurantNameController =
      TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String errorMessage = '';
  @override
  void initState() {
    super.initState();
    _fetchRestaurants().then((_) {
      // After fetching restaurants
      if (restaurants.isNotEmpty) {
        setState(() {
          selectedRestaurant = restaurants[0]; // Set initial selected value
          restaurantNameController.text =
              selectedRestaurant ??
              ''; // Set the initial value of the controller
        });
      }
    }); // Fetch restaurants when the widget initializes
  }

  void register() async {
    // Get input values
    String username = usernameController.text;
    String password = passwordController.text;
    String restaurantName = restaurantNameController.text;
    String confirmPassword = confirmPasswordController.text;
    //String role = info["role"] as String;

    // Validate input fields
    if (username.isEmpty || password.isEmpty || restaurantName.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields';
      });
      return;
    } else if (confirmPassword != password) {
      setState(() {
        errorMessage = 'Password Not Matches';
      });
      return;
    }

    try {
      // Call your login service to authenticate the user
      var user = await AuthService().signUp(
        username,
        password,
        restaurantName,
        "admin",
      );

      // If login is successful, navigate to the home page
      if (user == "Success") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SuperadminPage()),
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

  Future<void> _fetchRestaurants() async {
    try {
      List<String> fetchedRestaurants = await AuthService().getRestaurants();
      setState(() {
        restaurants = fetchedRestaurants;
        if (restaurants.isNotEmpty) {
          selectedRestaurant = restaurants[0]; // Set initial value if available
        }
      });
    } catch (e) {
      print("Error fetching restaurants: $e");
      setState(() {
        errorMessage =
            "Error fetching restaurants: $e"; // Display error message
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Admin"),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              const SizedBox(height: 25),
              Text(
                "Create an Admin",
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
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: DropdownButtonFormField<String>(
                  value: selectedRestaurant,
                  onChanged: (newValue) {
                    setState(() {
                      selectedRestaurant = newValue;
                      restaurantNameController.text =
                          newValue ?? ''; // Update the controller
                    });
                  },
                  items:
                      restaurants.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    hintText: 'Select Category',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    labelText: 'Category',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  }, // Validation
                ),
              ),
              const SizedBox(height: 25),

              MyButton(onTap: register, text: "Create Admin"),
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
      ),
    );
  }
}
