// SA_incident.dart
import 'dart:async';
import 'dart:io'; // Kept, although not directly used for base64 now in _buildIncidentListItem itself

import 'package:asset_management/screen/super_admin/SA_incident_detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Preserved
import 'dart:convert'; // Preserved
import 'package:intl/intl.dart';

class SAIncidentScreen extends StatefulWidget {
  const SAIncidentScreen({Key? key}) : super(key: key);

  @override
  State<SAIncidentScreen> createState() => _SAIncidentScreenState();
}

class _SAIncidentScreenState extends State<SAIncidentScreen> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController(); // Added
  String _searchQuery = ''; // Added
  List<Map<String, String>> _incidentData = [];
  bool _isLoading = true; // Preserved

  final List<String> _mainStatusCategories = [ // Changed name for clarity with subStatus
    'Assigned',
    'On Progress',
    'Rejected',
    'Completed',
  ];

  @override
  void initState() {
    super.initState();
    _fetchIncidents(); // Preserved
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose the controller
    super.dispose();
  }

  Future<void> _fetchIncidents() async { // Preserved
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http
          .get(Uri.parse('http://assetin.my.id/skripsi/get_incidents.php'))
          .timeout(const Duration(seconds: 45));
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
              'subStatus': item['sub_status']?.toString() ?? '', // Added sub_status from backend
              'location': item['location_name']?.toString() ?? 'Location #${item['location_id']?.toString() ?? 'Unknown'}',
              'ticketId': '#${item['incident_id']?.toString() ?? ''}',
              'description': item['description']?.toString() ?? 'No description provided',
              'before_photos': item['before_photos']?.toString() ?? '',
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

  // _updateIncidentStatus is not directly used by this screen in the new flow, but preserved if backend needs it.
  Future<void> _updateIncidentStatus(int incidentId, String newStatus) async { // Preserved
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

  void _handleIncidentUpdate(Map<String, String> updatedIncident) { // Modified to handle NEW UI status logic
    setState(() {
      final int index = _incidentData.indexWhere((incident) => incident['ticketId'] == updatedIncident['ticketId']);
      if (index != -1) {
        // If the status is 'Approved by SA', remove the incident from the local list.
        // The backend `_fetchIncidents` will confirm this.
        if (updatedIncident['status'] == 'Approved by SA') {
          _incidentData.removeAt(index);
          ScaffoldMessenger.of(context).showSnackBar( // Show snackbar for archiving
            SnackBar(
              content: Text('Incident ${updatedIncident['title']} has been moved to archive.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Otherwise, just update the incident in the local list
          _incidentData[index] = updatedIncident;
        }

        // After updating, switch to the tab relevant to the incident's new primary status
        // Also handling subStatus changes (e.g., Rejected by Admin -> Rejected, Completed by Admin -> Completed)
        final String newMainStatus = updatedIncident['status']!;
        if (_mainStatusCategories.contains(newMainStatus)) {
          _selectedTabIndex = _mainStatusCategories.indexOf(newMainStatus);
        } else if (newMainStatus.toLowerCase().contains('rejected')) { // If it's a rejected sub-status like "Rejected by Admin"
            _selectedTabIndex = _mainStatusCategories.indexOf('Rejected');
        } else if (newMainStatus.toLowerCase().contains('completed')) { // If it's a completed sub-status like "Completed by Admin"
            _selectedTabIndex = _mainStatusCategories.indexOf('Completed');
        }

        // Clear search query after an update, or re-filter if desired
        _searchController.clear();
        _searchQuery = '';
      }
    });

    _fetchIncidents(); // Always refresh data from database after an update
  }

  // Helper to filter incidents based on the selected main tab AND search query
  List<Map<String, String>> _getFilteredIncidents() { // Added helper
    final String selectedMainCategory = _mainStatusCategories[_selectedTabIndex];
    String query = _searchQuery.toLowerCase(); // Use the current search query

    return _incidentData.where((incident) {
      final String incidentStatus = incident['status']!;
      final String incidentSubStatus = incident['subStatus'] ?? ''; // Safely get subStatus
      final String title = incident['title']!.toLowerCase();
      final String companyInfo = incident['companyInfo']!.toLowerCase();
      final String ticketId = incident['ticketId']!.toLowerCase();

      bool matchesStatus = false;
      if (selectedMainCategory == 'Assigned' || selectedMainCategory == 'On Progress') {
        matchesStatus = (incidentStatus == selectedMainCategory);
      } else if (selectedMainCategory == 'Rejected') {
        // Only show rejected incidents that are NOT 'Approved by SA' (i.e., awaiting review or freshly rejected)
        matchesStatus = (incidentStatus == 'Rejected' && incidentSubStatus != 'Approved by SA');
      } else if (selectedMainCategory == 'Completed') {
        // Only show completed incidents that are NOT 'Approved by SA'
        matchesStatus = (incidentStatus == 'Completed' && incidentSubStatus != 'Approved by SA');
      }

      // Check if the incident matches the search query across multiple fields
      bool matchesSearch = query.isEmpty ||
                           title.contains(query) ||
                           companyInfo.contains(query) ||
                           ticketId.contains(query);

      return matchesStatus && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> filteredIncidents = _getFilteredIncidents(); // Use filtered incidents

    const double consistentAppBarHeight = 100.0; // Consistent with NEW UI

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Preserved loading indicator
          : SingleChildScrollView(
              // Wrap with a GestureDetector to unfocus when tapping outside text field
              child: GestureDetector( // Added
                onTap: () { // Added
                  FocusScope.of(context).unfocus(); // Added
                }, // Added
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 48,
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(_mainStatusCategories.length, (index) => _buildTabItem(index, _mainStatusCategories[index])), // Use _mainStatusCategories
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: TextField(
                        controller: _searchController, // Assigned controller
                        autofocus: false, // Prevent autofocus
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
                        onChanged: (value) { // Added onChanged
                          setState(() {
                            _searchQuery = value; // Update the search query state
                          });
                        },
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
                                      _buildCountItem('Assigned', _incidentData.where((i) => i['status'] == 'Assigned').length.toString()),
                                      const SizedBox(width: 8),
                                      _buildCountItem('On Progress', _incidentData.where((i) => i['status'] == 'On Progress').length.toString()),
                                      const SizedBox(width: 8),
                                      _buildCountItem('Rejected', _incidentData.where((i) => i['status'] == 'Rejected' && (i['subStatus'] ?? '') != 'Approved by SA').length.toString()), // Conditional count
                                      const SizedBox(width: 8),
                                      _buildCountItem('Completed', _incidentData.where((i) => i['status'] == 'Completed' && (i['subStatus'] ?? '') != 'Approved by SA').length.toString()), // Conditional count
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
            ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
          _searchController.clear(); // Clear search when switching tabs
          _searchQuery = '';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color.fromRGBO(52, 152, 219, 1) : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color.fromRGBO(52, 152, 219, 1) : Colors.grey[600],
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
    String primaryStatus = incident['status']!;
    String subStatus = incident['subStatus'] ?? ''; // Get subStatus

    // Determine colors for primary status chip
    Color primaryChipColor;
    Color primaryChipTextColor;
    switch (primaryStatus) {
      case 'Assigned':
        primaryChipColor = Colors.blue.withOpacity(0.1);
        primaryChipTextColor = Colors.blue;
        break;
      case 'On Progress':
        primaryChipColor = Colors.orange.withOpacity(0.1);
        primaryChipTextColor = Colors.orange;
        break;
      case 'Rejected':
        primaryChipColor = Colors.red.withOpacity(0.1);
        primaryChipTextColor = Colors.red;
        break;
      case 'Completed':
        primaryChipColor = Colors.green.withOpacity(0.1);
        primaryChipTextColor = Colors.green;
        break;
      default:
        primaryChipColor = Colors.grey.withOpacity(0.1);
        primaryChipTextColor = Colors.grey;
    }

    // Determine colors and text for sub-status chip if it exists
    Color subChipColor = Colors.transparent;
    Color subChipTextColor = Colors.grey;
    String displaySubStatus = '';

    if (subStatus.isNotEmpty) {
      switch (subStatus) {
        case 'Awaiting SA Review':
          subChipColor = Colors.orange.withOpacity(0.1); // Light orange/yellow
          subChipTextColor = Colors.orange;
          displaySubStatus = 'Awaiting Review';
          break;
        case 'Approved by SA': // For display only, these incidents should be archived
          subChipColor = Colors.lightGreen.withOpacity(0.1);
          subChipTextColor = Colors.lightGreen;
          displaySubStatus = 'Approved';
          break;
        // You can add more sub-status cases if needed
        default:
          subChipColor = Colors.grey.withOpacity(0.1);
          subChipTextColor = Colors.grey;
          displaySubStatus = subStatus; // Fallback
      }
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
              crossAxisAlignment: CrossAxisAlignment.start, // Align to top for multi-line status
              children: [
                Expanded(
                  child: Text(
                    incident['title']!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8), // Space between title and status chips
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end, // Align chips to the right
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryChipColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        primaryStatus,
                        style: TextStyle(color: primaryChipTextColor, fontSize: 12),
                      ),
                    ),
                    if (displaySubStatus.isNotEmpty) // Show sub-status chip if it exists
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0), // Small space between chips
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: subChipColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            displaySubStatus,
                            style: TextStyle(color: subChipTextColor, fontSize: 11),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              incident['companyInfo']!,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
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
                          currentTabStatus: primaryStatus, // Pass main status
                          onIncidentUpdated: _handleIncidentUpdate, // Pass the callback
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
          Image.asset(
            'assets/nodata.png',
            width: 100,
          ),
          const SizedBox(height: 20),
          const Text(
            'No incidents found.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}