import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock.dart';
import '../config/api_config.dart';

class StockService {
  static final String baseUrl = ApiConfig.stockEndpoint;

  Future<List<Stock>> getAllStocksPublic() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/all'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Stock.fromJson(json)).toList();
      } else {
        print(
            'Failed to load medicines from $baseUrl/all: ${response.statusCode}');
        return _sampleStocks();
      }
    } catch (e) {
      print('Error fetching medicines: $e');
      return _sampleStocks();
    }
  }

  List<Stock> _sampleStocks() {
    return [
      Stock(
          id: 1,
          product: 'Paracetamol 500mg',
          category: 'Painkiller',
          quantity: 50,
          price: 2.5,
          userId: 1,
          userName: 'Central Pharmacy',
          createdAt: DateTime.now().toIso8601String()),
      Stock(
          id: 2,
          product: 'Cough Syrup',
          category: 'Cold & Flu',
          quantity: 20,
          price: 5.0,
          userId: 2,
          userName: 'HealthPlus Pharmacy',
          createdAt: DateTime.now().toIso8601String()),
      Stock(
          id: 3,
          product: 'Antibiotic Capsule',
          category: 'Antibiotics',
          quantity: 10,
          price: 12.0,
          userId: 3,
          userName: 'Neighborhood Pharmacy',
          createdAt: DateTime.now().toIso8601String()),
    ];
  }
}
