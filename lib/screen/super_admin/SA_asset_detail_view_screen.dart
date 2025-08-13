// lib/screens/asset_detail_view_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // For map display
import 'package:latlong2/latlong.dart'; // For LatLng
import 'package:asset_management/screen/models/asset.dart'; // Import the updated Asset model

class SAAssetDetailViewScreen extends StatelessWidget {
  final Asset asset; // This screen receives a full Asset object

  const SAAssetDetailViewScreen({Key? key, required this.asset}) : super(key: key);

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 250, 
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(asset.latitude, asset.longitude), 
                      initialZoom: 15.0, 
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate, 
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.your_app_name',
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            asset.name, 
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

                  const Text(
                    "Asset's Barcode",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 150, 
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Center(
                      child: asset.barcodeData != null && asset.barcodeData!.isNotEmpty
                          ? Text(
                              'Barcode: ${asset.barcodeData}', 
                              style: const TextStyle(fontSize: 16, color: Colors.black54),
                            )
                          : const Text(
                              'No Barcode Available',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}