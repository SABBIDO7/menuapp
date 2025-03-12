import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menuapp/components/my_button.dart';
import 'package:menuapp/components/my_drawer.dart';
import 'package:menuapp/components/my_textfield.dart';
import 'package:menuapp/pages/admin/admin_page.dart';
import 'package:menuapp/services/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateitemPage extends StatefulWidget {
  const CreateitemPage({super.key});

  @override
  State<CreateitemPage> createState() => _CreateitemPageState();
}

class _CreateitemPageState extends State<CreateitemPage> {
  String errorMessage = "";
  String? selectedCategory;
  List<String> categories = [];
  final ImagePicker _picker = ImagePicker();
  XFile? imageFile;
  final TextEditingController categoryNameController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  List<Map<String, dynamic>> addonsList = []; // Store addons as a List<Map>
  List<TextEditingController> addonNameControllers = [];
  List<TextEditingController> addonPriceControllers = [];
  List<bool> addonChecked = [];
  Future<String> getRestaurantName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('restaurantName') ?? "None";
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories().then((_) {
      // After fetching restaurants
      if (categories.isNotEmpty) {
        setState(() {
          selectedCategory = categories[0]; // Set initial selected value
          categoryNameController.text =
              selectedCategory ?? ''; // Set the initial value of the controller
        });
      }
    }); // Fetch categories when the widget initializes
  }

  Future<void> _fetchCategories() async {
    // 1. Replace with your actual function call
    List<String> fetchedCategories = await AuthService().getCategories(
      await getRestaurantName(),
    );

    setState(() {
      categories = fetchedCategories;
      if (categories.isNotEmpty) {
        selectedCategory = categories[0]; // Select the first category initially
      }
    });
  }

  void createItem() async {
    // Get input values

    String info = await getRestaurantName();
    String restaurantName = info;
    // Validate input fields
    if (itemNameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        priceController.text.isEmpty ||
        categoryNameController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields';
      });
      return;
    }
    List<Map<String, dynamic>> selectedAddons = [];
    for (int i = 0; i < addonsList.length; i++) {
      if (addonChecked[i]) {
        selectedAddons.add({
          'name': addonNameControllers[i].text,
          'price': double.tryParse(addonPriceControllers[i].text) ?? 0.0,
        });
      }
    }

    try {
      double price = double.parse(priceController.text);

      // Call your login service to authenticate the user
      var itemRequest = await AuthService().createItem(
        itemNameController.text,
        descriptionController.text,
        price,
        selectedAddons, //  List<Map<String, dynamic>> addonsList
        categoryNameController.text,
        restaurantName,
        imageFile,
      );

      // If login is successful, navigate to the home page
      if (itemRequest == "Success") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPage()),
        );
      } else {
        setState(() {
          errorMessage = itemRequest;
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
        title: Text("Create Item"),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
      drawer: MyDrawer(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.food_bank,
                size: 80,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              const SizedBox(height: 25),
              Text(
                "Create An Item",
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              const SizedBox(height: 25),
              MyTextfield(
                controller: itemNameController,
                hintText: "Item name",
                obscureText: false,
              ),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: DropdownButtonFormField<String>(
                  value: selectedCategory,
                  onChanged: (newValue) {
                    setState(() {
                      selectedCategory = newValue;
                      categoryNameController.text =
                          newValue ?? ''; // Update the controller
                    });
                  },
                  items:
                      categories.map((category) {
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
              const SizedBox(height: 10),
              MyTextfield(
                controller: priceController,
                hintText: "Price",
                obscureText: false,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),

                child: TextFormField(
                  // Use TextFormField for multi-line input
                  controller: descriptionController,
                  maxLines: 4, // Allows multiple lines of text
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
                    hintText: "description",
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              _buildAddonsSection(), // Call the new function

              const SizedBox(height: 10),
              // Image Picker with Checkmark
              _buildImagePicker(),

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
              MyButton(onTap: createItem, text: "Create Item"),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // Add-on List Builder
  Widget _buildAddonsSection() {
    return Column(
      children: [
        ElevatedButton(
          // "Add Add-on" Button
          onPressed: () {
            setState(() {
              addonNameControllers.add(TextEditingController());
              addonPriceControllers.add(TextEditingController());
              addonChecked.add(false);
              addonsList.add({'name': '', 'price': 0.0});
            });
          },
          child: const Text("Add Add-on"),
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true, // Important for ListView inside Column
          physics: NeverScrollableScrollPhysics(), // Prevent inner scrolling
          itemCount: addonsList.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Row(
                children: [
                  Expanded(
                    // Takes available space
                    child: MyTextfield(
                      controller: addonNameControllers[index],
                      hintText: "Add-on Name",
                      obscureText: false,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    // Takes available space
                    child: MyTextfield(
                      controller: addonPriceControllers[index],
                      hintText: "Price",
                      obscureText: false,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              leading: Checkbox(
                value: addonChecked[index],
                onChanged: (value) {
                  setState(() {
                    addonChecked[index] = value!;
                  });
                },
              ),
            );
          },
        ),
      ],
    );
  }

  // Improved Image Picker with Check
  Widget _buildImagePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Center the row
      children: [
        MyButton(
          text: "Choose Image",
          onTap: () async {
            imageFile = await _picker.pickImage(source: ImageSource.gallery);
            setState(() {});
          },
        ),
        if (imageFile != null) // Display checkmark if image selected
          Icon(Icons.check, color: Colors.green),
      ],
    );
  }
}
