import 'package:flutter/material.dart';
import 'package:menuapp/components/my_drawer.dart';
import 'package:menuapp/components/my_food_tile.dart';
import 'package:menuapp/models/food.dart';
import 'package:menuapp/pages/admin/editItem_page.dart';
import 'package:menuapp/services/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodListPage extends StatefulWidget {
  const FoodListPage({Key? key}) : super(key: key);

  @override
  State<FoodListPage> createState() => _FoodListPageState();
}

class _FoodListPageState extends State<FoodListPage> {
  List<Food> foods = [];
  bool isLoading = true;
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();
  String? selectedCategory;
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<String> getRestaurantName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('restaurantName') ?? "None";
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    String restaurantName = await getRestaurantName();

    // Load foods
    List<Food> loadedFoods = await AuthService().getFoods(restaurantName);

    // Extract unique categories from foods
    Set<String> uniqueCategories = Set<String>();
    for (var food in loadedFoods) {
      uniqueCategories.add(food.category.name);
    }

    setState(() {
      foods = loadedFoods;
      categories = uniqueCategories.toList()..sort();
      isLoading = false;
    });
  }

  // Filter foods based on search query and selected category
  List<Food> getFilteredFoods() {
    return foods.where((food) {
      bool matchesSearch =
          searchQuery.isEmpty ||
          food.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          food.description.toLowerCase().contains(searchQuery.toLowerCase());

      bool matchesCategory =
          selectedCategory == null || food.category.name == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Food> filteredFoods = getFilteredFoods();

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Menu Items"),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
      drawer: MyDrawer(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        hintText: 'Search items...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),

                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),

                  // Category filter
                  if (categories.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        children: [
                          Text(
                            'Filter by category: ',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),

                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              value: selectedCategory,
                              hint: Text('All categories'),
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                                hintText: 'Select Category',
                                hintStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                labelText: 'Category',
                              ),
                              items: [
                                DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text(
                                    'All categories',
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.inversePrimary,
                                    ),
                                  ),
                                ),
                                ...categories
                                    .map(
                                      (category) => DropdownMenuItem<String?>(
                                        value: category,
                                        child: Text(
                                          category,
                                          style: TextStyle(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.inversePrimary,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedCategory = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Results count
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${filteredFoods.length} items found',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),

                  // Food list
                  Expanded(
                    child:
                        filteredFoods.isEmpty
                            ? Center(
                              child: Text(
                                'No items found. Try changing your search or filters.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.inversePrimary,
                                ),
                              ),
                            )
                            : RefreshIndicator(
                              onRefresh: _loadData,
                              child: ListView.builder(
                                padding: EdgeInsets.only(bottom: 20),
                                itemCount: filteredFoods.length,
                                itemBuilder: (context, index) {
                                  return _buildFoodItem(filteredFoods[index]);
                                },
                              ),
                            ),
                  ),
                ],
              ),
    );
  }

  Widget _buildFoodItem(Food food) {
    return Stack(
      children: [
        // The original food tile
        MyFoodTile(
          food: food,
          onTap: () {
            _navigateToEditPage(food.name);
          },
        ),
        // Edit button overlay
        Positioned(
          top: 10,
          right: 10,
          child: Row(
            children: [
              // Delete button
              Container(
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.white),
                  onPressed: () {
                    _showDeleteConfirmation(food);
                  },
                  tooltip: 'Delete item',
                ),
              ),

              // Edit button overlay
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    onPressed: () {
                      _navigateToEditPage(food.name);
                    },
                    tooltip: 'Edit item',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToEditPage(String foodName) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditItemPage(foodName: foodName)),
    ).then((_) {
      // Refresh the list when returning from edit page
      _loadData();
    });
  }

  void _showDeleteConfirmation(Food food) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete ${food.name}?'),
          content: Text('This action cannot be undone.'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog

                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Center(child: CircularProgressIndicator());
                  },
                );

                // Get restaurant name
                String restaurantName = await getRestaurantName();

                // Call delete function from AuthService
                String result = await AuthService().deleteItem(
                  food.name,
                  restaurantName,
                );

                // Close loading dialog
                Navigator.of(context).pop();

                // Show result message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result == "Success"
                          ? "Item deleted successfully"
                          : "Error: $result",
                    ),
                    backgroundColor:
                        result == "Success" ? Colors.green : Colors.red,
                  ),
                );

                // Refresh the list if deletion was successful
                if (result == "Success") {
                  _loadData();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
