import 'package:flutter/material.dart';
import 'package:menuapp/models/cart_item.dart';
import 'package:menuapp/utils/operation.dart';
import 'package:provider/provider.dart';

import '../utils/no_img.dart';

class MyCartTile extends StatelessWidget {
  final CartItem cartItem;
  const MyCartTile({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    return Consumer<operation>(
      builder:
          (context, restaurant, child) => Container(
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        cartItem.food.imagePath != ""
                            ? cartItem.food.imagePath
                            : imgPath,
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cartItem.food.name,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${cartItem.food.price}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}
