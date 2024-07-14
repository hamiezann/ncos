import 'package:flutter/material.dart';
import '../Maps/map.dart';
import '../Order/orderHistory.dart';
import '../customer_home.dart';

class MyProfilePage extends StatefulWidget {
  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  String name = "Jonathan Patterson";
  String userId = "U123456789";
  String email = "hello@reallygreatsite.com";
  String username = "jonathan.p";
  String phoneNumber = "123-456-7890";
  String address = "123 Main Street, Springfield, USA";

  void _editProfile(BuildContext context) async {
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage(
        name: name,
        email: email,
        username: username,
        phoneNumber: phoneNumber,
        address: address,
      )),
    );

    if (updatedData != null) {
      setState(() {
        name = updatedData['name'];
        email = updatedData['email'];
        username = updatedData['username'];
        phoneNumber = updatedData['phoneNumber'];
        address = updatedData['address'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _editProfile(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 50.0,
                    backgroundImage: AssetImage('assets/profile_picture.jpg'),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            ProfileDetail(
              icon: Icons.account_circle,
              title: 'User ID',
              detail: userId,
            ),
            ProfileDetail(
              icon: Icons.email,
              title: 'Email',
              detail: email,
            ),
            ProfileDetail(
              icon: Icons.person,
              title: 'Username',
              detail: username,
            ),
            ProfileDetail(
              icon: Icons.phone,
              title: 'Phone Number',
              detail: phoneNumber,
            ),
            ProfileDetail(
              icon: Icons.home,
              title: 'Address',
              detail: address,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.red,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(color: Colors.white),
        unselectedLabelStyle: TextStyle(color: Colors.grey),
        currentIndex: 3,
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
            label: 'History',
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OrdersHistoryPage()), // Navigate to OrdersHistoryPage
            );
              break;
            case 3:
             // Navigator.pushReplacementNamed(context, '/profile'); // Navigate to profile page
              break;
          }
        },
      ),
    );
  }
}

class ProfileDetail extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;

  ProfileDetail({
    required this.icon,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Icon(icon, color: Colors.orange, size: 40.0),
          SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 4.0),
              Text(
                detail,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final String username;
  final String phoneNumber;
  final String address;

  EditProfilePage({
    required this.name,
    required this.email,
    required this.username,
    required this.phoneNumber,
    required this.address,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late String editedName;
  late String editedEmail;
  late String editedUsername;
  late String editedPhoneNumber;
  late String editedAddress;

  @override
  void initState() {
    super.initState();
    editedName = widget.name;
    editedEmail = widget.email;
    editedUsername = widget.username;
    editedPhoneNumber = widget.phoneNumber;
    editedAddress = widget.address;
  }

  void _updateProfile(BuildContext context) {
    // Prepare updated data to pass back
    Map<String, String> updatedData = {
      'name': editedName,
      'email': editedEmail,
      'username': editedUsername,
      'phoneNumber': editedPhoneNumber,
      'address': editedAddress,
    };

    Navigator.pop(context, updatedData); // Return updated data to MyProfilePage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Edit Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () => _updateProfile(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 50.0,
                    backgroundImage: AssetImage('assets/profile_picture.jpg'),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    editedName,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            EditableProfileDetail(
              icon: Icons.email,
              title: 'Email',
              initialValue: editedEmail,
              onChanged: (value) {
                setState(() {
                  editedEmail = value;
                });
              },
            ),
            EditableProfileDetail(
              icon: Icons.person,
              title: 'Username',
              initialValue: editedUsername,
              onChanged: (value) {
                setState(() {
                  editedUsername = value;
                });
              },
            ),
            EditableProfileDetail(
              icon: Icons.phone,
              title: 'Phone Number',
              initialValue: editedPhoneNumber,
              onChanged: (value) {
                setState(() {
                  editedPhoneNumber = value;
                });
              },
            ),
            EditableProfileDetail(
              icon: Icons.home,
              title: 'Address',
              initialValue: editedAddress,
              onChanged: (value) {
                setState(() {
                  editedAddress = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EditableProfileDetail extends StatelessWidget {
  final IconData icon;
  final String title;
  final String initialValue;
  final ValueChanged<String> onChanged;

  EditableProfileDetail({
    required this.icon,
    required this.title,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Icon(icon, color: Colors.orange, size: 40.0),
          SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 4.0),
                TextFormField(
                  initialValue: initialValue,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: 'Enter $title',
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
