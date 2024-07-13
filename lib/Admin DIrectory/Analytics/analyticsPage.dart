import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../Network Configuration/networkConfig.dart';

class AnalyticService {

  static Future<String> fetchTotalSales() async {
    final response = await http.get(Uri.parse('${Config.apiUrl}/analytics/total-sales'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['total_sales'].toString();
    } else {
      throw Exception('Failed to load total sales');
    }
  }

  static Future<double> fetchTotalProfit() async {
    final response = await http.get(Uri.parse('${Config.apiUrl}/analytics/total-profit'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['total_profit'];
    } else {
      throw Exception('Failed to load total profit');
    }
  }


  static Future<List<Map<String, dynamic>>> fetchBestSellingProducts() async {
    final response = await http.get(Uri.parse('${Config.apiUrl}/analytics/best-selling-products'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonData['best_selling_products']);
    } else {
      throw Exception('Failed to load best selling products');
    }
  }
}
