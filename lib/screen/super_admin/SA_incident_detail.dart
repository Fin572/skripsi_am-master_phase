// SA_incident_detail.dart
// sa_detail_screen.dart
import 'package:asset_management/widgets/company_info_card.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // For base64 decoding (preserved)
import 'package:http/http.dart' as http; // Preserved

class SAIncidentDetailScreen extends StatefulWidget {
  final Map<String, String> incident; // Changed type to Map<String, String>
  final String currentTabStatus;
  // Callback function to notify parent when incident status is updated
  final Function(Map<String, String> updatedIncident)? onIncidentUpdated; // Updated type

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
    // Combines before_photos and after_photos
    List<String> images = [];
    if (widget.incident['before_photos'] != null && widget.incident['before_photos']!.isNotEmpty) {
      images.addAll(widget.incident['before_photos']!.split(',').where((s) => s.isNotEmpty));
    }
    if (widget.incident['after_photos'] != null && widget.incident['after_photos']!.isNotEmpty) {
      images.addAll(widget.incident['after_photos']!.split(',').where((s) => s.isNotEmpty));
    }
    _uploadedImages = images;
  }

  Future<void> _approveIncident(String newStatus, String newSubStatus) async { // Modified signature
    final url = Uri.parse('http://assetin.my.id/skripsi/approve_incident_sa.php'); // Preserved endpoint
    final incidentId = widget.incident['incident_id'];
    final currentStatusFromIncident = widget.incident['status']; // Get current status from incident data

    try {
      final response = await http.post( // Preserved HTTP call
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'incident_id': incidentId,
          'status': newStatus, // New main status to set
          'sub_status': newSubStatus, // New sub-status to set
          'current_status': currentStatusFromIncident, // Pass current status of incident
          'remark': newSubStatus, // Assuming remark is the sub_status for simplicity for now
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        // Update the local incident data and notify the parent
        final Map<String, String> updatedIncident = Map<String, String>.from(widget.incident); // Ensure type is correct
        updatedIncident['status'] = newStatus;
        updatedIncident['subStatus'] = newSubStatus; // Update subStatus in the map
        if (widget.onIncidentUpdated != null) {
          widget.onIncidentUpdated!(updatedIncident); // Notify parent
        }
        Navigator.pop(context); // Return to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve/reject: ${data['message']}')),
        );
      }
    } catch (e) {
      print('Error approving/rejecting incident: $e'); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving/rejecting incident: $e')),
      );
    }
  }

  // Simplified and consolidated update status logic for UI
  void _updateIncidentStatus(String newStatus, String? newSubStatus) {
    // This function acts as an intermediary for UI state update and then calls the backend interaction.
    // It is mostly for local UI updates before the backend call confirms the change.
    // The actual backend approval/rejection happens in _approveIncident.

    // If the action is "Approve" (SA approves Admin's action), we directly call _approveIncident
    // If the action is "Reject" (SA rejects Admin's action), we also call _approveIncident with new statuses
    if (newStatus == 'Approved by SA' || newSubStatus == 'Approved' || newSubStatus == 'Rejected') {
      _approveIncident(newStatus, newSubStatus ?? ''); // Call backend with appropriate status
    }
    // No local setState here for main status, as _approveIncident will trigger _fetchIncidents on parent
    // which then updates the main list.
  }


  // New callback for when AdminCompleteIncidentScreen finishes (Preserved from admin_incident_detail_screen.dart)
  void _handleAdminCompleted(Map<String, String> updatedIncident) {
    // This callback is triggered when AdminCompleteIncidentScreen submits.
    // It should update the incident's status to 'Completed' in the parent AdminIncidentScreen.
    if (widget.onIncidentUpdated != null) {
      widget.onIncidentUpdated!(updatedIncident);
    }
    // No need to pop here, AdminCompleteIncidentScreen already popped this screen.
  }


  @override
  Widget build(BuildContext context) {
    const double consistentAppBarHeight = 100.0; // Consistent with NEW UI

    final String companyInfoRaw = widget.incident['companyInfo'] ?? 'PT Dunia Persada - #000000';
    List<String> companyParts = companyInfoRaw.split(' - ');
    final String displayCompanyName = companyParts.isNotEmpty ? companyParts[0].trim() : 'N/A';
    final String displayTicketNumber = companyParts.length > 1 ? companyParts[1].trim() : '#000000';
    final String displayDeviceCount = widget.incident['title']!.contains('CCTV') ? '4 Devices' : 'N/A Devices'; // More dynamic

    bool isAwaitingSAReview = (widget.incident['subStatus'] == 'Awaiting SA Review'); // Check from incident data

    // Determine if the current incident's main status needs SA review buttons
    // The previous logic for showApproveButtonForAssigned/Completed/Rejected is now consolidated into isAwaitingSAReview
    // as Super Admin only acts on "Awaiting SA Review".

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
                print('Error loading bg_image.png: $error'); // Debug print
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
                      'Incident Detail', // Changed title
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

            // Display Price, PIC, Completion Description if available (for 'Completed' status from backend)
            // Using incident['value'], incident['pic_id'], incident['description'] from initial fetch
            // and assuming 'Completed' as primary status indicates these might be filled.
            if (widget.incident['status'] == 'Completed' && (widget.incident['value']?.isNotEmpty ?? false))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildReadOnlyTextField(
                    label: 'Price',
                    value: widget.incident['value']!,
                  ),
                  const SizedBox(height: 10),
                  _buildReadOnlyTextField(
                    label: 'PIC (Completion)',
                    value: widget.incident['pic_id'] ?? 'N/A', // Using pic_id as PIC completion
                  ),
                  const SizedBox(height: 10),
                  _buildReadOnlyTextField(
                    label: 'Completion Details',
                    value: widget.incident['description'] ?? 'No completion details provided.', // Using original description field for completion details if not separate
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
            _buildImageGrid(), // Updated to use the list populated in initState

            const SizedBox(height: 20),

            // Action Buttons based on status and subStatus
            if (isAwaitingSAReview) // Only show SA approval/rejection buttons if it's awaiting SA review
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Super Admin rejects the admin's action (rejection or completion)
                        // Reverts status to previous state, subStatus becomes 'Rejected' by SA
                        // If it was 'Rejected' by Admin, new status is 'Assigned', subStatus 'Rejected'
                        // If it was 'Completed' by Admin, new status is 'On Progress', subStatus 'Rejected'
                        String newMainStatus;
                        if (widget.incident['status'] == 'Rejected') {
                          newMainStatus = 'Assigned'; // Revert rejected to assigned
                        } else if (widget.incident['status'] == 'Completed') {
                          newMainStatus = 'On Progress'; // Revert completed to on progress
                        } else {
                          newMainStatus = 'Assigned'; // Default or fallback
                        }
                        _approveIncident(newMainStatus, 'Rejected'); // Backend will handle marking it rejected by SA
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
                        // Super Admin approves the admin's action (rejection or completion)
                        // This moves the incident to archive or finalizes its status.
                        // Based on original status, new status becomes 'Approved by SA' or final.
                        String newFinalStatus;
                        if (widget.incident['status'] == 'Rejected') {
                          newFinalStatus = 'Rejected'; // Final status remains 'Rejected'
                        } else if (widget.incident['status'] == 'Completed') {
                          newFinalStatus = 'Completed'; // Final status remains 'Completed'
                        } else {
                          newFinalStatus = 'Approved by SA'; // Fallback
                        }
                        _approveIncident(newFinalStatus, 'Approved by SA'); // Backend will archive based on this subStatus
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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: _uploadedImages.length, // Use the dynamically loaded images
      itemBuilder: (context, index) {
        final String imageData = _uploadedImages[index];
        final String imageLabel = _getImageLabel(index); // Get label based on index or type

        return Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: imageData.startsWith('http')
                    ? Image.network(
                        imageData,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          );
                        },
                      )
                    : (imageData.isNotEmpty && RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(imageData))
                        ? Image.memory(
                            base64Decode(imageData),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Base64 decode error: $error for path: $imageData');
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              );
                            },
                          )
                        : Image.asset( // Fallback for local assets or empty
                            imageData.isNotEmpty ? imageData : 'assets/image_placeholder.png', // A generic placeholder
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Asset error or empty path: $error for path: $imageData');
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              );
                            },
                          ),
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

  // Helper to determine image label based on index (can be expanded to check content type if needed)
  String _getImageLabel(int index) {
    if (index == 0) return 'Before Image (1)';
    if (index == 1) return 'After Image (1)';
    if (index == 2) return 'Before Image (2)';
    if (index == 3) return 'After Image (2)';
    return 'Image ${index + 1}';
  }
}