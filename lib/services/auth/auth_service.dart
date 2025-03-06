import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:menuapp/services/auth/login_or_register.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      String storedPassword =
          userDoc['password']; // Ideally, hash this before storing
      String role = userDoc['role'];
      String restaurantName = userDoc['restaurantName'];

      // Check if the password matches
      if (password != storedPassword) {
        print("password incorrect hereeee");

        throw Exception("Incorrect password");
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username);
      return {
        'username': username,
        'role': role,
        'restaurantName': restaurantName,
      };
    } catch (e) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clears all stored session data
      print("failed hereeee $e");
      throw Exception("Login failed: $e");
    }
  }

  Future<void> signOut(BuildContext context) async {
    // Since we are not using Firebase Auth, we simply clear session storage.
    // If you store user data in SharedPreferences or GetStorage, clear it here.
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn'); // Clear login session

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
}
