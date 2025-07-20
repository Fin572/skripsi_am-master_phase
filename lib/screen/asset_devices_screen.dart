// lib/screens/asset_devices_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:asset_management/screen/add_device_screen.dart';
import 'package:asset_management/screen/asset_category_detail_screen.dart';
import 'package:asset_management/widgets/company_info_card.dart';
import 'package:asset_management/screen/models/asset.dart';

class AssetDevicesScreen extends StatefulWidget {
  final bool showSuccessPopup;

  const AssetDevicesScreen({Key? key, required this.showSuccessPopup})
      : super(key: key);

  @override
  State<AssetDevicesScreen> createState() => _AssetDevicesScreenState();
}

class _AssetDevicesScreenState extends State<AssetDevicesScreen> {
  bool _showSuccessPopup = false;
  List<Map<String, dynamic>> _assetCategoryData = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    if (widget.showSuccessPopup) {
      _showSuccessPopup = true;
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showSuccessPopup = false;
          });
        }
      });
    }
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse('http://assetin.my.id/skripsi/get_asset.php?action=get_categories'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _assetCategoryData = data.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load categories: ${response.statusCode}';
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
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CompanyInfoCard(
                  ticketNumber: '#000001',
                  companyName: 'PT Dunia Persada',
                  deviceCount: _isLoading
                      ? 'Loading...'
                      : '${_assetCategoryData.fold<int>(0, (sum, category) => sum + int.parse(category['deviceCount'] ?? '0'))} Assets',
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                        ? Center(child: Text(_errorMessage))
                        : _assetCategoryData.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                itemCount: _assetCategoryData.length,
                                itemBuilder: (context, index) {
                                  final category = _assetCategoryData[index];
                                  return _buildAssetCategoryCard(
                                    categoryName: category['categoryName']!,
                                    deviceCount: category['deviceCount']!,
                                  );
                                },
                              ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const AddDeviceScreen(availableLocations: [])),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      'Add device',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_showSuccessPopup)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.green,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: const SafeArea(
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Success! Device has been added',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAssetCategoryCard({
    required String categoryName,
    required String deviceCount,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.devices, size: 40, color: Colors.grey),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Qty : $deviceCount',
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
                    builder: (context) => AssetCategoryDetailScreen(
                      categoryName: categoryName,
                    ),
                  ),
                );
              },
              child: const Row(
                children: [
                  Text('Detail', style: TextStyle(color: Colors.blue)),
                  Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.blue),
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