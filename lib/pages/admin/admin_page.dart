import 'package:flutter/material.dart';
import 'package:menuapp/components/my_drawer.dart';
import 'package:menuapp/components/my_drawer_tile.dart';
import 'package:menuapp/pages/admin/createCategories_page.dart';
import 'package:menuapp/pages/admin/createItem_page.dart';
import 'package:menuapp/pages/admin/create_user.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin"),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
      drawer: MyDrawer(),
      body: Column(
        children: [
          MyDrawerTile(
            text: "Create User",
            icon: Icons.create_new_folder,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateUser()),
                ),
          ),
          Divider(color: Theme.of(context).colorScheme.secondary),
          MyDrawerTile(
            text: "Add Item",
            icon: Icons.food_bank,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateitemPage()),
                ),
          ),
          Divider(color: Theme.of(context).colorScheme.secondary),

          MyDrawerTile(
            text: "Add Category",
            icon: Icons.category_rounded,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreatecategoriesPage(),
                  ),
                ),
          ),
          Divider(color: Theme.of(context).colorScheme.secondary),
          MyDrawerTile(
            text: "Edit Item",
            icon: Icons.edit_document,
            onTap: () {},
          ),
          Divider(color: Theme.of(context).colorScheme.secondary),
          MyDrawerTile(
            text: "Edit Profile",
            icon: Icons.supervised_user_circle_sharp,
            onTap: () {},
          ),
          Divider(color: Theme.of(context).colorScheme.secondary),
        ],
      ),
    );
  }
}
