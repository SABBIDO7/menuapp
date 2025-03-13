import 'package:flutter/material.dart';
import 'package:menuapp/components/my_description_box.dart';
import 'package:menuapp/components/my_drawer.dart';
import 'package:menuapp/components/my_silver_appBar.dart';
import 'package:menuapp/components/my_tabBar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              MySilverAppbar(
                title: MyTabbar(tabController: _tabController),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,

                  children: [
                    Divider(
                      indent: 25,
                      endIndent: 25,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    MyDescriptionBox(),
                  ],
                ),
              ),
            ],
        body: TabBarView(
          controller: _tabController,
          children: [
            ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => Text("First Tab"),
            ),
            ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => Text("Second Tab"),
            ),
            ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => Text("Third Tab"),
            ),
          ],
        ),
      ),
    );
  }
}
