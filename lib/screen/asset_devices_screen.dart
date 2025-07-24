// lib/screens/asset_devices_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:asset_management/screen/add_device_screen.dart';
import 'package:asset_management/screen/asset_category_detail_screen.dart';
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
  bool _isEditing = false; // New state variable for edit mode
  Set<String> _selectedCategoryNames = {}; // Stores names of selected categories

  List<Map<String, dynamic>> _assetCategoryData = []; // Now mutable, fetched from API
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

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _selectedCategoryNames.clear(); // Clear selection when exiting edit mode
      }
    });
  }

  void _toggleSelectCategory(String categoryName) {
    setState(() {
      if (_selectedCategoryNames.contains(categoryName)) {
        _selectedCategoryNames.remove(categoryName);
      } else {
        _selectedCategoryNames.add(categoryName);
      }
    });
  }

  void _confirmAndDeleteCategories() async {
    if (_selectedCategoryNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No asset category selected for deletion.')),
      );
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete ${_selectedCategoryNames.length} selected asset category(ies)?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // No
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Yes
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // TODO: Implement actual deletion logic via API call here
      // For now, simulate deletion from local list
      setState(() {
        _assetCategoryData.removeWhere((category) => _selectedCategoryNames.contains(category['categoryName']));
        _selectedCategoryNames.clear();
        if (_assetCategoryData.isEmpty) { // Exit edit mode if all items are deleted
          _isEditing = false;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected asset category(ies) deleted.'),
        backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define the consistent AppBar height
    const double consistentAppBarHeight = 100.0;

    // Calculate total assets dynamically
    final totalAssetsCount = _assetCategoryData.fold(0, (sum, category) => sum + int.parse(category['deviceCount'] ?? '0'));


    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(consistentAppBarHeight),
        child: Stack(
          children: [
            // Background image that covers the entire PreferredSize area (95.0px)
            Image.asset(
              'assets/bg_image.png', // Ensure this path is correct
              height: consistentAppBarHeight,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
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
                    const Spacer(), // Pushes actions to the right
                    // Show delete icon only when editing and items are selected
                    if (_isEditing && _selectedCategoryNames.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: _confirmAndDeleteCategories,
                      ),
                    // Show edit icon only if there are items to edit, or if currently editing to exit
                    if (_assetCategoryData.isNotEmpty || _isEditing)
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
                      : '$totalAssetsCount Device', // Updated to dynamically reflect data
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
                                  final categoryName = category['categoryName']!;
                                  final isSelected = _selectedCategoryNames.contains(categoryName);

                                  return GestureDetector(
                                    onLongPress: () {
                                      if (!_isEditing) {
                                        _toggleEditMode();
                                      }
                                      _toggleSelectCategory(categoryName);
                                    },
                                    onTap: () {
                                      if (_isEditing) {
                                        _toggleSelectCategory(categoryName);
                                      } else {
                                        // Fetch actual assets for the category before navigating
                                        // For this example, we're navigating directly.
                                        // In a real app, you'd fetch assets related to this categoryName
                                        // and pass them. Since the original asset_category_detail_screen.dart
                                        // fetches its own data, we can pass an empty list initially,
                                        // or refactor to fetch here and pass. For now, matching the NEW UI's data passing.
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AssetCategoryDetailScreen(
                                              categoryName: categoryName,
                                              // NOTE: The original asset_category_detail_screen.dart fetches its own data.
                                              // To fully match NEW UI's direct asset passing, you'd fetch them here.
                                              // For now, we'll rely on AssetCategoryDetailScreen to fetch its own.
                                              // But the NEW UI example for AssetDevicesScreen passes a 'devices' list.
                                              // If your API provides 'devices' directly here, you can use:
                                              // assetsInCategory: (category['devices'] as List<dynamic>?)?.map((e) => Asset.fromJson(e)).toList() ?? [],
                                              // For now, passing a placeholder as the original AssetCategoryDetailScreen handles fetching.
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Card(
                                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: _isEditing && isSelected
                                            ? const BorderSide(color: Colors.blue, width: 2.0)
                                            : BorderSide.none,
                                      ),
                                      color: Colors.white, // Set card background to white
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: [
                                            if (_isEditing)
                                              Checkbox(
                                                value: isSelected,
                                                onChanged: (bool? value) {
                                                  _toggleSelectCategory(categoryName);
                                                },
                                              ),
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
                                                    'Qty : ${category['deviceCount']!}',
                                                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (!_isEditing) // Show detail button only when not in editing mode
                                              TextButton(
                                                onPressed: () {
                                                  // Navigate to AssetCategoryDetailScreen
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => AssetCategoryDetailScreen(
                                                        categoryName: categoryName,
                                                        // Passing empty list as the target screen will fetch its own
                                                        // based on your original file.
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
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: _isEditing
                      ? ElevatedButton(
                          onPressed: _confirmAndDeleteCategories,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Text(
                            'Delete Selected',
                            style: TextStyle(color: Color.fromARGB(255, 119, 119, 119), fontSize: 18),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AddDeviceScreen()), // Pass empty list as constructor now requires it
                            );
                            if (result == true) { // If device was successfully added
                              setState(() {
                                _showSuccessPopup = true;
                              });
                              Future.delayed(const Duration(seconds: 3), () {
                                if (mounted) {
                                  setState(() {
                                    _showSuccessPopup = false;
                                  });
                                }
                              });
                              _fetchCategories(); // Refresh categories after adding a device
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(52, 152, 219, 1),
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