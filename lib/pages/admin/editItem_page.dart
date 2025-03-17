import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menuapp/components/my_button.dart';
import 'package:menuapp/components/my_drawer.dart';
import 'package:menuapp/components/my_textfield.dart';
import 'package:menuapp/models/food.dart';
import 'package:menuapp/pages/admin/admin_page.dart';
import 'package:menuapp/services/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class EditItemPage extends StatefulWidget {
  final String foodName;

  const EditItemPage({Key? key, required this.foodName}) : super(key: key);

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  String errorMessage = "";
  String? selectedCategory;
  List<String> categories = [];
  final ImagePicker _picker = ImagePicker();
  XFile? imageFile;
  String currentImagePath = '';
  bool isLoading = true;
  String originalName = '';

  final TextEditingController categoryNameController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  List<Map<String, dynamic>> addonsList = [];
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
    originalName = widget.foodName; // Store original name for comparison
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    await _fetchCategories();
    await _loadItemData();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchCategories() async {
    List<String> fetchedCategories = await AuthService().getCategories(
      await getRestaurantName(),
    );

    setState(() {
      categories = fetchedCategories;
      print("cate");
      print(categories);
    });
  }

  Future<void> _loadItemData() async {
    String restaurantName = await getRestaurantName();
    List<Food> foods = await AuthService().getFoods(restaurantName);

    // Find the food with matching name
    Food? targetFood = foods.firstWhere(
      (food) => food.name == widget.foodName,
      // ignore: cast_from_null_always_fails
      orElse: () => null as Food, // This will throw if not found
    );

    // ignore: unnecessary_null_comparison
    if (targetFood != null) {
      setState(() {
        itemNameController.text = targetFood.name;
        descriptionController.text = targetFood.description;
        priceController.text = targetFood.price.toString();
        selectedCategory = targetFood.category.name;
        categoryNameController.text = selectedCategory ?? '';
        currentImagePath = targetFood.imagePath;

        // Load addons
        addonsList = [];
        addonNameControllers = [];
        addonPriceControllers = [];
        addonChecked = [];

        for (var addon in targetFood.availableAddon) {
          TextEditingController nameController = TextEditingController(
            text: addon.name,
          );
          TextEditingController priceController = TextEditingController(
            text: addon.price.toString(),
          );

          addonNameControllers.add(nameController);
          addonPriceControllers.add(priceController);
          addonChecked.add(
            true,
          ); // Since these are existing addons, mark them as checked
          addonsList.add({'name': addon.name, 'price': addon.price});
        }
      });
    } else {
      Navigator.pop(context); // Return to previous screen if item not found
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Item not found')));
    }
  }

  void updateItem() async {
    // Get restaurant name
    String restaurantName = await getRestaurantName();

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

    // Check if name changed and if it's unique
    if (itemNameController.text != originalName) {
      // Check if the new name already exists
      List<Food> foods = await AuthService().getFoods(restaurantName);
      bool nameExists = foods.any(
        (food) =>
            food.name == itemNameController.text && food.name != originalName,
      );

      if (nameExists) {
        setState(() {
          errorMessage = 'Item name already exists. Choose another one.';
        });
        return;
      }
    }

    // Prepare selected addons
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

      // Show loading indicator
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // First, find the document ID by querying for the original name
      var querySnapshot =
          await FirebaseFirestore.instance
              .collection('Restaurants')
              .doc(restaurantName)
              .collection('Food')
              .where('name', isEqualTo: originalName)
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = 'Item not found. It may have been deleted.';
        });
        return;
      }

      String docId = querySnapshot.docs.first.id;

      // Upload new image if selected
      String imagePath = currentImagePath;
      if (imageFile != null) {
        // Delete old image if it exists
        if (currentImagePath.isNotEmpty) {
          try {
            // Extract the file path from the URL
            Reference oldImageRef = FirebaseStorage.instance.refFromURL(
              currentImagePath,
            );
            await oldImageRef.delete();
          } catch (e) {
            print("Error deleting old image: $e");
            // Continue with update even if delete fails
          }
        }

        // Upload the new image
        File file = File(imageFile!.path);
        String fileName = file.path.split('/').last;

        Reference storageRef = FirebaseStorage.instance.ref().child(
          '$restaurantName/$fileName',
        );

        await storageRef.putFile(file);
        imagePath = await storageRef.getDownloadURL();
      }

      // Update the document
      await FirebaseFirestore.instance
          .collection('Restaurants')
          .doc(restaurantName)
          .collection('Food')
          .doc(docId)
          .update({
            'name': itemNameController.text,
            'description': descriptionController.text,
            'price': price,
            'category': categoryNameController.text,
            'availableAddon': selectedAddons,
            'imagePath': imagePath,
          });

      // Navigate back to admin page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminPage()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Item"),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
      drawer: MyDrawer(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_note,
                        size: 80,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      const SizedBox(height: 25),
                      Text(
                        "Edit Item",
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

                      // Category Dropdown
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

                      // Price field
                      MyTextfield(
                        controller: priceController,
                        hintText: "Price",
                        obscureText: false,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),

                      // Description field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: TextFormField(
                          controller: descriptionController,
                          maxLines: 4,
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
                            hintText: "Description",
                            hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Addons section
                      _buildAddonsSection(),
                      const SizedBox(height: 10),

                      // Current image preview
                      if (currentImagePath.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                "Current Image",
                                style: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.inversePrimary,
                                ),
                              ),
                              SizedBox(height: 5),
                              Container(
                                height: 150,
                                width: 150,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    currentImagePath,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (
                                      context,
                                      child,
                                      loadingProgress,
                                    ) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Text('Error loading image'),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Image picker
                      _buildImagePicker(),
                      const SizedBox(height: 25),

                      // Error message
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

                      // Update button
                      MyButton(onTap: updateItem, text: "Update Item"),
                      const SizedBox(height: 25),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Add-ons",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  addonNameControllers.add(TextEditingController());
                  addonPriceControllers.add(TextEditingController());
                  addonChecked.add(true);
                  addonsList.add({'name': '', 'price': 0.0});
                });
              },
              child: const Text("Add Add-on"),
            ),
          ],
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: addonsList.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: addonChecked[index],
                      onChanged: (value) {
                        setState(() {
                          addonChecked[index] = value!;
                        });
                      },
                    ),
                    Expanded(
                      flex: 3,
                      child: MyTextfield(
                        controller: addonNameControllers[index],
                        hintText: "Add-on Name",
                        obscureText: false,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: MyTextfield(
                        controller: addonPriceControllers[index],
                        hintText: "Price",
                        obscureText: false,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          addonNameControllers.removeAt(index);
                          addonPriceControllers.removeAt(index);
                          addonChecked.removeAt(index);
                          addonsList.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Improved Image Picker
  Widget _buildImagePicker() {
    return Column(
      children: [
        Text(
          imageFile != null
              ? "New Image Selected"
              : "Select New Image (Optional)",
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyButton(
              text: "Choose Image",
              onTap: () async {
                final XFile? selectedImage = await _picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (selectedImage != null) {
                  setState(() {
                    imageFile = selectedImage;
                  });
                }
              },
            ),
            SizedBox(width: 10),
            if (imageFile != null)
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check, color: Colors.green),
                    SizedBox(width: 5),
                    Text("New image ready"),
                  ],
                ),
              ),
          ],
        ),
        if (imageFile != null)
          TextButton(
            onPressed: () {
              setState(() {
                imageFile = null;
              });
            },
            child: Text("Clear selection"),
          ),
      ],
    );
  }
}
