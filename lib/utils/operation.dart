import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:menuapp/models/cart_item.dart';
import 'package:menuapp/models/food.dart';
class operation extends ChangeNotifier{
  List<CartItem> get cart => _cart;
  List<CartItem> _cart = [];
  void addToCart(Food food, List<Addon> selectedAddons) {
    CartItem? cartItem = _cart.firstWhereOrNull((item) {
      // check if the food items are the same
      bool isSameFood = item.food == food;
// check if the addson are the same
      bool isSameAddons = ListEquality().equals(
          item.selectedAddons, selectedAddons);
      return isSameFood && isSameAddons;
    });
    // if item already exsists
    if (cartItem != null) {
      cartItem.quantity++;
    }

    //else add new item to the cart
    else {
      _cart.add(
          CartItem(food: food, selectedAddons: selectedAddons)
      );
    }
    notifyListeners();
  }
void removeFromCart(CartItem cartItem){
    int cartIndex = _cart.indexOf(cartItem);
    if(cartIndex !=-1){
      if(_cart[cartIndex].quantity > 1){
        _cart[cartIndex].quantity--;
      }else{
        _cart.removeAt(cartIndex);
      }
    }
    notifyListeners();
}

//get total price of cart

double getTotalPrice() {
    double total = 0.0;
    for (CartItem cartItem in _cart){
      double itemTotal = cartItem.food.price;
      for(Addon addon in cartItem.selectedAddons){
        itemTotal += addon.price;
      }
      total += itemTotal * cartItem.quantity;
    }
    return total;
}

// get total number of items
int getTotalItemCount(){
    int totalItemCount = 0 ;
    for(CartItem cartItem in _cart){
      totalItemCount+=cartItem.quantity;
    }
    return totalItemCount;
}
//clear cart

void clearCart(){
    _cart.clear();
    notifyListeners();
}


}