import 'package:flutter/material.dart';
import 'package:menuapp/components/my_drawer.dart';
import 'package:menuapp/components/my_drawer_tile.dart';
import 'package:menuapp/pages/superAdmin/createAdmin_page.dart';
import 'package:menuapp/pages/superAdmin/createRestaurant_page.dart';

class SuperadminPage extends StatelessWidget {
  const SuperadminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Super Admin"),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
      drawer: MyDrawer(),
      body: Column(
        children: [
          MyDrawerTile(
            text: "Create Restaurant",
            icon: Icons.restaurant_menu_outlined,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreaterestaurantPage(),
                  ),
                ),
          ),
          Divider(color: Theme.of(context).colorScheme.secondary),
          MyDrawerTile(
            text: "Create Admin",
            icon: Icons.admin_panel_settings,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateadminPage()),
                ),
          ),
          Divider(color: Theme.of(context).colorScheme.secondary),
        ],
      ),
    );
  }
}
