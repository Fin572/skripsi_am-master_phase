// lib/screens/asset_category_detail_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:asset_management/screen/asset_detail_view_screen.dart';
import 'package:asset_management/screen/models/asset.dart';

class AssetCategoryDetailScreen extends StatefulWidget {
  final String categoryName;

  const AssetCategoryDetailScreen({
    Key? key,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<AssetCategoryDetailScreen> createState() => _AssetCategoryDetailScreenState();
}

class _AssetCategoryDetailScreenState extends State<AssetCategoryDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Asset> _devices = [];
  List<Asset> _filteredDevices = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDevices();
    _searchController.addListener(_filterDevices);
  }

  Future<void> _fetchDevices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(
          'http://192.168.1.9/Skripsi/get_asset.php?action=get_devices_by_category&category=${Uri.encodeComponent(widget.categoryName)}'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _devices = data.map((item) => Asset(
            id: item['id'],
            name: item['name'],
            category: item['category'],
            locationId: item['locationId'],
            locationInfo: item['locationInfo'],
            latitude: (item['latitude'] as num).toDouble(), // Convert to double
            longitude: (item['longitude'] as num).toDouble(), // Convert to double
            personInCharge: item['personInCharge'],
            phoneNumber: item['phoneNumber'],
            barcodeData: item['barcodeData'],
          )).toList();
          _filteredDevices = _devices;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load devices: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _filterDevices() {
    setState(() {
      _filteredDevices = _devices
          .where((asset) => asset.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterDevices);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Devices',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage))
                    : _filteredDevices.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: _filteredDevices.length,
                            itemBuilder: (context, index) {
                              final asset = _filteredDevices[index];
                              return _buildAssetListItem(asset: asset);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetListItem({
    required Asset asset,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Qty : 1',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssetDetailViewScreen(
                      asset: asset,
                    ),
                  ),
                );
              },
              child: const Row(
                children: [
                  Text('Detail', style: TextStyle(color: Colors.blue)),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/nodata.png',
            width: 100,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}