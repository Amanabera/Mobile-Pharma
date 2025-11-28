import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/pharmacy.dart';
import '../services/pharmacy_service.dart';

class PharmaListScreen extends StatefulWidget {
  const PharmaListScreen({super.key});

  @override
  State<PharmaListScreen> createState() => _PharmaListScreenState();
}

class _PharmaListScreenState extends State<PharmaListScreen> {
  final PharmacyService _pharmacyService = PharmacyService();
  final TextEditingController _searchController = TextEditingController();
  final List<Pharmacy> _pharmacies = [];
  final List<Pharmacy> _filteredPharmacies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPharmacies();
    _searchController.addListener(_filterPharmacies);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPharmacies() async {
    setState(() => _isLoading = true);
    try {
      final pharmacies = await _pharmacyService.getAllPharmacies();
      _pharmacies
        ..clear()
        ..addAll(pharmacies);
      _filterPharmacies();
    } catch (e, st) {
      if (kDebugMode) {
        print('Error loading pharmacies: $e\n$st');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterPharmacies() {
    final q = _searchController.text.toLowerCase().trim();
    _filteredPharmacies
      ..clear()
      ..addAll(_pharmacies.where((p) {
        if (q.isEmpty) return true;
        return p.pharmacyName.toLowerCase().contains(q) ||
            p.address.toLowerCase().contains(q) ||
            p.phoneNumber.toLowerCase().contains(q);
      }));
    setState(() {});
  }

  void _showDetails(Pharmacy pharmacy) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pharmacy.pharmacyName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (pharmacy.phoneNumber.isNotEmpty)
                Text('Phone: ${pharmacy.phoneNumber}'),
              if (pharmacy.address.isNotEmpty)
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Address: ${pharmacy.address}')),
              if ((pharmacy.email ?? '').isNotEmpty)
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Email: ${pharmacy.email}')),
              if ((pharmacy.description ?? '').isNotEmpty)
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('${pharmacy.description}')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 18),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Available Pharmacies',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1f8c4d)),
              ),
              SizedBox(height: 4),
              Text('Find nearby pharmacies and view details',
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360, minWidth: 120),
          child: SizedBox(
            width: 280,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search pharmacies...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF1f8c4d), width: 2)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_filteredPharmacies.isEmpty)
      return const Center(
          child: Text('No pharmacies found',
              style: TextStyle(fontSize: 16, color: Colors.grey)));

    return RefreshIndicator(
      onRefresh: _loadPharmacies,
      child: LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount = 1;
        if (width > 1000)
          crossAxisCount = 3;
        else if (width > 640) crossAxisCount = 2;

        return GridView.builder(
          padding: const EdgeInsets.only(top: 10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.8,
          ),
          itemCount: _filteredPharmacies.length,
          itemBuilder: (context, index) =>
              _buildPharmacyCard(_filteredPharmacies[index]),
        );
      }),
    );
  }

  Widget _buildPharmacyCard(Pharmacy pharmacy) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDetails(pharmacy),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12))),
              child: const Center(
                  child: Icon(Icons.local_pharmacy,
                      size: 56, color: Color(0xFF1f8c4d))),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(pharmacy.pharmacyName,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1f8c4d)),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text(pharmacy.phoneNumber,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87)),
                    const SizedBox(height: 6),
                    Text(pharmacy.address,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () => _showDetails(pharmacy),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1f8c4d)),
                          child: const Text('More Info')),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
