import 'package:flutter/material.dart';
import 'package:menuapp/components/my_drawer.dart';
import 'package:menuapp/components/my_drawer_tile.dart';

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
            onTap: () {},
          ),
          Divider(color: Theme.of(context).colorScheme.secondary),
          MyDrawerTile(
            text: "Add Item",
            icon: Icons.menu_book_rounded,
            onTap: () {},
          ),
          Divider(color: Theme.of(context).colorScheme.secondary),
          MyDrawerTile(
            text: "Edit Item",
            icon: Icons.edit_document,
            onTap: () {},
          ),
          Divider(color: Theme.of(context).colorScheme.secondary),
        ],
      ),
    );
  }
}
