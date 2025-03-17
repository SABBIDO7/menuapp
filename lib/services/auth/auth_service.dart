import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:menuapp/models/food.dart';
import 'package:menuapp/services/auth/login_or_register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; // For image picking
import 'package:firebase_storage/firebase_storage.dart';
import 'package:crypto/crypto.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Log in function using username and password
  Future<Map<String, dynamic>> logIn(
    String username,
    String password,
    String restoName,
  ) async {
    try {
      // Retrieve user from Firestore by username
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('users')
              .where('username', isEqualTo: username)
              .where('restaurantName', isEqualTo: restoName)
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        print("user incorrect hereeee");

        throw Exception("User not found");
      }

      var userDoc = querySnapshot.docs.first;
      String storedHashedPassword =
          userDoc['password']; // Ideally, hash this before storing
      String role = userDoc['role'];
      String restaurantName = userDoc['restaurantName'];

      // Check if the password matches
      var bytes = utf8.encode(password);
      var digest = sha256.convert(bytes);
      String enteredHashedPassword = digest.toString();

      // 3. Check if the hashed passwords match
      if (enteredHashedPassword != storedHashedPassword) {
        throw Exception("Incorrect password");
      }

      String phoneNumber = "";

      CollectionReference profileCollection = _firestore
          .collection("Restaurants")
          .doc(restaurantName)
          .collection('profile');

      QuerySnapshot snapshot =
          await profileCollection.get(); // Get all profile docs

      if (snapshot.docs.isNotEmpty) {
        // Check if a profile doc exists
        print("pppp");
        String profileDocId = snapshot.docs[0].id;
        // Fetch the phoneNumber from the "profile" collection using the userId
        DocumentSnapshot profileDoc =
            await FirebaseFirestore.instance
                .collection("Restaurants")
                .doc(restaurantName)
                .collection('profile')
                .doc(profileDocId)
                .get();

        if (profileDoc.exists) {
          phoneNumber = profileDoc['phoneNumber'] ?? "";
        }
      }
      print("here2");
      print(phoneNumber);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username);
      await prefs.setString('role', role);
      await prefs.setString('restaurantName', restaurantName);
      await prefs.setString('phoneNumber', phoneNumber);

      return {
        'username': username,
        'role': role,
        'restaurantName': restaurantName,
        'phoneNumber': phoneNumber,
      };
    } catch (e) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clears all stored session data
      print("failed hereeee $e");
      throw Exception("Login failed: $e");
    }
  }

  Future<String> signUp(
    String username,
    String password,
    String restaurantName,
    String role,
  ) async {
    try {
      // Check if username is already taken
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('users')
              .where('username', isEqualTo: username)
              .where('restaurantName', isEqualTo: restaurantName)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return "Username already exists. Choose another one.";
      }

      // Generate a unique user ID (since we're not using Firebase Auth)
      String userId = _firestore.collection('users').doc().id;
      // 1. Hash the password using SHA256
      var bytes = utf8.encode(password); // Encode the password as UTF-8 bytes
      var digest = sha256.convert(bytes); // Generate the SHA256 hash
      String hashedPassword = digest.toString();
      // Save user data to Firestore
      await _firestore.collection('users').doc(userId).set({
        'username': username,
        'password': hashedPassword, // Store a hashed password in production
        'restaurantName': restaurantName,
        'role': role, // 'admin', 'user', or 'superAdmin'
      });
      return "Success";
    } catch (e) {
      return "Sign-up failed: $e";
    }
  }

  Future<void> signOut(BuildContext context) async {
    // Since we are not using Firebase Auth, we simply clear session storage.
    // If you store user data in SharedPreferences or GetStorage, clear it here.
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn'); // Clear login session
      await prefs.remove('username');
      await prefs.remove('role');
      await prefs.remove('restaurantName');
      await prefs.remove('phoneNumber');

      // Navigate to Login Screen after logout
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginOrRegister()),
        (route) => false, // Remove all previous routes
      );

      print("User signed out successfully.");
    } catch (e) {
      print("Sign out failed: $e");
    }
    print("User signed out successfully.");
  }

  Future<String> createCategory(
    String categoryName,
    String restaurantName,
  ) async {
    try {
      // Check if category is already taken
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('Restaurants')
              .doc(restaurantName)
              .collection("categories")
              .where('name', isEqualTo: categoryName)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return "Category already exists. Choose another one.";
      }

      // Generate a unique category ID (since we're not using Firebase Auth)
      String categoryId =
          _firestore
              .collection('Restaurants')
              .doc(restaurantName)
              .collection("categories")
              .doc()
              .id;

      // Save category data to Firestore
      await _firestore
          .collection('Restaurants')
          .doc(restaurantName)
          .collection("categories")
          .doc(categoryId)
          .set({'name': categoryName});
      return "Success";
    } catch (e) {
      return "Creation failed: $e";
    }
  }

  Future<String> createItem(
    String itemName,
    String description,
    double price,
    List<Map<String, dynamic>> availableAddons,
    String categoryName,
    String restaurantName,
    XFile? imageFile,
  ) async {
    try {
      // Check if category is already taken
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('Restaurants')
              .doc(restaurantName)
              .collection("Food")
              .where('name', isEqualTo: itemName)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return "Item already exists. Choose another one.";
      }

      // Generate a unique item ID (since we're not using Firebase Auth)
      String itemId =
          _firestore
              .collection('Restaurants')
              .doc(restaurantName)
              .collection("Food")
              .doc()
              .id;
      String imagePath = ''; // Initialize imagePath

      // 3. Upload image to Firebase Storage if provided
      if (imageFile != null) {
        File file = File(imageFile.path);
        String fileName = file.path.split('/').last;

        Reference storageRef = FirebaseStorage.instance.ref().child(
          '$restaurantName/$fileName',
        ); // Use restaurant name

        await storageRef.putFile(file);
        imagePath = await storageRef.getDownloadURL();
      }
      // Save item data to Firestore
      await _firestore
          .collection('Restaurants')
          .doc(restaurantName)
          .collection("Food")
          .doc(itemId)
          .set({
            'name': itemName,
            'category': categoryName,
            'description': description,
            'price': price,
            'availableAddon': availableAddons,
            'imagePath': imagePath,
          });
      return "Success";
    } catch (e) {
      return "Creation failed: $e";
    }
  }

  Future<List<String>> getCategories(String restaurantName) async {
    // Add restaurantName parameter
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('Restaurants')
              .doc(restaurantName) // Use the restaurantName
              .collection('categories')
              .get();

      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      print("Error fetching categories: $e");
      return []; // Return an empty list in case of an error
    }
  }

  Future<String> createOrEditProfile(
    String phoneNumber,
    String restaurantNameChoosen,

    String restaurantName,
  ) async {
    try {
      CollectionReference profileCollection = _firestore
          .collection("Restaurants")
          .doc(restaurantName)
          .collection('profile');

      QuerySnapshot snapshot =
          await profileCollection.get(); // Get all profile docs

      if (snapshot.docs.isNotEmpty) {
        // Check if a profile doc exists
        print("pppp");
        String profileDocId =
            snapshot.docs[0].id; // Get the ID of the first (and only) document
        DocumentReference profileRef = profileCollection.doc(profileDocId);

        await profileRef.set({
          'phoneNumber': phoneNumber,
          'name': restaurantNameChoosen,
        });
      } else {
        print("pppp22");

        String profileDocId =
            _firestore.doc(restaurantName).collection('profile').doc().id;
        DocumentReference profileRef = profileCollection.doc(profileDocId);

        await profileRef.set({
          'phoneNumber': phoneNumber,
          'name': restaurantNameChoosen,
        });
      }
      return "Success";
    } catch (e) {
      return "Failed to create/edit profile: $e";
    }
  }

  Future<List<String>> getRestaurants() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Restaurants').get();

      return snapshot.docs.map((doc) => doc.id).toList(); //Use Doc IDs
    } catch (e) {
      print("Error fetching restaurant names: $e");
      return [];
    }
  }

  Future<String> createRestaurant(String restaurantName) async {
    try {
      // 1. Check if restaurant name already exists
      DocumentSnapshot restaurantDoc =
          await FirebaseFirestore.instance
              .collection('Restaurants')
              .doc(restaurantName)
              .get();

      if (restaurantDoc.exists) {
        return "Restaurant name already exists.";
      }

      // 2. Create restaurant document in Firestore
      await FirebaseFirestore.instance
          .collection('Restaurants')
          .doc(restaurantName)
          .set({}); // Empty document initially

      // // 3. Create subcollections
      // await FirebaseFirestore.instance
      //     .collection('Restaurants')
      //     .doc(restaurantName)
      //     .collection('Food')
      //     .add({}); //Add an empty document to ensure creation

      // await FirebaseFirestore.instance
      //     .collection('Restaurants')
      //     .doc(restaurantName)
      //     .collection('categories')
      //     .add({});

      await FirebaseFirestore.instance
          .collection('Restaurants')
          .doc(restaurantName)
          .collection('profile')
          .add({"name": "", "phoneNumber": ""});

      // // 4. Create folder in Firebase Storage
      // Reference storageRef = FirebaseStorage.instance.ref().child(
      //   restaurantName,
      // );
      // await storageRef.putString(
      //   "",
      //   metadata: SettableMetadata(contentType: 'text/plain'),
      // ); // Create an empty folder in storage.

      return "Success";
    } catch (e) {
      print("Error creating restaurant: $e");
      return "Error creating restaurant: $e";
    }
  }

  Future<List<Food>> getFoods(String restaurantName) async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('Restaurants')
              .doc(restaurantName)
              .collection('Food')
              .get();

      List<Food> foods = [];
      for (var doc in snapshot.docs) {
        // Convert Firestore data to Food object
        List<Addon> availableAddon = [];
        if (doc['availableAddon'] != null) {
          for (var addon in doc['availableAddon']) {
            availableAddon.add(
              Addon(name: addon['name'], price: addon['price']),
            );
          }
        }
        foods.add(
          Food(
            name: doc['name'],
            description: doc['description'],
            imagePath: doc['imagePath'],
            price: doc['price'].toDouble(),
            category: _getFoodCategory(doc['category']),
            availableAddon: availableAddon,
          ),
        );
      }
      return foods;
    } catch (e) {
      print('Error getting foods: $e');
      return [];
    }
  }

  // Helper function to convert string to FoodCategory object
  FoodCategory _getFoodCategory(String categoryString) {
    return FoodCategory.fromString(
      categoryString,
    ); // Create a FoodCategory object
  }

  Future<String> editItem(
    String itemId,
    String itemName,
    String description,
    double price,
    List<Map<String, dynamic>> availableAddons,
    String categoryName,
    String restaurantName,
    XFile? imageFile,
    String currentImagePath,
  ) async {
    try {
      // Check if the new name is already taken by another item
      if (itemName != itemName) {
        // Only check if name has changed
        QuerySnapshot querySnapshot =
            await _firestore
                .collection('Restaurants')
                .doc(restaurantName)
                .collection("Food")
                .where('name', isEqualTo: itemName)
                .where(
                  FieldPath.documentId,
                  isNotEqualTo: itemId,
                ) // Exclude the current item
                .limit(1)
                .get();

        if (querySnapshot.docs.isNotEmpty) {
          return "Item name already exists. Choose another one.";
        }
      }

      String imagePath = currentImagePath; // Start with the current image path

      // Upload new image to Firebase Storage if provided
      if (imageFile != null) {
        // Delete the old image if it exists
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
        File file = File(imageFile.path);
        String fileName = file.path.split('/').last;

        Reference storageRef = FirebaseStorage.instance.ref().child(
          '$restaurantName/$fileName',
        );

        await storageRef.putFile(file);
        imagePath = await storageRef.getDownloadURL();
      }

      // Update item data in Firestore
      await _firestore
          .collection('Restaurants')
          .doc(restaurantName)
          .collection("Food")
          .doc(itemId)
          .update({
            'name': itemName,
            'category': categoryName,
            'description': description,
            'price': price,
            'availableAddon': availableAddons,
            'imagePath': imagePath,
          });

      return "Success";
    } catch (e) {
      return "Update failed: $e";
    }
  }

  // Method to fetch a specific food item by ID
  Future<Map<String, dynamic>?> getItemById(
    String itemId,
    String restaurantName,
  ) async {
    try {
      DocumentSnapshot document =
          await _firestore
              .collection('Restaurants')
              .doc(restaurantName)
              .collection("Food")
              .doc(itemId)
              .get();

      if (document.exists) {
        return document.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching item: $e");
      return null;
    }
  }

  // Add this method to your AuthService class
  Future<String> deleteItem(String foodName, String restaurantName) async {
    try {
      // Find the document with matching name
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('Restaurants')
              .doc(restaurantName)
              .collection("Food")
              .where('name', isEqualTo: foodName)
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        return "Item not found";
      }

      // Get the document ID
      String docId = querySnapshot.docs.first.id;

      // Check if there's an image to delete from storage
      //String imagePath = querySnapshot.docs.first['imagePath'] ?? '';

      // Delete the document from Firestore
      await _firestore
          .collection('Restaurants')
          .doc(restaurantName)
          .collection("Food")
          .doc(docId)
          .delete();

      // Delete the image from storage if it exists
      // if (imagePath.isNotEmpty) {
      //   try {
      //     Reference imageRef = FirebaseStorage.instance.refFromURL(imagePath);
      //     await imageRef.delete();
      //   } catch (e) {
      //     print("Error deleting image: $e");
      //     // Continue with deletion even if image deletion fails
      //   }
      // }

      return "Success";
    } catch (e) {
      print("Error deleting item: $e");
      return "Deletion failed: $e";
    }
  }
}
