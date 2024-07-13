import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'cartModel.dart';



class CartService {
  static const _cartKey = 'cart';

  Future<void> addToCart(CartItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final cart = await getCartItems();
    final index = cart.indexWhere((element) => element.id == item.id);

    if (index == -1) {
      cart.add(item);
    } else {
      cart[index].quantity += 1;
    }

    await prefs.setString(_cartKey, jsonEncode(cart.map((e) => e.toJson()).toList()));
  }

  Future<void> removeFromCart(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final cart = await getCartItems();
    final index = cart.indexWhere((element) => element.id == id);

    if (index != -1) {
      if (cart[index].quantity > 1) {
        cart[index].quantity -= 1;
      } else {
        cart.removeAt(index);
      }
    }

    await prefs.setString(_cartKey, jsonEncode(cart.map((e) => e.toJson()).toList()));
  }

  Future<List<CartItem>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString(_cartKey);
    if (cartString != null) {
      final List<dynamic> cartJson = jsonDecode(cartString);
      return cartJson.map((e) => CartItem.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}
