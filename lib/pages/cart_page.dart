import 'package:flutter/material.dart';
import 'package:menuapp/components/my_button.dart';
import 'package:menuapp/components/my_cart_tile.dart';
import 'package:menuapp/utils/operation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';
import 'package:url_launcher/url_launcher.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});
  Future<String> getPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('phoneNumber') ?? "";
  }

  Future<String> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? "";
  }

  void sendOrderToWhatsApp(List<CartItem> cart, operation restaurant) async {
    if (cart.isEmpty) return;

    StringBuffer message = StringBuffer();
    String username = await getUser();
    message.writeln("🛒 *Order Details:* for $username");
    message.writeln("-----------------------------------");

    double totalAmount = 0;

    for (var item in cart) {
      message.writeln("🍽️ *${item.food.name}*");
      message.writeln("   - Quantity: ${item.quantity}");
      message.writeln("   - Price: \$${item.food.price.toStringAsFixed(2)}");

      if (item.selectedAddons.isNotEmpty) {
        message.writeln("   - Addons:");
        for (var addon in item.selectedAddons) {
          message.writeln(
            "     ✅ ${addon.name} (\$${addon.price.toStringAsFixed(2)})",
          );
        }
      }

      double itemTotal = item.totalPrice;
      totalAmount += itemTotal;
      message.writeln("   - *Total: \$${itemTotal.toStringAsFixed(2)}*");
      message.writeln("-----------------------------------");
    }

    message.writeln("*Grand Total: \$${totalAmount.toStringAsFixed(2)}*");

    String phoneNumber =
        await getPhoneNumber(); // Replace with the restaurant's WhatsApp number
    print("here");
    print(phoneNumber);
    String whatsappUrl =
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message.toString())}";

    Uri uri = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      restaurant.clearCart();
    } else {
      debugPrint("Could not open WhatsApp.");
    }
  }

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
            actions: [
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text("Are sure you want to delete the cart?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                resturant.clearCart();
                              },
                              child: Text("Yes"),
                            ),
                          ],
                        ),
                  );
                },
                icon: Icon(Icons.delete),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    userCart.isEmpty
                        ? Expanded(
                          child: Center(child: Text("Cart is Empty ...")),
                        )
                        : Expanded(
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
              ),
              MyButton(
                onTap: () => sendOrderToWhatsApp(userCart, resturant),
                text: "Make Order (\$${resturant.getTotalPrice()})",
              ),
              SizedBox(height: 25),
            ],
          ),
        );
      },
    );
  }
}
