// lib/screens/super_admin/SA_asset_category_detail_screen.dart

import 'package:asset_management/screen/super_admin/SA_asset_detail_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:asset_management/screen/models/asset.dart'; 

class SAAssetCategoryDetailScreen extends StatefulWidget {
  final String categoryName;
  final List<Asset> assetsInCategory; 

  const SAAssetCategoryDetailScreen({
    Key? key,
    required this.categoryName,
    this.assetsInCategory = const [],
  }) : super(key: key);

  @override
  State<SAAssetCategoryDetailScreen> createState() => _SAAssetCategoryDetailScreenState();
}

class _SAAssetCategoryDetailScreenState extends State<SAAssetCategoryDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isEditing = false; 
  Set<String> _selectedAssetIds = {}; 

  
  List<Asset> _mockAssetsForCategory = [];

  @override
  void initState() {
    super.initState();
    if (widget.assetsInCategory.isEmpty) {
      if (widget.categoryName == 'CCTV') {
        _mockAssetsForCategory = [
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
            barcodeData: 'CCTV001-XYZ',
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
        ];
      } else {
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
      _mockAssetsForCategory = List.from(widget.assetsInCategory); 
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _selectedAssetIds.clear(); 
      }
    });
  }

  void _toggleSelectAsset(String assetId) {
    setState(() {
      if (_selectedAssetIds.contains(assetId)) {
        _selectedAssetIds.remove(assetId);
      } else {
        _selectedAssetIds.add(assetId);
      }
    });
  }

  void _confirmAndDeleteAssets() async {
    if (_selectedAssetIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No assets selected for deletion.')),
      );
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete ${_selectedAssetIds.length} selected asset(s)?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); 
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); 
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _mockAssetsForCategory.removeWhere((asset) => _selectedAssetIds.contains(asset.id));
        _selectedAssetIds.clear();
        if (_mockAssetsForCategory.isEmpty) { 
          _isEditing = false;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected asset(s) deleted.'),backgroundColor: Colors.red,),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Asset> displayedAssets = _mockAssetsForCategory;

    if (_searchController.text.isNotEmpty) {
      displayedAssets = displayedAssets
          .where((asset) => asset.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(95.0), 
        child: Stack(
          children: [
            Image.asset(
              'assets/bg_image.png', 
              height: 95,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
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
                    Text(
                      widget.categoryName, 
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(), 
                    if (_isEditing && _selectedAssetIds.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: _confirmAndDeleteAssets,
                      ),
                    IconButton(
                      icon: Icon(_isEditing ? Icons.done_all : Icons.edit, color: Colors.white),
                      onPressed: _toggleEditMode,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: displayedAssets.isEmpty
                ? _buildEmptyState() 
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: displayedAssets.length,
                    itemBuilder: (context, index) {
                      final asset = displayedAssets[index];
                      final isSelected = _selectedAssetIds.contains(asset.id);
                      return GestureDetector(
                        onLongPress: () {
                          if (!_isEditing) {
                            _toggleEditMode();
                          }
                          _toggleSelectAsset(asset.id);
                        },
                        onTap: () {
                          if (_isEditing) {
                            _toggleSelectAsset(asset.id);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SAAssetDetailViewScreen(
                                  asset: asset,
                                ),
                              ),
                            );
                          }
                        },
                        child: Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: _isEditing && isSelected
                                ? const BorderSide(color: Colors.blue, width: 2.0)
                                : BorderSide.none,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                if (_isEditing)
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (bool? value) {
                                      _toggleSelectAsset(asset.id);
                                    },
                                  ),
                          
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
                                      const Text(
                                        'Qty : 1', 
                                        style: TextStyle(fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!_isEditing)
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SAAssetDetailViewScreen(
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
                        ),
                      );
                    },
                  ),
          ),
        ],
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