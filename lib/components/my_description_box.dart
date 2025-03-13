import 'package:flutter/material.dart';

class MyDescriptionBox extends StatelessWidget {
  const MyDescriptionBox({super.key});

  @override
  Widget build(BuildContext context) {
    var myPrimaryTextStyle = TextStyle(
      color: Theme.of(context).colorScheme.inversePrimary,
    );
    var mySecondTextStyle = TextStyle(
      color: Theme.of(context).colorScheme.primary,
    );
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.secondary),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.only(left: 25, right: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text('For Support', style: myPrimaryTextStyle),
              GestureDetector(
                child: Icon(
                  Icons.phone,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () {},
              ),
            ],
          ),

          Column(
            children: [
              Text('15-30 min', style: myPrimaryTextStyle),
              Text('Preparation time', style: mySecondTextStyle),
            ],
          ),
        ],
      ),
    );
  }
}
