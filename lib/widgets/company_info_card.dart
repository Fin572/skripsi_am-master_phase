// lib/widgets/company_info_card.dart
import 'package:flutter/material.dart';

class CompanyInfoCard extends StatelessWidget {
  // These parameters allow you to pass specific values
  // so the card can display dynamic information.
  final String ticketNumber;
  final String companyName;
  final String deviceCount; // Renamed from assetCount to be more precise for devices

  const CompanyInfoCard({
    Key? key,
    // Provide default values if you want to use it without specifying everything
    this.ticketNumber = '#000001',
    this.companyName = 'PT Dunia Persada',
    this.deviceCount = '4 Devices',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      // The Card itself handles the basic shape and elevation
      margin: EdgeInsets.zero, // Removed margin as it's typically handled by parent padding
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4, // Add elevation for a card look and shadow
      child: Container(
        // Use Container for the gradient background and internal padding
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)], // Your blue gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          // Box shadow moved to Card's default elevation
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Make column only take needed space
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Icon(Icons.apartment, size: 30, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              ticketNumber,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18, // Adjust font size as needed
              ),
            ),
            Text(
              companyName,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.laptop_mac, color: Colors.white70, size: 16), // Changed to laptop_mac as per original image
                const SizedBox(width: 4),
                Text(
                  deviceCount,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}