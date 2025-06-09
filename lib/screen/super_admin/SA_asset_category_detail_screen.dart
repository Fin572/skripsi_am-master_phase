// lib/screens/super_admin/SA_asset_category_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:asset_management/screen/models/asset.dart'; // Make sure to import the Asset model here

class SAAssetCategoryDetailScreen extends StatefulWidget {
  final String categoryName;
  final List<Asset> assetsInCategory; // This parameter is crucial

  const SAAssetCategoryDetailScreen({
    Key? key,
    required this.categoryName,
    required this.assetsInCategory, // Mark it as required
  }) : super(key: key);

  @override
  State<SAAssetCategoryDetailScreen> createState() => _SAAssetCategoryDetailScreenState();
}

class _SAAssetCategoryDetailScreenState extends State<SAAssetCategoryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(245,245,245, 245),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(95.0), // Consistent height for the app bar
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
                    Text(
                      '${widget.categoryName} Devices', // Display the category name in the app bar
                      style: const TextStyle(
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
      body: widget.assetsInCategory.isEmpty
          ? const Center(
              child: Text('No assets found in this category.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: widget.assetsInCategory.length,
              itemBuilder: (context, index) {
                final asset = widget.assetsInCategory[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  color: Colors.white, 
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text('ID: ${asset.id}'),
                        Text('Location: ${asset.locationInfo}'),
                        Text('PIC: ${asset.personInCharge}'),
                        // Add more asset details as needed
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}