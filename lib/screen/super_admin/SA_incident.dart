import 'dart:async';
import 'dart:io';

import 'package:asset_management/screen/super_admin/SA_incident_detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class SAIncidentScreen extends StatefulWidget {
  const SAIncidentScreen({Key? key}) : super(key: key);

  @override
  State<SAIncidentScreen> createState() => _SAIncidentScreenState();
}

class _SAIncidentScreenState extends State<SAIncidentScreen> {
  int _selectedTabIndex = 0;
  List<Map<String, String>> _incidentData = [];
  bool _isLoading = true;

  final List<String> _statusCategories = [
    'Assigned',
    'On Progress',
    'Rejected',
    'Completed',
  ];

  @override
  void initState() {
    super.initState();
    _fetchIncidents();
  }

  Future<void> _fetchIncidents() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http
          .get(Uri.parse('http://assetin.my.id/skripsi/get_incidents.php'))
          .timeout(const Duration(seconds: 10));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        List<dynamic> rawData;

        if (data is Map<String, dynamic> && data['success'] == true && data['data'] != null) {
          rawData = data['data'];
        } else if (data is List<dynamic>) {
          rawData = data; // Handle plain array response
        } else {
          throw Exception('Unexpected JSON structure: $data');
        }

        setState(() {
          _incidentData = rawData.map((item) {
            String formattedDate = '';
            if (item['incident_date'] != null && item['incident_date'].toString().isNotEmpty) {
              try {
                DateTime dateTime = DateTime.parse(item['incident_date'].toString());
                formattedDate = DateFormat('dd MMM yyyy HH:mm:ss').format(dateTime) + ' WIB';
              } catch (e) {
                formattedDate = item['incident_date'].toString();
              }
            }

            return {
              'incident_id': item['incident_id']?.toString() ?? '',
              'title': item['title']?.toString() ?? 'Untitled Incident',
              'companyInfo': '${item['organization_name']?.toString() ?? 'Unknown Organization'} - #${item['incident_id']?.toString() ?? ''}',
              'date': formattedDate,
              'status': item['status']?.toString() ?? 'Unknown',
              'location': item['location_name']?.toString() ?? 'Location #${item['location_id']?.toString() ?? 'Unknown'}',
              'ticketId': '#${item['incident_id']?.toString() ?? ''}',
              'description': item['description']?.toString() ?? 'No description provided',
              'imageUrls': item['before_photos']?.toString() ?? '',
              'value': item['value']?.toString() ?? '',
              'pic_id': item['pic_id']?.toString() ?? '',
              'after_photos': item['after_photos']?.toString() ?? '',
              'action_taken': item['remark']?.toString() ?? '',
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load incidents: Status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching incidents: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching incidents: $e')),
      );
    }
  }

  Future<void> _updateIncidentStatus(int incidentId, String newStatus) async {
    final url = Uri.parse('http://assetin.my.id/skripsi/status_sa.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'incident_id': incidentId, 'status': newStatus}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        _fetchIncidents(); // Refresh data after update
      } else {
        print('Update Error: ${data['message']}');
      }
    } else {
      print('HTTP Error on update: ${response.statusCode} - ${response.body}');
    }
  }

  void _handleIncidentUpdate(Map<String, dynamic> updatedIncident) {
    setState(() {
      final int index = _incidentData.indexWhere((incident) => incident['ticketId'] == updatedIncident['ticketId']);
      if (index != -1) {
        _incidentData[index] = updatedIncident.cast<String, String>(); // Cast to Map<String, String>
        final String newStatus = updatedIncident['status']!;
        print('Updated incident status: $newStatus');
        print('Current incident data: $_incidentData');

        int newTabIndex = _statusCategories.indexWhere((status) => status.toLowerCase() == newStatus.toLowerCase());
        if (newTabIndex != -1) {
          _selectedTabIndex = newTabIndex;
          print('Switched to tab index: $_selectedTabIndex');
        } else {
          print('Status $newStatus not found in _statusCategories');
        }
      } else {
        print('Incident with ticketId ${updatedIncident['ticketId']} not found in _incidentData');
      }
    });

    _fetchIncidents(); // Refresh data from database
  }

  @override
  Widget build(BuildContext context) {
    final String currentStatus = _statusCategories[_selectedTabIndex];
    final List<Map<String, String>> filteredIncidents = _incidentData.where((incident) {
      return (incident['status'] ?? '').toLowerCase() == currentStatus.toLowerCase();
    }).toList();
    print('Current status: $currentStatus');
    print('Filtered incidents: $filteredIncidents');

    const double consistentAppBarHeight = 95.0;

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
                      onPressed: () => Navigator.pop(context),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 48,
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(_statusCategories.length, (index) => _buildTabItem(index, _statusCategories[index])),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 255, 255, 255),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Incident',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const Text(
                                  'Period 1 Jan 2025 - 30 Dec 2025',
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildCountItem('Total', _incidentData.length.toString()),
                                    const SizedBox(width: 8),
                                    _buildCountItem('Assigned', _incidentData.where((i) => (i['status'] ?? '').toLowerCase() == 'assigned').length.toString()),
                                    const SizedBox(width: 8),
                                    _buildCountItem('On Progress', _incidentData.where((i) => (i['status'] ?? '').toLowerCase() == 'on progress').length.toString()),
                                    const SizedBox(width: 8),
                                    _buildCountItem('Rejected', _incidentData.where((i) => (i['status'] ?? '').toLowerCase() == 'rejected').length.toString()),
                                    const SizedBox(width: 8),
                                    _buildCountItem('Completed', _incidentData.where((i) => (i['status'] ?? '').toLowerCase() == 'completed').length.toString()),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Data(${filteredIncidents.length})',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        filteredIncidents.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredIncidents.length,
                                itemBuilder: (context, index) {
                                  final incident = filteredIncidents[index];
                                  return _buildIncidentListItem(incident);
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.blueAccent : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.blueAccent : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCountItem(String label, String count) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 235, 233, 233),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              count,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentListItem(Map<String, String> incident) {
    Color chipColor;
    Color chipTextColor;
    switch (incident['status']?.toLowerCase()) {
      case 'assigned':
        chipColor = Colors.blue.withOpacity(0.1);
        chipTextColor = Colors.blue;
        break;
      case 'on progress':
        chipColor = Colors.orange.withOpacity(0.1);
        chipTextColor = Colors.orange;
        break;
      case 'rejected':
        chipColor = Colors.red.withOpacity(0.1);
        chipTextColor = Colors.red;
        break;
      case 'completed':
        chipColor = Colors.green.withOpacity(0.1);
        chipTextColor = Colors.green;
        break;
      default:
        chipColor = Colors.grey.withOpacity(0.1);
        chipTextColor = Colors.grey;
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    incident['title']!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    incident['status']!,
                    style: TextStyle(color: chipTextColor, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              incident['companyInfo']!,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Text(
              incident['description']!,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(height: 20, thickness: 1, color: Colors.grey),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(
                      incident['date']!,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SAIncidentDetailScreen(
                          incident: incident,
                          currentTabStatus: incident['status']!,
                          onIncidentUpdated: _handleIncidentUpdate,
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Detail',
                        style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 12),
                      ),
                      Icon(Icons.arrow_circle_right, size: 16, color: Colors.blue),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/nodata.png', width: 100),
          const SizedBox(height: 20),
          const Text('No data', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const Text('No incidents found.', style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}