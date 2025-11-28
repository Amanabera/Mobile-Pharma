import 'package:flutter/material.dart';
// UI for exploring medicines
import '../models/stock.dart';
import '../services/stock_service.dart';

class ExploreMedicineScreen extends StatefulWidget {
  const ExploreMedicineScreen({super.key});

  @override
  State<ExploreMedicineScreen> createState() => _ExploreMedicineScreenState();
}

class _ExploreMedicineScreenState extends State<ExploreMedicineScreen> {
  final StockService _stockService = StockService();
  final TextEditingController _searchController = TextEditingController();
  RangeValues _priceRange = const RangeValues(0, 100);
  double _minPrice = 0.0;
  double _maxPrice = 100.0;
  
  List<Stock> _medicines = [];
  List<Stock> _filteredMedicines = [];
  List<String> _categories = [];
  String _selectedCategory = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
    _searchController.addListener(_filterMedicines);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicines() async {
    setState(() => _isLoading = true);
    try {
      final medicines = await _stockService.getAllStocksPublic();
      final prices = medicines.map((m) => m.price).toList();
      final min = prices.isEmpty ? 0.0 : prices.reduce((a, b) => a < b ? a : b);
      final max = prices.isEmpty ? 100.0 : prices.reduce((a, b) => a > b ? a : b);
      setState(() {
        _medicines = medicines;
        _categories = medicines.map((m) => m.category).toSet().toList();
        _filteredMedicines = medicines;
        _minPrice = min;
        _maxPrice = max;
        _priceRange = RangeValues(min, max);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading medicines: $e')),
        );
      }
    }
  }

  void _filterMedicines() {
    final searchTerm = _searchController.text.toLowerCase();
    final minPrice = _priceRange.start;
    final maxPrice = _priceRange.end;

    setState(() {
      _filteredMedicines = _medicines.where((med) {
        final matchesSearch = med.product.toLowerCase().contains(searchTerm);
        final matchesCategory = _selectedCategory.isEmpty || med.category == _selectedCategory;
        final matchesMinPrice = med.price >= minPrice;
        final matchesMaxPrice = med.price <= maxPrice;

        return matchesSearch && matchesCategory && matchesMinPrice && matchesMaxPrice;
      }).toList();
    });
  }

  void _showDetails(Stock medicine) {
    showDialog(
      context: context,
      builder: (context) => _buildDetailDialog(medicine),
    );
  }

  Widget _buildDetailDialog(Stock medicine) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      medicine.product,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1f8c4d)),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.medication, size: 56, color: Color(0xFF1f8c4d)),
                ),
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Category', medicine.category),
              _buildDetailRow('Pharmacy', medicine.userName),
              _buildDetailRow('Quantity', medicine.quantity.toString()),
              _buildDetailRow('Price', '\$${medicine.price.toStringAsFixed(2)}'),
              _buildDetailRow('Added On', _formatDate(medicine.createdAt)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], foregroundColor: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Simple contact action
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Contact ${medicine.userName}')));
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Contact'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1f8c4d)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Explore Medicines',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1f8c4d),
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search medicines...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1f8c4d),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Filters
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1f8c4d),
                        ),
                      ),
                      const SizedBox(height: 5),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory.isEmpty ? null : _selectedCategory,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        hint: const Text('All'),
                        items: [
                          const DropdownMenuItem<String>(
                            value: '',
                            child: Text('All'),
                          ),
                          ..._categories.map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value ?? '';
                            _filterMedicines();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                const SizedBox(width: 15),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Price Range',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1f8c4d),
                        ),
                      ),
                      const SizedBox(height: 8),
                      RangeSlider(
                        values: _priceRange,
                        min: _minPrice,
                        max: _maxPrice,
                        divisions: 20,
                        labels: RangeLabels(
                          '\$${_priceRange.start.toStringAsFixed(2)}',
                          '\$${_priceRange.end.toStringAsFixed(2)}',
                        ),
                        onChanged: (values) {
                          setState(() {
                            _priceRange = values;
                          });
                          _filterMedicines();
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('\$${_priceRange.start.toStringAsFixed(0)}'),
                          Text('\$${_priceRange.end.toStringAsFixed(0)}'),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Cards Grid
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredMedicines.isEmpty
                      ? const Center(
                          child: Text(
                            'No medicines found',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _filteredMedicines.length,
                          itemBuilder: (context, index) {
                            final medicine = _filteredMedicines[index];
                            return _buildMedicineCard(medicine);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineCard(Stock medicine) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showDetails(medicine),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: const Icon(
                  Icons.medication,
                  size: 60,
                  color: Color(0xFF1f8c4d),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      medicine.product,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1f8c4d),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Category: ${medicine.category}',
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pharmacy: ${medicine.userName}',
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty: ${medicine.quantity}',
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${medicine.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1f8c4d),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: ElevatedButton(
                onPressed: () => _showDetails(medicine),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1f8c4d),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'More Info',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

