// lib/screens/asset_category_detail_screen.dart
import 'package:asset_management/screen/asset_detail_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:asset_management/screen/models/asset.dart'; // Import the Asset model


class AssetCategoryDetailScreen extends StatefulWidget {
  final String categoryName;
  final List<Asset> assetsInCategory; // Changed to List<Asset> to pass full objects

  const AssetCategoryDetailScreen({
    Key? key,
    required this.categoryName,
    this.assetsInCategory = const [], // Default empty list
  }) : super(key: key);

  @override
  State<AssetCategoryDetailScreen> createState() => _AssetCategoryDetailScreenState();
}

class _AssetCategoryDetailScreenState extends State<AssetCategoryDetailScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Mock list of assets for the category to populate the ListView.
  // In a real app, this would be fetched based on categoryName.
  List<Asset> _mockAssetsForCategory = [];

  @override
  void initState() {
    super.initState();
    // Populate mock assets based on category for testing
    if (widget.assetsInCategory.isEmpty) {
      if (widget.categoryName == 'CCTV') {
        _mockAssetsForCategory = [
          Asset(
            id: '#001001',
            name: 'CCTV', // As per image
            category: 'Electronics',
            locationId: 'LOC001',
            locationInfo: 'Jl Pertiwi 12',
            latitude: -6.373706652012434,
            longitude: 106.807699530,
            personInCharge: 'Danny',
            phoneNumber: '081208120812',
            barcodeData: 'CCTV001-XYZ',
          ),
          Asset(
            id: '#001002',
            name: 'CCTV Unit 02',
            category: 'Electronics',
            locationId: 'LOC001',
            locationInfo: 'Jl Pertiwi 12',
            latitude: -6.373706652012434, // Same coord for simplicity
            longitude: 106.807699530,
            personInCharge: 'Danny',
            phoneNumber: '081208120812',
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
          ),
        ];
      } else {
        // Generic mock assets for other categories
        _mockAssetsForCategory = [
          Asset(
            id: '#GEN001',
            name: '${widget.categoryName} Item A',
            category: widget.categoryName,
            locationId: 'LOC002',
            locationInfo: 'Random Location',
            latitude: -6.2000,
            longitude: 106.8000,
            personInCharge: 'John Doe',
            phoneNumber: '081234567890',
          ),
          Asset(
            id: '#GEN002',
            name: '${widget.categoryName} Item B',
            category: widget.categoryName,
            locationId: 'LOC002',
            locationInfo: 'Random Location',
            latitude: -6.2000,
            longitude: 106.8000,
            personInCharge: 'Jane Doe',
            phoneNumber: '081234567890',
          ),
        ];
      }
    } else {
      _mockAssetsForCategory = widget.assetsInCategory; // Use passed assets if any
    }
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Asset> displayedAssets = _mockAssetsForCategory;

    // Apply search filtering (case-insensitive)
    if (_searchController.text.isNotEmpty) {
      displayedAssets = displayedAssets
          .where((asset) => asset.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: Colors.grey[100], // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: const Text(
          'Devices', // Title from image is "Devices"
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
                onChanged: (value) {
                  setState(() {
                    // Trigger rebuild to apply search filter
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: displayedAssets.isEmpty
                ? _buildEmptyState() // Show empty state if no assets after filtering
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: displayedAssets.length,
                    itemBuilder: (context, index) {
                      final asset = displayedAssets[index];
                      return _buildAssetListItem(
                        asset: asset, // Pass the full Asset object
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Helper widget for individual asset list items
  Widget _buildAssetListItem({
    required Asset asset, // Now receives an Asset object
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // You might want an icon specific to the asset type here
            // For now, using a general placeholder or leaving it out if image doesn't show one
            // const Icon(Icons.videocam, size: 40, color: Colors.grey), // Example for CCTV
            // const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.name, // Display asset's name
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Qty : 1', // Assuming 1 quantity per individual asset listed here
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to individual asset detail screen, passing the full asset object
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssetDetailViewScreen(
                      asset: asset, // Pass the specific asset being viewed
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

  // Helper for empty state if no assets found or after filtering
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/nodata.png', // Ensure this asset is in your pubspec.yaml
            width: 100,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}