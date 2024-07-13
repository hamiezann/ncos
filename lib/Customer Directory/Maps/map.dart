import 'package:flutter/material.dart';
import '../Order/orderHistory.dart';
import '../customer_home.dart';


class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Placeholder for the map
          Container(
            color: Colors.grey[300],
            child: Center(
              child: Text(
                'Map Placeholder',
                style: TextStyle(fontSize: 24, color: Colors.grey[700]),
              ),
            ),
          ),
          // Search bar
          Positioned(
            top: 50.0,
            left: 15.0,
            right: 15.0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Your location',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Icon(Icons.mic),
                ],
              ),
            ),
          ),
          // Map marker info
          Positioned(
            bottom: 100.0,
            left: 50.0,
            right: 50.0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_cafe, color: Colors.red),
                      SizedBox(width: 10),
                      Text(
                        'Map Location',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text('COFFEE SHOP'),
                  Text('19 min (3.1 mi)'),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CustomerHomePage()), // Navigate to CustomerHomePage
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrdersHistoryPage()), // Navigate to OrdersHistoryPage
              );
              break;
            case 3:
              Navigator.pushNamed(
                  context, '/profile'); // Navigate to profile page
              break;
          }
        },
      ),
    );
  }
}
