import 'package:flutter/material.dart';

class MySilverAppbar extends StatelessWidget {
  final Widget child;
  final Widget title;
  final String restaurantName;
  const MySilverAppbar({super.key, required this.child, required this.title,required this.restaurantName});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 340,
      collapsedHeight: 120,
      floating: false,
      pinned: true,
      actions: [IconButton(onPressed: () {}, icon: Icon(Icons.shopping_cart))],
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(restaurantName),
      flexibleSpace: FlexibleSpaceBar(
        title: title,
        centerTitle: true,
        titlePadding: const EdgeInsets.only(left: 0, right: 0, top: 0),
        expandedTitleScale: 1,
        background: Padding(
          padding: const EdgeInsets.only(bottom: 50),
          child: child,
        ),
      ),

      centerTitle: true,
    );
  }
}
