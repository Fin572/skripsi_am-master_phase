// SA_incident_detail.dart
import 'package:asset_management/widgets/company_info_card.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // For base64 decoding (preserved)
import 'package:http/http.dart' as http; // Preserved
import 'dart:io'; // For SocketException
import 'dart:async'; // Added for TimeoutException

class SAIncidentDetailScreen extends StatefulWidget {
  final Map<String, String> incident;
  final String currentTabStatus;
  final Function(Map<String, String> updatedIncident)? onIncidentUpdated;

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
  late List<String> _uploadedImages;

  @override
  void initState() {
    super.initState();
    _initializeUploadedImages();
  }

  void _initializeUploadedImages() {
    List<String> images = [];
    if (widget.incident['before_photos'] != null && widget.incident['before_photos']!.isNotEmpty) {
      images.addAll(widget.incident['before_photos']!.split(',').where((s) => s.isNotEmpty));
    }
    if (widget.incident['after_photos'] != null && widget.incident['after_photos']!.isNotEmpty) {
      images.addAll(widget.incident['after_photos']!.split(',').where((s) => s.isNotEmpty));
    }
    _uploadedImages = images;
  }

  Future<void> _approveIncident(String newStatusSa, String newSubStatus) async {
    final url = Uri.parse('http://assetin.my.id/skripsi/approve_incident_sa.php');
    final int? incidentId = int.tryParse(widget.incident['incident_id'] ?? '0');
    if (incidentId == null || incidentId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid incident ID.')),
      );
      return;
    }
    final currentStatusFromIncident = widget.incident['status'];

    final payload = {
      'incident_id': incidentId,
      'status_sa': newStatusSa, // Changed from 'status' to 'status_sa' to match PHP
      'sub_status': newSubStatus,
      'current_status': currentStatusFromIncident,
      'remark': newSubStatus,
    };

    print('Request payload: ${jsonEncode(payload)}'); // Added for debugging

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          final Map<String, String> updatedIncident = Map<String, String>.from(widget.incident);
          updatedIncident['status'] = newStatusSa; // Update status based on status_sa
          updatedIncident['subStatus'] = newSubStatus;

          if (widget.onIncidentUpdated != null) {
            widget.onIncidentUpdated!(updatedIncident);
          }
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to approve/reject: ${data['message'] ?? 'Unknown error'}')),
          );
        }
      } else {
        throw Exception('Failed to update incident: Status code ${response.statusCode} - ${response.body}');
      }
    } on TimeoutException catch (e) {
      print('Timeout error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request timed out. Please check your connection or server status.')),
      );
    } on SocketException catch (e) {
      print('Network error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your internet connection.')),
      );
    } catch (e) {
      print('Error approving/rejecting incident: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving/rejecting incident: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const double consistentAppBarHeight = 100.0;

    final String companyInfoRaw = widget.incident['companyInfo'] ?? 'PT Dunia Persada - #000000';
    List<String> companyParts = companyInfoRaw.split(' - ');
    final String displayCompanyName = companyParts.isNotEmpty ? companyParts[0].trim() : 'N/A';
    final String displayTicketNumber = companyParts.length > 1 ? companyParts[1].trim() : '#000000';
    final String displayDeviceCount = widget.incident['title'] != null && widget.incident['title']!.contains('CCTV') ? '4 Devices' : 'N/A Devices';

    bool isCurrentIncidentCompleted = (widget.incident['status'] == 'Completed');
    bool isCurrentIncidentRejected = (widget.incident['status'] == 'Rejected');

    bool showSAActionButtons = (isCurrentIncidentCompleted || isCurrentIncidentRejected) &&
                               (widget.incident['subStatus'] != 'Approved by SA');

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
                      'Incident Detail',
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
            const SizedBox(height: 20),

            _buildReadOnlyTextField(
              label: 'Location',
              value: widget.incident['location'] ?? 'N/A Location',
            ),
            const SizedBox(height: 10),

            _buildReadOnlyTextField(
              label: 'Incident ID',
              value: widget.incident['ticketId'] ?? 'N/A ID',
            ),
            const SizedBox(height: 10),

            _buildReadOnlyTextField(
              label: 'Category',
              value: widget.incident['title']!,
            ),
            const SizedBox(height: 10),

            _buildReadOnlyTextField(
              label: 'Description',
              value: widget.incident['description'] ?? 'No description provided.',
              isMultiline: true,
            ),

            if (isCurrentIncidentCompleted)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildReadOnlyTextField(
                    label: 'Price',
                    value: widget.incident['value'] ?? 'N/A',
                  ),
                  const SizedBox(height: 10),
                  _buildReadOnlyTextField(
                    label: 'PIC (Completion)',
                    value: widget.incident['pic_id'] ?? 'N/A',
                  ),
                  const SizedBox(height: 10),
                  _buildReadOnlyTextField(
                    label: 'Completion Details',
                    value: widget.incident['action_taken'] ?? 'No completion details provided.',
                    isMultiline: true,
                  ),
                ],
              ),

            const SizedBox(height: 20),
            const Text(
              'Upload Images',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildImageGrid(),

            const SizedBox(height: 20),

            if (showSAActionButtons)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        String newStatusSa;
                        if (isCurrentIncidentCompleted) {
                          newStatusSa = 'On Progress'; // Align with backend's allowed transition
                        } else if (isCurrentIncidentRejected) {
                          newStatusSa = 'Assigned'; // Align with backend's allowed transition
                        } else {
                          newStatusSa = 'On Progress'; // Fallback
                        }
                        _approveIncident(newStatusSa, 'Rejected by SA');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Reject',
                        style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        String newStatusSa;
                        if (isCurrentIncidentCompleted) {
                          newStatusSa = 'Approved by Admin'; // Align with backend's allowed transition
                        } else if (isCurrentIncidentRejected) {
                          newStatusSa = 'Rejected by Admin'; // Align with backend's allowed transition
                        } else {
                          newStatusSa = 'On Progress'; // Fallback
                        }
                        _approveIncident(newStatusSa, 'Approved by SA');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Approve',
                        style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyTextField({required String label, required String value, bool isMultiline = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.normal,
            ),
            maxLines: isMultiline ? null : 1,
            overflow: isMultiline ? TextOverflow.clip : TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildImageGrid() {
    List<String> allImagePaths = [];
    if (widget.incident['before_photos'] != null && widget.incident['before_photos']!.isNotEmpty) {
      allImagePaths.addAll(widget.incident['before_photos']!.split(',').where((s) => s.isNotEmpty));
    }
    if (widget.incident['after_photos'] != null && widget.incident['after_photos']!.isNotEmpty) {
      allImagePaths.addAll(widget.incident['after_photos']!.split(',').where((s) => s.isNotEmpty));
    }

    final List<Map<String, String>> displayImages = allImagePaths.isNotEmpty
        ? allImagePaths.map((path) => {'path': path, 'type': 'dynamic'}).toList()
        : [
            {'path': 'assets/cctv_front.png', 'type': 'asset', 'label': 'Front View'},
            {'path': 'assets/cctv_rear.png', 'type': 'asset', 'label': 'Rear View'},
            {'path': 'assets/cctv_top.png', 'type': 'asset', 'label': 'Top View'},
            {'path': 'assets/cctv_bottom.png', 'type': 'asset', 'label': 'Bottom View'},
          ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: displayImages.length,
      itemBuilder: (context, index) {
        final Map<String, String> imageData = displayImages[index];
        final String imagePath = imageData['path']!;
        final String imageType = imageData['type'] ?? 'dynamic';

        String imageLabel;
        if (imageData.containsKey('label')) {
            imageLabel = imageData['label']!;
        } else if (imageType == 'dynamic' && index < allImagePaths.length) {
            imageLabel = _getLabelForBackendImage(index);
        } else {
            imageLabel = 'Image ${index + 1}';
        }

        Widget imageWidget;
        if (imageType == 'asset') {
          imageWidget = Image.asset(imagePath, fit: BoxFit.cover);
        } else if (imagePath.startsWith('http')) {
          imageWidget = Image.network(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              );
            },
          );
        } else if (imagePath.isNotEmpty && RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(imagePath)) {
          try {
            imageWidget = Image.memory(
              base64Decode(imagePath),
              fit: BoxFit.cover,
            );
          } catch (e) {
            print('Error decoding base64 image: $e');
            imageWidget = Container(
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.error, color: Colors.red),
              ),
            );
          }
        } else {
          imageWidget = Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: imageWidget,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              imageLabel,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        );
      },
    );
  }

  String _getLabelForBackendImage(int index) {
      if (index == 0) return 'Before Image (1)';
      if (index == 1) return 'After Image (1)';
      return 'Image ${index + 1}';
  }
}