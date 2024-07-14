import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart';
import 'package:ncos/Customer%20Directory/Order/orderHistory.dart';
import 'package:ncos/Customer%20Directory/customer_home.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  LatLng _initialPosition = LatLng(4.2105, 101.9758); // Initial position in Malaysia
  LatLng _cafePosition = LatLng(2.1896, 102.2501); // Cafe position at Menara Taming Sari
  Position? _currentPosition;
  String _currentAddress = 'Your location';
  String _distance = 'Calculating...';
  String _duration = 'Calculating...';

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndGetLocation();
  }

  void _checkPermissionsAndGetLocation() async {
    if (await Permission.location.isGranted) {
      _getCurrentLocation();
    } else {
      if (await Permission.location.request().isGranted) {
        _getCurrentLocation();
      } else {
        // Handle permission denied
        print('Location permission denied');
      }
    }
  }

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
      _initialPosition = LatLng(position.latitude, position.longitude);
      _getAddressFromLatLng(position);
      _calculateDistanceAndDuration();
    });
  }

  void _getAddressFromLatLng(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    setState(() {
      _currentAddress = '${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}';
    });
  }

  void _calculateDistanceAndDuration() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey:'AIzaSyCfx_bqDvUZLVoKkYtrsoC_QIoSU1q64QY', // Replace with your API Key
      request: PolylineRequest(
          origin: PointLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          destination:  PointLatLng(_cafePosition.latitude, _cafePosition.longitude),
          mode:  TravelMode.driving,),
    );

    if (result.points.isNotEmpty) {
      double totalDistance = 0.0;
      Duration totalDuration = Duration();

      for (int i = 0; i < result.points.length - 1; i++) {
        totalDistance += Geolocator.distanceBetween(
          result.points[i].latitude,
          result.points[i].longitude,
          result.points[i + 1].latitude,
          result.points[i + 1].longitude,
        );

        // Assuming average speed of 50 km/h for duration calculation
        totalDuration += Duration(seconds: (Geolocator.distanceBetween(
          result.points[i].latitude,
          result.points[i].longitude,
          result.points[i + 1].latitude,
          result.points[i + 1].longitude,
        ) / 13.8889).round());
      }

      setState(() {
        _distance = (totalDistance / 1000).toStringAsFixed(2) + ' km';
        _duration = (totalDuration.inMinutes).toString() + ' min';
      });
    }
  }

  void _launchMapsUrl(double lat, double lon) async {
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lon');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            markers: {
              Marker(
                markerId: MarkerId('cafe'),
                position: _cafePosition,
                infoWindow: InfoWindow(
                  title: 'NASH d CAFE',
                  snippet: '$_duration ($_distance)',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              ),
            },
            myLocationEnabled: true,
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
                        hintText: _currentAddress,
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
            child: GestureDetector(
              onTap: () => _launchMapsUrl(_cafePosition.latitude, _cafePosition.longitude),
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
                          'Map Distance From You',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text('NASH d CAFE'),
                    Text('$_duration ($_distance)'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.red,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(color: Colors.white),
        unselectedLabelStyle: TextStyle(color: Colors.grey),
        currentIndex: 1,
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
            // Stay on MapScreen, no action needed for this index
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => OrdersHistoryPage()), // Navigate to OrdersHistoryPage
              );
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profile'); // Navigate to profile page
              break;
          }
        },

      ),
    );
  }
}
