import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ncos/Customer%20Directory/Order/OrderListClass.dart';
import 'package:ncos/Network%20Configuration/networkConfig.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrdersHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey,
          title: Text('Orders', style: TextStyle(color: Colors.white),),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Past Orders'),
              Tab(text: 'Upcoming Orders'),
            ],
          ),
        ),
        body: FutureBuilder<int>(
          future: getUserIdFromPrefs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final userId = snapshot.data!;
            return TabBarView(
              children: [
                OrdersList(orderType: 'Past', userId: userId),
                OrdersList(orderType: 'Upcoming', userId: userId),
              ],
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.red,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(color: Colors.white),
          unselectedLabelStyle: TextStyle(color: Colors.grey),
          currentIndex: 2,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: 'Location',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          onTap: (int index) {
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/customer-home'); // Navigate to CustomerHomePage
                break;
              case 1:
              Navigator.pushReplacementNamed(context, '/map');
                break;
              case 2:
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (context) => OrdersHistoryPage()), // Navigate to OrdersHistoryPage
                // );
                break;
              case 3:
                Navigator.pushReplacementNamed(context, '/profile'); // Navigate to profile page
                break;
            }
          },

        ),
      ),
    );
  }

  Future<int> getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId') ?? 0; // Replace with a default value if 'userId' is not found
  }
}
