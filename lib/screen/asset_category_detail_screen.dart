import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:asset_management/screen/asset_detail_view_screen.dart';
import 'package:asset_management/screen/models/asset.dart';

class AssetCategoryDetailScreen extends StatefulWidget {
  final String categoryName;

  final List<Asset> assetsInCategory;

  const AssetCategoryDetailScreen({
    Key? key,
    required this.categoryName,
    this.assetsInCategory = const [],
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

  bool _isEditing = false; 
  Set<String> _selectedAssetIds = {}; 

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
          'http://assetin.my.id/skripsi/get_asset.php?action=get_devices_by_category&category=${Uri.encodeComponent(widget.categoryName)}'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _devices = data.map((item) => Asset(
            id: item['id'],
            name: item['name'],
            category: item['category'],
            locationId: item['locationId'],
            locationInfo: item['locationInfo'],
            latitude: (item['latitude'] as num).toDouble(), 
            longitude: (item['longitude'] as num).toDouble(),
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
        _devices.removeWhere((asset) => _selectedAssetIds.contains(asset.id));
        _filterDevices(); 
        _selectedAssetIds.clear();
        if (_devices.isEmpty) { 
          _isEditing = false;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected asset(s) deleted.'),backgroundColor: Colors.red,),
      );
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterDevices);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double consistentAppBarHeight = 100.0;

    return Scaffold(
      backgroundColor: Colors.grey[100], 
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(consistentAppBarHeight), 
        child: Stack(
          children: [
            Image.asset(
              'assets/bg_image.png', 
              height: consistentAppBarHeight,
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
                                        builder: (context) => AssetDetailViewScreen(
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