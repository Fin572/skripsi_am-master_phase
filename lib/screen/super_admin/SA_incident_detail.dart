// sa_detail_screen.dart
import 'package:asset_management/widgets/company_info_card.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // For base64 decoding
import 'package:http/http.dart' as http;

class SAIncidentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> incident; // Changed from Map<String, String> to Map<String, dynamic>
  final String currentTabStatus;
  // Callback function to notify parent when incident status is updated
  final Function(Map<String, dynamic> updatedIncident)? onIncidentUpdated; // Updated type

  const SAIncidentDetailScreen({
    Key? key,
    required this.incident,
    required this.currentTabStatus,
    this.onIncidentUpdated,
  }) : super(key: key);

  @override
  State<SAIncidentDetailScreen> createState() => _SAIncidentDetailScreenState();
}

class _SAIncidentDetailScreenState extends State<SAIncidentDetailScreen> {
  late List<String> _uploadedImages; // Will be initialized dynamically

  @override
  void initState() {
    super.initState();
    _initializeUploadedImages();
  }

  void _initializeUploadedImages() {
    // Initialize _uploadedImages with data from the incident
    _uploadedImages = [
      widget.incident['before_photos']?.toString() ?? '', // First image from before_photos
      widget.incident['after_photos']?.toString() ?? '',  // Second image from after_photos (if available)
      '', // Placeholder for Tampak Atas
      '', // Placeholder for Tampak Bawah
      '', // Additional placeholder if needed
    ];
  }

  Future<void> _approveIncident(String newStatusSa) async {
    final url = Uri.parse('http://assetin.my.id/skripsi/approve_incident_sa.php');
    final incidentId = widget.incident['incident_id'];

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'incident_id': incidentId,
          'status_sa': newStatusSa,
          'current_status': widget.currentTabStatus,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        // Update the local incident data and notify the parent
        final Map<String, dynamic> updatedIncident = Map.from(widget.incident);
        updatedIncident['status_sa'] = newStatusSa;
        if (widget.onIncidentUpdated != null) {
          widget.onIncidentUpdated!(updatedIncident);
        }
        Navigator.pop(context); // Return to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve: ${data['message']}')),
        );
      }
    } catch (e) {
      print('Error approving incident: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving incident: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const double consistentAppBarHeight = 95.0;

    final String companyInfoRaw = widget.incident['companyInfo'] ?? 'PT Dunia Persada - #000000';
    List<String> companyParts = companyInfoRaw.split(' - ');
    final String displayCompanyName = companyParts.isNotEmpty ? companyParts[0].trim() : 'N/A';
    final String displayTicketNumber = companyParts.length > 1 ? companyParts[1].trim() : '#000000';
    final String displayDeviceCount = '4 Devices';

    bool showApproveButtonForAssigned = widget.currentTabStatus == 'Assigned';
    bool showApproveButtonForCompleted = widget.currentTabStatus == 'Completed';
    bool showApproveButtonForRejected = widget.currentTabStatus == 'Rejected';

    return Scaffold(
      backgroundColor: const Color.fromARGB(245, 245, 245, 245),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(consistentAppBarHeight),
        child: Stack(
          children: [
            Image.asset(
              'assets/bg_image.png',
              height: consistentAppBarHeight,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading bg_image.png: $error');
                return Container(
                  height: consistentAppBarHeight,
                  width: double.infinity,
                  color: Colors.red,
                  child: const Center(
                    child: Text('Error loading image', style: TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Detail',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CompanyInfoCard(
              ticketNumber: displayTicketNumber,
              companyName: displayCompanyName,
              deviceCount: displayDeviceCount,
            ),
            const SizedBox(height: 16),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: widget.incident['value']?.toString() ?? 'Rp 200.000,-',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 5,
              readOnly: true,
              decoration: InputDecoration(
                hintText: widget.incident['description']?.toString() ?? 'Margareth\n\nSaluran sudah kembali normal :\n• terdapat kerusakan di kabel dikarenakan digigit tikus',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Uploaded Images',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: _uploadedImages.length,
              itemBuilder: (context, index) {
                if (index < _uploadedImages.length) {
                  return _buildImagePlaceholder(_uploadedImages[index], index == 0 ? null : _getImageLabel(index));
                }
                return SizedBox.shrink(); // Return empty widget for out-of-bounds indices
              },
            ),
            const SizedBox(height: 30),
            if (showApproveButtonForAssigned)
              Center(
                child: ElevatedButton(
                  onPressed: () => _approveIncident('On Progress'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Approve',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (showApproveButtonForCompleted)
              Center(
                child: ElevatedButton(
                  onPressed: () => _approveIncident('Approved by Admin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Approve',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (showApproveButtonForRejected)
              Center(
                child: ElevatedButton(
                  onPressed: () => _approveIncident('Rejected by Admin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Approve',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(String imageData, String? label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imageData.isNotEmpty)
            // Handle base64-encoded image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  base64Decode(imageData), // Decode base64 string to image
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error decoding image at index: $error');
                    return const Icon(Icons.broken_image, size: 40, color: Colors.red);
                  },
                ),
              ),
            )
          else
            Icon(Icons.image, size: 40, color: Colors.grey.shade400),
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
        ],
      ),
    );
  }

  String _getImageLabel(int index) {
    switch (index) {
      case 1:
        return 'Tampak Belakang';
      case 2:
        return 'Tampak Atas';
      case 3:
        return 'Tampak Bawah';
      default:
        return '';
    }
  }
}