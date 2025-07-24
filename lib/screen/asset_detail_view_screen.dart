// lib/screens/asset_detail_view_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // For map display
import 'package:latlong2/latlong.dart'; // For LatLng
import 'package:asset_management/screen/models/asset.dart'; // Import the updated Asset model

class AssetDetailViewScreen extends StatelessWidget {
  final Asset asset; // This screen receives a full Asset object

  const AssetDetailViewScreen({Key? key, required this.asset}) : super(key: key);

  // Helper for displaying a single info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                    const Text(
                      'Devices', // Title "Devices" from the image
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 250, // Height for the map
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(asset.latitude, asset.longitude), // Center map on asset's coordinates
                      initialZoom: 15.0, // Zoom level
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate, // Allow pan/zoom, but not rotate
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.your_app_name', // Replace with your package name
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(asset.latitude, asset.longitude),
                            width: 80,
                            height: 80,
                            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // No search bar on the map in this specific image for detail view
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Asset Details Card ---
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            asset.name, // e.g., CCTV
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                          ),
                          const SizedBox(height: 10),
                          _buildInfoRow('Device ID', asset.id),
                          _buildInfoRow('Category', asset.category),
                          _buildInfoRow('Location Info', asset.locationInfo),
                          _buildInfoRow(
                            'Coordinate',
                            '${asset.latitude.toStringAsFixed(10)}, ${asset.longitude.toStringAsFixed(10)}',
                          ),
                          _buildInfoRow('Person in charge', asset.personInCharge),
                          _buildInfoRow('Phone number', asset.phoneNumber),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Asset's Barcode Section ---
                  const Text(
                    "Asset's Barcode",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 150, // Height for barcode image
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Center(
                      // Placeholder for barcode. You'd use a package like barcode_widget
                      // or network image if barcode is from server.
                      child: asset.barcodeData != null && asset.barcodeData!.isNotEmpty
                          ? Text(
                              'Barcode: ${asset.barcodeData}', // Display barcode data as text
                              style: const TextStyle(fontSize: 16, color: Colors.black54),
                            )
                          : const Text(
                              'No Barcode Available',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20), // Spacing at the bottom
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}