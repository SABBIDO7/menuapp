import 'package:flutter/material.dart';

class MyTabbar extends StatelessWidget {
  final TabController tabController;
  final List<String> categories;
  const MyTabbar({
    super.key,
    required this.tabController,
    required this.categories,
  });
  List<Tab> _buildCategoriesTab() {
    return categories.asMap().entries.map((entry) {
      return Tab(text: entry.value);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
        ),
        child: TabBar(
          controller: tabController,
          isScrollable: true,
          tabs: _buildCategoriesTab(),
        ),
      ),
    );
  }
}
