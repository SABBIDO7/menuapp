import 'package:flutter/material.dart';
import 'package:menuapp/components/my_drawer_tile.dart';
import 'package:menuapp/pages/admin/admin_page.dart';
import 'package:menuapp/pages/home_page.dart';
import 'package:menuapp/pages/settings_page.dart';
import 'package:menuapp/services/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyDrawer extends StatelessWidget {
  Future<String> userRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role') ?? "user";
  }

  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: userRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          ); // Show loading indicator while checking session
        } else {
          String userRole = snapshot.data ?? "user";
          return Drawer(
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Icon(
                    Icons.lock_open_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: Divider(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                MyDrawerTile(
                  text: "H O M E",
                  icon: Icons.home,
                  onTap:
                      () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  userRole == "user"
                                      ? const HomePage()
                                      : const AdminPage(),
                        ),
                        (route) => false,
                      ),
                ),
                MyDrawerTile(
                  text: "S E T T I N G S",
                  icon: Icons.settings,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
                Spacer(),
                MyDrawerTile(
                  text: "L O G O U T",
                  icon: Icons.logout,
                  onTap: () async {
                    await AuthService().signOut(
                      context,
                    ); // Call sign-out method
                  },
                ),
                SizedBox(height: 25),
              ],
            ),
          );
        }
      },
    );
  }
}
