import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pharmacy.dart';
import '../config/api_config.dart';

class PharmacyService {
  final bool useSqlBackend;

  // ← Add this constructor (Fix A)
  PharmacyService({this.useSqlBackend = false});

  static final String baseUrl = ApiConfig.pharmacyEndpoint;

  Future<List<Pharmacy>> getAllPharmacies() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Pharmacy.fromJson(json)).toList();
      } else {
        // Log and fall back to sample data
        print(
            'Failed to load pharmacies from $baseUrl: ${response.statusCode}');
        return _samplePharmacies();
      }
    } catch (e) {
      // If the backend is unreachable (network error/CORS/etc) return
      // a local sample so the UI remains functional during development.
      print('Error fetching pharmacies: $e');
      return _samplePharmacies();
    }
  }

  List<Pharmacy> _samplePharmacies() {
    return [
      Pharmacy(
          id: 1,
          pharmacyName: 'Central Pharmacy',
          address: '123 Main St',
          phoneNumber: '555-0100'),
      Pharmacy(
          id: 2,
          pharmacyName: 'HealthPlus Pharmacy',
          address: '456 Elm St',
          phoneNumber: '555-0110'),
      Pharmacy(
          id: 3,
          pharmacyName: 'Neighborhood Pharmacy',
          address: '789 Oak Ave',
          phoneNumber: '555-0120'),
    ];
  }
}
