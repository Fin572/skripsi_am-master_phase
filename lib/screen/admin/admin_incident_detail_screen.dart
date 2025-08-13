// admin_incident_detail_screen.dart
import 'package:asset_management/screen/admin/Admin_completed_Incident_Screen.dart';
import 'package:flutter/material.dart';
import 'package:asset_management/widgets/company_info_card.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert'; 

class AdminIncidentDetailScreen extends StatefulWidget {
  final Map<String, String> incident;
  final String currentTabStatus;
  final Function(Map<String, String>) onIncidentUpdated;

  const AdminIncidentDetailScreen({
    Key? key,
    required this.incident,
    required this.currentTabStatus,
    required this.onIncidentUpdated,
  }) : super(key: key);

  @override
  State<AdminIncidentDetailScreen> createState() => _AdminIncidentDetailScreenState();
}

class _AdminIncidentDetailScreenState extends State<AdminIncidentDetailScreen> {
  late Map<String, String> _currentIncident;

  @override
  void initState() {
    super.initState();
    _currentIncident = Map<String, String>.from(widget.incident);
    print('Current Incident in Detail: $_currentIncident'); 
  }

  Future<void> _showConfirmationDialog(String action) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text('Are you sure you want to $action this incident?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _updateIncidentStatus(action); 
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateIncidentStatus(String action) async { 
    String newStatus;
    if (action == 'Accept') {
      newStatus = 'On progress'; 
    } else if (action == 'Reject') {
      newStatus = 'Rejected';
    } else {
      return;
    }

    setState(() {
      _currentIncident['status'] = newStatus;
      print('Updating incident ${_currentIncident['incident_id']} to status: $newStatus'); 
    });

    try {
      final response = await http.post( 
        Uri.parse('http://assetin.my.id/skripsi/update_incidents.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'incident_id': _currentIncident['incident_id'],
          'status': newStatus,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        print('API Success: ${responseData['message']}'); 
        widget.onIncidentUpdated(_currentIncident);
      } else {
        print('API Error: ${responseData['error']}'); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: ${responseData['error']}')),
        );
        setState(() {
          _currentIncident['status'] = widget.incident['status']!; 
        });
      }
    } catch (e) {
      print('Network Error: $e'); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating incident: $e')),
      );
      setState(() {
        _currentIncident['status'] = widget.incident['status']!; 
      });
    }
  }

  void _handleIncidentCompleted(Map<String, String> updatedIncident) {
    widget.onIncidentUpdated(updatedIncident);
  }

  @override
  Widget build(BuildContext context) {
    const double consistentAppBarHeight = 100.0; 

    final String companyInfo = _currentIncident['companyInfo']!;
    final List<String> companyParts = companyInfo.split(' - ');
    final String companyName = companyParts[0].trim();
    final String companyId = companyParts.length > 1 ? companyParts[1].trim() : '';
    final String displayDeviceCount = _currentIncident['title']!.contains('CCTV') ? '4 Devices' : 'N/A Devices';

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
                      'Incident',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CompanyInfoCard(
                ticketNumber: companyId,
                companyName: companyName,
                deviceCount: displayDeviceCount,
              ),
              const SizedBox(height: 20),
              _buildReadOnlyTextField(
                label: 'Location',
                value: _currentIncident['location'] ?? '#110000 - Kantor Pusat Cakung',
              ),
              const SizedBox(height: 10),
              _buildReadOnlyTextField(
                label: 'Incident ID',
                value: _currentIncident['ticketId'] ?? '#001001',
              ),
              const SizedBox(height: 10),
              _buildReadOnlyTextField(
                label: 'Category',
                value: _currentIncident['title']!,
              ),
              const SizedBox(height: 10),
              _buildReadOnlyTextField(
                label: 'Description',
                value: _currentIncident['description'] ?? 'No description provided',
                isMultiline: true,
              ),
              const SizedBox(height: 20),
              const Text(
                'Upload Images',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildImageGrid(),
              const SizedBox(height: 20),
              if (_currentIncident['status'] == 'Assigned')
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showConfirmationDialog('Reject'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Reject',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showConfirmationDialog('Accept'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(52, 152, 219, 1), 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                )
              else if (_currentIncident['status']?.toLowerCase() == 'on progress')
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminCompleteIncidentScreen(
                            incident: _currentIncident,
                            onIncidentCompleted: _handleIncidentCompleted,
                            action: 'Submit', // Reintroduced action
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255), 
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      'Complete Incident',
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18), 
                    ),
                  ),
                ),
            ],
          ),
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
    List<String> imageUrls = [];
    if (_currentIncident['before_photos'] != null && _currentIncident['before_photos']!.isNotEmpty) {
      imageUrls = _currentIncident['before_photos']!.split(',');
    }

    final List<Map<String, String>> displayImages = imageUrls.isNotEmpty
        ? imageUrls.map((url) {
            String cleanedUrl = url.trim();
            print('Processing image URL: $cleanedUrl'); // Debug log
            return {'path': cleanedUrl, 'label': 'Before Image'};
          }).where((image) => image['path']!.isNotEmpty).toList()
        : [
            {'path': 'assets/cctv_front.png', 'label': 'Front View'},
            {'path': 'assets/cctv_rear.png', 'label': 'Rear View'},
            {'path': 'assets/cctv_top.png', 'label': 'Top View'},
            {'path': 'assets/cctv_bottom.png', 'label': 'Bottom View'},
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
        final String imagePath = displayImages[index]['path']!;
        final String imageLabel = displayImages[index]['label']!;

        return Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: imagePath.startsWith('http')
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Network image error: $error');
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          );
                        },
                      )
                    : (imagePath.isNotEmpty && RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(imagePath))
                        ? Image.memory(
                            base64Decode(imagePath),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Base64 decode error: $error for path: $imagePath');
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Asset error: $error for path: $imagePath');
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
}