// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// class PayPalReturnPage extends StatefulWidget {
//   final String initialUrl;
//
//   PayPalReturnPage({required this.initialUrl});
//
//   @override
//   _PayPalReturnPageState createState() => _PayPalReturnPageState();
// }
//
// class _PayPalReturnPageState extends State<PayPalReturnPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Processing Payment'),
//       ),
//       body: WebViewWidget(
//         initialUrl: widget.initialUrl,
//         javascriptMode: JavascriptMode.unrestricted,
//         onPageFinished: (String url) {
//           if (url.contains('payment-successful')) {
//             Navigator.pushReplacementNamed(context, '/payment-successful');
//           } else if (url.contains('payment-failed')) {
//             Navigator.pushReplacementNamed(context, '/payment-failed');
//           }
//         },
//       ),
//     );
//   }
// }
