import 'package:flutter/material.dart';
import 'package:menuapp/components/my_cart_tile.dart';
import 'package:menuapp/utils/operation.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<operation>(
      builder: (context, resturant, child) {
        final userCart = resturant.cart;
        return Scaffold(
          appBar: AppBar(
            title: Text("Cart"),
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: userCart.length,
                  itemBuilder: (context, index) {
                    final cartItem = userCart[index];
                    return MyCartTile(cartItem: cartItem);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
