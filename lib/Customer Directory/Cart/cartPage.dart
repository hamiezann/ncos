import 'dart:async';
import 'dart:convert';
import 'package:app_links/app_links.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutter/material.dart';
import 'package:ncos/Customer%20Directory/Payment/successPayment.dart';
import 'package:ncos/Network%20Configuration/networkConfig.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Cart/cartModel.dart';
import 'cartWidget.dart';
import 'package:http/http.dart' as http;

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();
  List<CartItem> cartItems = [];
  late AppLinks _appLinks;
  late StreamSubscription _appLinksSubscription;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool paymentFailed = false;
  bool paymentSuccessful = false;


  @override
  void initState() {
    super.initState();
    loadCartItems();
    initDeepLinking();
  }

  Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<void> loadCartItems() async {
    final items = await _cartService.getCartItems();
    setState(() {
      cartItems = items;
    });
  }

  Future<void> updateCartItem(CartItem item, bool isAdd) async {
    if (isAdd) {
      await _cartService.addToCart(item);
    } else {
      await _cartService.removeFromCart(item.id);
    }
    await loadCartItems();
  }

  Future<void> removeFromCart(CartItem item) async {
    setState(() {
      cartItems.remove(item);
    });
    await _cartService.removeFromCart(item.id); // Remove item from SharedPreferences
    await loadCartItems(); // Reload cart items to reflect changes
  }

  Future<void> clearCart() async {
    setState(() {
      cartItems = [];
    });
    await _cartService.clearCart(); // Implement clearCart method in CartService
  }

  void initDeepLinking() async {
    _appLinks = AppLinks();
    _appLinksSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      if (uri.toString().contains('myapp://success')) {
        // Handle success
        clearCart();
        Navigator.of(context).pushNamed('/payment-success');
      } else if (uri.toString().contains('myapp://cancel')) {
        // Handle cancellation
        Navigator.of(context).pushNamed('/payment-cancel');
      }
    });
  }

  @override
  void dispose() {
    _appLinksSubscription.cancel();
    super.dispose();
  }

  Future<void> sendPaymentDataToServer(Map<String, dynamic> paymentDetails) async {
    try {
      var apiUrl = '${Config.apiUrl}/api/handle-payment-success';
      int? userId = await getUserId();
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'items': cartItems.map((item) => {
            'name': item.name,
            'quantity': item.quantity,
            'price': item.price,
          }).toList(),
          'totalAmount': paymentDetails['transactions'][0]['amount']['total'],
          'userID': userId,
          'paymentId': paymentDetails['id'], // Ensure paymentId is passed
          'orderAddress': 'dummy address', // Include order address if applicable
        }),
      );

      if (response.statusCode == 200) {
        print('Payment data sent to Laravel successfully');
        setState(() {
          paymentSuccessful = true;
        });
        await clearCart();
        Navigator.of(context).pushNamed('/payment-success');
      } else {
        print('Failed to send payment data to Laravel: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to complete order. Please try again later.')),
        );
      }
    } catch (e) {
      print('Error sending payment data to Laravel: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    if (paymentSuccessful) {

      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Navigator.of(context).pushNamed('/payment-success');
      });
    } else if(paymentFailed) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Navigator.of(context).pushNamed('/payment-failed');
      });
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
               const Text(
                  'Your Cart',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 300, // Adjust height as needed
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return CartItemCard(
                        title: item.name,
                        imageUrl: item.imageUrl,
                        subtitle: 'Quantity: ${item.quantity}',
                        totalPrice: item.price * item.quantity,
                        onAdd: () async {
                          setState(() {
                            item.quantity++;
                          });
                          await _cartService.addToCart(item);
                          await loadCartItems();
                        },
                        onTrash: () async {
                          await removeFromCart(item);
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                AddressSection(),
                SizedBox(height: 20),
                SummarySection(cartItems: cartItems),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFA726),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    double totalAmount = cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => UsePaypal(
                          sandboxMode: true,
                          clientId: "ARt6tfhmbkdQXHOizF2j_G3Sx-zaW3PzTs6Nx-iTDHLvQIEI2zMrR3-TeVRsoZvJ6OCUmUhEmt51c_WP",
                          secretKey: "EFRtQIZSlTrQZFiI8XQeALynhDMnoHAvbSgeI_FYDL-VVsURukKmRJaXedC4Ftxjw-LL7p036Iam9YFw",
                          returnURL: "myapp://success",
                          cancelURL: "myapp://cancel",
                          transactions: [
                            {
                              "amount": {
                                "total": totalAmount.toStringAsFixed(2),
                                "currency": "USD",
                                "details": {
                                  "subtotal": totalAmount.toStringAsFixed(2),
                                  "shipping": '0',
                                  "shipping_discount": 0
                                }
                              },
                              "description": "The payment transaction description.",
                              "item_list": {
                                "items": cartItems.map((item) {
                                  return {
                                    "name": item.name,
                                    "quantity": item.quantity.toString(),
                                    "price": item.price.toStringAsFixed(2),
                                    "currency": "USD"
                                  };
                                }).toList()
                              }
                            }
                          ],
                          note: "Contact us for any questions on your order.",
                          onSuccess: (Map<dynamic, dynamic> params) async {
                            setState(() {
                              paymentSuccessful = true;
                            });
                            await sendPaymentDataToServer(params.cast<String, dynamic>());
                          },

                          onError: (error) {
                            print("onError: $error");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Payment error: $error')),
                            );
                          },
                          onCancel: (params) {
                            print('cancelled: $params');
                            // Navigator.of(context).pushNamed('/payment-cancel');
                            setState(() {
                              paymentFailed = true;
                            });
                          },
                        ),
                      ),
                    );
                  },
                  // onPressed: createPaymentIntent,
                  child: Center(child: Text('Place Order')),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String subtitle;
  final double totalPrice;
  final VoidCallback onAdd;
  final VoidCallback onTrash;

  CartItemCard({
    required this.title,
    required this.imageUrl,
    required this.subtitle,
    required this.totalPrice,
    required this.onAdd,
    required this.onTrash,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 10),
          Image.network(
            imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    color: Colors.white,
                    // onPressed: onRemove,
                    onPressed: onTrash,
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    color: Colors.white,
                    onPressed: onAdd,
                  ),
                ],
              ),
            ],
          ),
          Spacer(),
          Text(
            '\RM${totalPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class AddressSection extends StatefulWidget {
  @override
  _AddressSectionState createState() => _AddressSectionState();
}

class _AddressSectionState extends State<AddressSection> {
  String orderType = 'dine_in'; // Default to pickup
  String orderAddress = '140 Roadway Ave.'; // Example default address
  String tableNumber = ''; // Variable to store table number for dine-in

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.location_on),
              SizedBox(width: 10),
              DropdownButton<String>(
                value: orderType,
                items: [
                  DropdownMenuItem(
                    value: 'pickup',
                    child: Text('Pickup'),
                  ),
                  DropdownMenuItem(
                    value: 'dine_in',
                    child: Text('Dine In'),
                  ),
                  DropdownMenuItem(
                    value: 'delivery',
                    child: Text('Delivery'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    orderType = value!;
                  });
                },
              ),
              Spacer(),
              // IconButton(
              //   icon: Icon(Icons.edit),
              //   onPressed: () {
              //     // Handle editing logic here
              //   },
              // ),
            ],
          ),
          if (orderType == 'delivery') ...[
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Delivery Address',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  orderAddress = value;
                });
              },
            ),
          ] else if (orderType == 'dine_in') ...[
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Table Number',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  tableNumber = value;
                });
              },
            ),
          ] else if (orderType == 'pickup') ...[
            SizedBox(height: 10),
            Text(
              'Pickup from store',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.timer),
              SizedBox(width: 10),
              Text('25-30 min (ASAP)'),
              Spacer(),
              // Icon(Icons.edit),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.attach_money),
              SizedBox(width: 10),
              Text('Bank Transfer'),
              Spacer(),
              // Icon(Icons.edit),
            ],
          ),
        ],
      ),
    );
  }
}

class SummarySection extends StatelessWidget {
  final List<CartItem> cartItems;

  SummarySection({required this.cartItems});

  double get totalAmount {
    double total = 0.0;
    for (var item in cartItems) {
      total += item.price * item.quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal'),
              Text('\RM${totalAmount.toStringAsFixed(2)}'),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delivery fee'),
              Text('\RM5.00'), // Example delivery fee
            ],
          ),
          SizedBox(height: 10),
          Divider(color: Colors.grey),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\RM${(totalAmount + 5.00).toStringAsFixed(2)}', // Subtotal + delivery fee
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
