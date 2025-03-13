class Food {
  final String name;
  final String description;
  final String imagePath;
  final double price;
  final FoodCategory category;
  List<Addon> availableAddon;
  Food({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.price,
    required this.category,
    required this.availableAddon,
  });
}

class FoodCategory {
  String name; 
  FoodCategory({required this.name});
   // Factory constructor to create from a string (optional but helpful)
  factory FoodCategory.fromString(String categoryString) {
    return FoodCategory(name: categoryString);
  }
}

class Addon {
  String name;
  double price;
  Addon({required this.name, required this.price});
}
