import 'package:flutter/material.dart';
import 'package:menuapp/components/my_description_box.dart';
import 'package:menuapp/components/my_drawer.dart';
import 'package:menuapp/components/my_food_tile.dart';
import 'package:menuapp/components/my_silver_appBar.dart';
import 'package:menuapp/components/my_tabBar.dart';
import 'package:menuapp/models/food.dart';
import 'package:menuapp/pages/food_page.dart';
import 'package:menuapp/services/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<Food> foods = [];
  List<String> categories = [];
  String restaurantName = '';
  late TabController? _tabController;
  Future<void>? _dataFuture;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _dataFuture = _fetchRestaurantName().then((name) {
      //Assign the future in initState

      setState(() {
        restaurantName = name;
      });
      return _fetchFoodsAndCategories(); // Return the result of _fetchFoodsAndCategories
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _fetchFoodsAndCategories() async {
    try {
      List<Food> fetchedFoods = await AuthService().getFoods(restaurantName);
      List<String> fetchedCategories = await AuthService().getCategories(
        restaurantName,
      );

      setState(() {
        categories = fetchedCategories;

        foods = fetchedFoods;

        _tabController = TabController(
          length: categories.length, // Dynamic length
          vsync: this,
        );
      });
    } catch (e) {
      print("Error fetching data: $e");
      // ... Handle error (e.g., show a snackbar)
    }
  }

  Future<String> _fetchRestaurantName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('restaurantName') ?? "None";
  }

  @override
  Widget build(BuildContext context) {
    if (restaurantName.isEmpty) {
      //Handle initial state while fetching restaurantName
      return const Center(
        child: CircularProgressIndicator(),
      ); //or any loading widget
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      drawer: MyDrawer(),
      body: FutureBuilder(
        future: _dataFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return NestedScrollView(
              headerSliverBuilder:
                  (context, innerBoxIsScrolled) => [
                    MySilverAppbar(
                      restaurantName: restaurantName,
                      title:
                          _tabController != null
                              ? MyTabbar(
                                tabController: _tabController!,
                                categories: categories,
                              )
                              : const SizedBox.shrink(), // Conditional TabBar
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,

                        children: [
                          Container(
                            padding: const EdgeInsets.all(25),
                            margin: const EdgeInsets.only(left: 25, right: 25),
                            child: Text(
                              "Our Restaurant Is One of the Best That Makes The Special Burger.",
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.inversePrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Divider(
                            indent: 25,
                            endIndent: 25,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          MyDescriptionBox(),
                        ],
                      ),
                    ),
                  ],
              body:
                  categories.isNotEmpty
                      ? TabBarView(
                        controller: _tabController,
                        children:
                            categories.asMap().entries.map((entry) {
                              int index = entry.key;
                              String categoryName = entry.value;
                              List<Food> categoryFoods =
                                  foods
                                      .where(
                                        (food) =>
                                            food.category.name == categoryName,
                                      )
                                      .toList();

                              return ListView.builder(
                                itemCount: categoryFoods.length,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) {
                                  Food food = categoryFoods[index];

                                  return MyFoodTile(
                                    food: food,
                                    onTap:
                                        () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    FoodPage(food: food),
                                          ),
                                        ),
                                  );
                                },
                              );
                            }).toList(),
                      )
                      : const Center(child: Text('No categories found')),
            );
          }
        },
      ),
    );
  }
}
