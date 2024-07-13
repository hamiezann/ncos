import 'package:flutter/material.dart';

class PaymentFailedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Failed'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.cancel_outlined,
              color: Colors.red,
              size: 100,
            ),
            SizedBox(height: 20),
            Text(
              'Your payment was not successful.',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to another screen, or close the failed screen
                Navigator.pop(context);
              },
              child: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
