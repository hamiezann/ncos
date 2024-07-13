import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncos/Customer%20Directory/Payment/failedPayment.dart';
import 'package:ncos/Customer%20Directory/Payment/successPayment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'Admin DIrectory/Category/addCategory.dart';
import 'Admin DIrectory/Category/editCategory.dart';
import 'Admin DIrectory/Product/addProduct.dart';
import 'Admin DIrectory/Product/productList.dart';
import 'Admin DIrectory/Rating/ratingList.dart';
import 'Admin DIrectory/admin_home.dart';
import 'Authentication Directory/login.dart';
import 'Authentication Directory/register.dart';
import 'Customer Directory/Cart/cartPage.dart';
import 'Customer Directory/Maps/map.dart';
import 'Customer Directory/Menu/menuList.dart';
import 'Customer Directory/Order/orderHistory.dart';
import 'Customer Directory/Profile/profile.dart';
import 'Customer Directory/customer_home.dart';
import 'Splash Screen/splashScreen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  bool isAdmin = prefs.getString('role') == 'admin';
// Define a GlobalKey for navigation


  String initialRoute = isLoggedIn ? (isAdmin ? '/admin-home' : '/customer-home') : '/splashscreen';


  runApp(MyApp(initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  MyApp(this.initialRoute, {Key? key}) : super(key: key);
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    MaterialColor primarySwatchWhite = const MaterialColor(
      0xFFFFFFFF, // 0xFFFFFFFF is white, you can adjust shades as needed
      <int, Color>{
        50: Color(0xFFFAFAFA), // Very light shade
        100: Color(0xFFF5F5F5),
        200: Color(0xFFEEEEEE),
        300: Color(0xFFE0E0E0),
        400: Color(0xFFBDBDBD),
        500: Colors.white, // Normal white
        600: Color(0xFF757575),
        700: Color(0xFF616161),
        800: Color(0xFF424242),
        900: Color(0xFF212121), // Very dark shade
      },
    );
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Nash Cafe Mobile App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: primarySwatchWhite,

        ),
        useMaterial3: true,
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      initialRoute: initialRoute,
      routes: {
        //Authentication Route
        '/splashscreen': (context) => HomePage(),
        '/register': (context) => RegisterScreen(),
        '/login': (context) => LoginPage(),

        // //Admin Route
        '/admin-home': (context) => AdminHomePage(),
        '/admin-rating-list' : (context) => AdminRatingListPage(),
        '/admin-product-list' : (context) => AdminMenuList(),
        '/admin-create-product' : (context) => CreateProductPage(),
        '/admin-create-category' : (context) => AddCategoryPage(),
        // '/admin-edit-category' : (context) => EditCategoryPage(),
        //
        // //Customer Route
        '/customer-home': (context) => CustomerHomePage(),
        '/map': (context) => MapScreen(),
        '/order-history': (context) => OrdersHistoryPage(),
        '/profile': (context) => MyProfilePage(),
        'cart': (context) => CartPage(),
        '/payment-success': (context) => PaymentSuccessPage(),
        '/payment-cancel': (context) => PaymentFailedPage(),
        // '/orderDetails': (context) => OrderDetailsPage(order: order),
        // '/menu': (context) => MenuPage(),
      },
    );
  }
}
