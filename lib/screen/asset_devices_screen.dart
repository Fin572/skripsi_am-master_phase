// lib/screens/asset_devices_screen.dart
import 'package:asset_management/screen/asset_category_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:asset_management/widgets/company_info_card.dart';
import 'package:asset_management/screen/models/asset.dart'; // Import the Asset model

class AssetDevicesScreen extends StatefulWidget {
  final bool showSuccessPopup;

  const AssetDevicesScreen({Key? key, this.showSuccessPopup = false}) : super(key: key);

  @override
  State<AssetDevicesScreen> createState() => _AssetDevicesScreenState();
}

class _AssetDevicesScreenState extends State<AssetDevicesScreen> {
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
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      print('Add device button pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
    required List<Asset> assetsInCategory, // Now accepts List<Asset>
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                    builder: (context) => AssetCategoryDetailScreen(
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