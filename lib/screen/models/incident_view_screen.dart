// incident_view_screen.dart
// lib/screens/incident_view_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // This import is still present but its usage for formatting is not directly visible in the provided snippets.
import 'package:asset_management/screen/models/incident_ticket.dart';
import 'package:asset_management/widgets/company_info_card.dart';
// Removed: import 'dart:convert';
// Removed: import 'dart:typed_data';

class IncidentViewScreen extends StatelessWidget {
  final IncidentTicket incidentTicket;

  const IncidentViewScreen({Key? key, required this.incidentTicket}) : super(key: key);

  // --- FIX: Define _imageLabels here as a static const member ---
  static const List<String> _imageLabels = [
    'Tampak Depan',
    'Tampak Belakang',
    'Tampak Atas',
    'Tampak Bawah',
    'Lainnya 1',
    'Lainnya 2',
  ];
  // --- END FIX ---


  // Helper to get status color (reused from IncidentScreen) - KEPT FOR REFERENCE, NOT USED IN THIS UI
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Assigned':
        return Colors.orange;
      case 'On progress':
        return Colors.blue;
      case 'Rejected':
        return Colors.red;
      case 'Done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // --- Helper for read-only text fields (similar to _buildTextField but simplified for view) ---
  Widget _buildReadOnlyField({
    required String labelText,
    required String value,
    String? hintText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with asterisk
        RichText(
          text: TextSpan(
            text: labelText,
            style: TextStyle(
              color: Colors.grey[700], // Label color
              fontSize: 14,
            ),
            children: const [
              TextSpan(
                text: '*', // Asterisk for required fields
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4), // Small space between label and field
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.grey[200], // Background color for read-only fields
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: Text(
            value.isEmpty ? (hintText ?? '') : value, // Display value or hint if empty
            style: TextStyle(
              color: value.isEmpty ? Colors.grey[500] : Colors.black, // Text color
              fontSize: 16,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis, // Handle overflow
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Removed: print('IncidentTicket data: $incidentTicket'); // Tambahan debug
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        toolbarHeight: 100, // Matches IncidentDetailScreen's AppBar
        title: const Text(
          "Incident", // Title in image is "Incident"
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: const Image(
          image: AssetImage('assets/bg_image.png'), // Assuming this asset is available
          fit: BoxFit.cover,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, null); // Pop back without data
          },
        ),
        // Removed delete button from view screen as per the image
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Card - using the reusable widget
            const CompanyInfoCard(), // Uses default values for ticket number, company, and devices
                                    // Make sure these defaults match your requirement from the image.
                                    // If this data is dynamic (e.g., from a specific device/company),
                                    // you'd pass it via IncidentTicket and then to CompanyInfoCard.
            const SizedBox(height: 20),

            // Location ID
            _buildReadOnlyField(
              labelText: 'Location ID',
              value: '${incidentTicket.location.id} - ${incidentTicket.location.name}',
            ),
            const SizedBox(height: 15),

            // Asset ID
            _buildReadOnlyField(
              labelText: 'Device ID',
              value: incidentTicket.asset.id,
            ),
            const SizedBox(height: 15),

            // Asset Name
            _buildReadOnlyField(
              labelText: 'Device Name',
              value: incidentTicket.asset.name,
              hintText: 'Auto-filled from Device ID',
            ),
            const SizedBox(height: 15),

            // Description
            _buildReadOnlyField(
              labelText: 'Description',
              value: incidentTicket.description,
              maxLines: 5,
              hintText: 'No description provided',
            ),
            const SizedBox(height: 20),

            // Upload Images Section
            const Text(
              'Upload Images',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Display only existing images in the grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Disable scrolling
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.2, // Adjust as needed
              ),
              itemCount: 4, // Fixed to 4 slots as per the image, even if less uploaded
              itemBuilder: (context, index) {
                // Assuming imageUrls now contain direct paths (either asset or file)
                final imagePath = index < incidentTicket.imageUrls.length
                    ? incidentTicket.imageUrls[index]
                    : null;
                // Access _imageLabels using the class name since it's static
                final String imageLabel = index < _imageLabels.length ? _imageLabels[index] : '';
                // Removed: print('Image $index - Base64: $imageBase64');

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Background for empty slots
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imagePath != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            // Using Image.file as per NEW UI, assuming imagePath is a valid File path
                            Image.file(
                              File(imagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Removed detailed prints, kept generic error icon
                                return const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40));
                              },
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8.0)),
                                ),
                                child: Text(
                                  imageLabel,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column( // Placeholder for empty image slots
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 40, color: Colors.grey[400]),
                            const SizedBox(height: 5),
                            Text(
                              imageLabel,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                );
              },
            ),
            const SizedBox(height: 30),

            // Only a Cancel button at the bottom as per image
            SizedBox(
              width: double.infinity, // Make button fill width
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context, null); // Just pop back, no special action on this cancel
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}