//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:menuapp/components/my_button.dart';
import 'package:menuapp/components/my_drawer.dart';
import 'package:menuapp/components/my_textfield.dart';
import 'package:menuapp/pages/admin/admin_page.dart';
import 'package:menuapp/services/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl_phone_field/intl_phone_field.dart'; // For phone number field

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String errorMessage = "";
  final TextEditingController restaurantNameController =
      TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  String? initialPhoneNumber; // Store initial phone number
  String completePhoneNumber = '';
  String? initialCountryCode; // Default country code

  Future<String> getRestaurantName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('restaurantName') ?? "None";
  }

  @override
  void initState() {
    super.initState();
    
  }

  // Future<void> _loadProfileData() async {
  //   try {
  //     print("pppp ABEL");
  //     String info = await getRestaurantName();
  //     String restaurantName = info;
  //     QuerySnapshot snapshot =
  //         await FirebaseFirestore.instance
  //             .collection("Restaurants")
  //             .doc(restaurantName)
  //             .collection('profile')
  //             .limit(1)
  //             .get();

  //     if (snapshot.docs.isNotEmpty) {
  //       print("pppp2 FET");

  //       DocumentSnapshot profileDoc =
  //           snapshot.docs[0]; // Access the first document

  //       setState(() {
  //         restaurantNameController.text = profileDoc.get('name') ?? '';
  //         initialPhoneNumber = _extractNationalNumber(
  //           profileDoc.get('phoneNumber') as String? ?? '',
  //         );
  //         initialCountryCode = _extractCountryCode(
  //           profileDoc.get('phoneNumber') as String? ?? '',
  //           initialCountryCode ?? "FR",
  //         ); // Extract or set default
  //         print(
  //           'National Number: $initialPhoneNumber, Country Code: $initialCountryCode',
  //         );
  //       });
  //     }
  //   } catch (e) {
  //     print("Error loading profile data: $e");
  //     setState(() {
  //       errorMessage = 'Error loading profile: $e';
  //     });
  //   }
  // }

 

  void createOrEditProfile() async {
    // Get input values

    String info = await getRestaurantName();
    String restaurantName = info;
    String restaurantNameChoosen = restaurantNameController.text;
    // Validate input fields
    if (completePhoneNumber.isEmpty || restaurantNameChoosen.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields';
      });
      return;
    }

    try {
      // Call your login service to authenticate the user
      var profileRequest = await AuthService().createOrEditProfile(
        completePhoneNumber,
        restaurantNameChoosen,
        restaurantName,
      );

      // If login is successful, navigate to the home page
      if (profileRequest == "Success") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPage()),
        );
      } else {
        setState(() {
          errorMessage = profileRequest;
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
        title: Text("Profile"),
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
                Icons.supervised_user_circle_sharp,
                size: 80,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              const SizedBox(height: 25),
              Text(
                "Profile",
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              const SizedBox(height: 25),
              MyTextfield(
                controller: restaurantNameController,
                hintText: "Restaurant name",
                obscureText: false,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: IntlPhoneField(
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
                    hintText: "Phone Number",
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  initialCountryCode:
                      
                      'FR', // Use initialCountryCode from state or default
                  // Use extracted country code
                  initialValue: initialPhoneNumber, // Set initial phone number

                  onChanged: (phone) {
                    completePhoneNumber = phone.completeNumber;
                  },
                ),
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
              MyButton(onTap: createOrEditProfile, text: "Update Profile"),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
