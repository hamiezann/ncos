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
          title: Text('Orders'),
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
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: 'Map',
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
                Navigator.pushNamed(context, '/home');
                break;
              case 1:
                Navigator.pushNamed(context, '/map');
                break;
              case 2:
                Navigator.pushNamed(context, '/orders');
                break;
              case 3:
                Navigator.pushNamed(context, '/profile');
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
