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
    return Container(
      child: TabBar(controller: tabController, tabs: _buildCategoriesTab()),
    );
  }
}
