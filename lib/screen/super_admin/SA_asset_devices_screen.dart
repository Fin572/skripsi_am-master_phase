// lib/screens/asset_devices_screen.dart
import 'package:asset_management/screen/add_device_screen.dart';
import 'package:asset_management/screen/asset_category_detail_screen.dart';
import 'package:asset_management/screen/super_admin/SA_asset_category_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:asset_management/widgets/company_info_card.dart';
import 'package:asset_management/screen/models/asset.dart'; // Import the Asset model

class SAAssetDevicesScreen extends StatefulWidget {
  final bool showSuccessPopup;
  final Asset asset; // This needs to be correctly initialized or made optional.

  const SAAssetDevicesScreen({Key? key, this.showSuccessPopup = false, required this.asset}) : super(key: key);

  @override
  State<SAAssetDevicesScreen> createState() => _SAAssetDevicesScreenState();
}

class _SAAssetDevicesScreenState extends State<SAAssetDevicesScreen> {
  bool _showSuccessPopup = false;

  // This list will contain your asset categories, now mapped to a structure
  // that can generate Asset objects for the next screen.
  final List<Map<String, dynamic>> _assetCategoryData = [
    {
      'categoryName': 'CCTV',
      'deviceCount': '4',
      'assets': [ // Actual Asset objects for CCTV category
        Asset(
          id: '#001001',
          name: 'CCTV',
          category: 'Electronics',
          locationId: 'LOC001',
          locationInfo: 'Jl Pertiwi 12',
          latitude: -6.373706652012434,
          longitude: 106.807699530,
          personInCharge: 'Danny',
          phoneNumber: '081208120812',
          barcodeData: 'BC001',
        ),
        Asset(
          id: '#001002',
          name: 'CCTV Unit 02',
          category: 'Electronics',
          locationId: 'LOC001',
          locationInfo: 'Jl Pertiwi 12',
          latitude: -6.373706652012434,
          longitude: 106.807699530,
          personInCharge: 'Danny',
          phoneNumber: '081208120812',
          barcodeData: 'BC002',
        ),
        Asset(
          id: '#001003',
          name: 'CCTV Unit 03',
          category: 'Electronics',
          locationId: 'LOC001',
          locationInfo: 'Jl Pertiwi 12',
          latitude: -6.373706652012434,
          longitude: 106.807699530,
          personInCharge: 'Danny',
          phoneNumber: '081208120812',
          barcodeData: 'BC003',
        ),
        Asset(
          id: '#001004',
          name: 'CCTV Unit 04',
          category: 'Electronics',
          locationId: 'LOC001',
          locationInfo: 'Jl Pertiwi 12',
          latitude: -6.373706652012434,
          longitude: 106.807699530,
          personInCharge: 'Danny',
          phoneNumber: '081208120812',
          barcodeData: 'BC004',
        ),
      ]
    },
    {
      'categoryName': 'Electronics',
      'deviceCount': '2', // Example, changed from 4 to differentiate
      'assets': [
        Asset(
          id: '#ELC001',
          name: 'Laptop X',
          category: 'Electronics',
          locationId: 'LOC002',
          locationInfo: 'Gudang Barat',
          latitude: -6.2000,
          longitude: 106.8000,
          personInCharge: 'Budi',
          phoneNumber: '081122334455',
          barcodeData: 'BC005',
        ),
        Asset(
          id: '#ELC002',
          name: 'Projector Y',
          category: 'Electronics',
          locationId: 'LOC002',
          locationInfo: 'Gudang Barat',
          latitude: -6.2000,
          longitude: 106.8000,
          personInCharge: 'Budi',
          phoneNumber: '081122334455',
          barcodeData: 'BC006',
        ),
      ]
    },
    // Add more categories with their specific assets if needed
  ];

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(243,245,247,247),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(95.0), // Height similar to your example
        child: Stack(
          children: [
            // Background image for the AppBar
            Image.asset(
              'assets/bg_image.png', // Ensure this path is correct
              height: 95,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            // Content of the AppBar (back button and title)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Devices',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: const CompanyInfoCard(
                  ticketNumber: '#000001',
                  companyName: 'PT Dunia Persada',
                  deviceCount: '6 Assets', // Updated to match dummy data sum
                ),
              ),
              Expanded(
                child: _assetCategoryData.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: _assetCategoryData.length,
                        itemBuilder: (context, index) {
                          final category = _assetCategoryData[index];
                          return _buildAssetCategoryCard(
                            categoryName: category['categoryName']!,
                            deviceCount: category['deviceCount']!,
                            assetsInCategory: category['assets'] as List<Asset>, // Pass the actual list of assets
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCategoryCard({
    required String categoryName,
    required String deviceCount,
    required List<Asset> assetsInCategory, // Now accepts List<Asset>
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white, 
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.laptop_mac, size: 40, color: Colors.grey),
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
                // Navigate to AssetCategoryDetailScreen, passing the actual assets
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SAAssetCategoryDetailScreen(
                      categoryName: categoryName,
                      assetsInCategory: assetsInCategory, // Pass the actual list of Asset objects
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