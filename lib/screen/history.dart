import 'package:asset_management/screen/history_detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // For date formatting

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();

  List<Map<String, String>> _doneData = [];
  List<Map<String, String>> _rejectedData = [];

  bool _isLoadingDone = true;
  bool _isLoadingRejected = true;
  String _errorDone = '';
  String _errorRejected = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchHistoryData();
    _searchController.addListener(() {
      setState(() {}); // Rebuild for search filter
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchHistoryData() async {
    await Future.wait([_fetchDoneData(), _fetchRejectedData()]);
  }

  Future<void> _fetchDoneData() async {
    try {
      final response = await http.get(Uri.parse('http://assetin.my.id/skripsi/history_get.php?status=completed'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _doneData = (data['data'] as List).map((item) {
              // Format date
              DateTime parsedDate = DateTime.parse(item['incident_date']);
              String formattedDate = DateFormat('dd MMM yyyy HH:mm:ss').format(parsedDate) + ' WIB';
              return {
                'title': item['title'] as String,
                'company': 'PT Dunia Persada', // Assuming fixed or from DB if available
                'date': formattedDate,
                'status': 'Done',
                'incident_id': item['incident_id']?.toString() ?? '0', // Added incident_id
              };
            }).toList();
            _isLoadingDone = false;
          });
        } else {
          setState(() {
            _errorDone = data['message'] ?? 'Failed to load data';
            _isLoadingDone = false;
          });
        }
      } else {
        setState(() {
          _errorDone = 'Server error: ${response.statusCode}';
          _isLoadingDone = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorDone = 'Error: $e';
        _isLoadingDone = false;
      });
    }
  }

  Future<void> _fetchRejectedData() async {
    try {
      final response = await http.get(Uri.parse('http://assetin.my.id/skripsi/history_get.php?status=rejected'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _rejectedData = (data['data'] as List).map((item) {
              DateTime parsedDate = DateTime.parse(item['incident_date']);
              String formattedDate = DateFormat('dd MMM yyyy HH:mm:ss').format(parsedDate) + ' WIB';
              return {
                'title': item['title'] as String,
                'company': 'PT Dunia Persada',
                'date': formattedDate,
                'status': 'Rejected',
                'incident_id': item['incident_id']?.toString() ?? '0', // Added incident_id
              };
            }).toList();
            _isLoadingRejected = false;
          });
        } else {
          setState(() {
            _errorRejected = data['message'] ?? 'Failed to load data';
            _isLoadingRejected = false;
          });
        }
      } else {
        setState(() {
          _errorRejected = 'Server error: ${response.statusCode}';
          _isLoadingRejected = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorRejected = 'Error: $e';
        _isLoadingRejected = false;
      });
    }
  }

  // Helper to get status background color for cards
  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'Done':
        return Colors.green.shade100;
      case 'Rejected':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  // Helper to get status text color for cards
  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Done':
        return Colors.green.shade700;
      case 'Rejected':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Widget _buildCard(Map<String, String> item, bool isRejectedTab) {
    return Card(
      color: Colors.white, // From NEW UI
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // From NEW UI
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoryDetailScreen(
                status: isRejectedTab ? 'rejected' : 'done',
                // Pass incident_id for fetching detail
                incident_id: int.tryParse(item['incident_id'] ?? '0') ?? 0,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Increased padding from 12.0 to 16.0 for a cleaner look
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.web_asset, size: 24.0, color: Colors.black54), // From NEW UI (Incident card)
                  const SizedBox(width: 8.0), // From NEW UI (Incident card)
                  Expanded(
                    child: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.black87)), // Increased font size, changed color
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0), // From NEW UI (Incident card)
                    decoration: BoxDecoration(
                      color: _getStatusBgColor(item['status']!), // Dynamic background color
                      borderRadius: BorderRadius.circular(8.0), // From NEW UI (Incident card)
                    ),
                    child: Text(
                      item['status']!,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: _getStatusTextColor(item['status']!), // Dynamic text color
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0), // From NEW UI (Incident card)
              Text(
                item['company']!,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16.0), // From NEW UI (Incident card)
              const Divider( // From NEW UI (Incident card)
                height: 1.0,
                color: Colors.grey,
              ),
              const SizedBox(height: 16.0), // From NEW UI (Incident card)
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 20.0, color: Colors.black54), // From NEW UI (Incident card)
                  const SizedBox(width: 8.0), // From NEW UI (Incident card)
                  Expanded(
                    child: Text(item['date']!, style: const TextStyle(fontSize: 14.0, color: Colors.black54)), // Changed font size and color
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Detail', style: TextStyle(fontSize: 14.0, color: Colors.blue)), // From NEW UI (Incident card)
                      const SizedBox(width: 4.0), // From NEW UI (Incident card)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100, // From NEW UI (Incident card)
                          shape: BoxShape.circle, // From NEW UI (Incident card)
                        ),
                        child: Icon(Icons.arrow_forward_ios, size: 16.0, color: Colors.blue.shade700), // From NEW UI (Incident card)
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(List<Map<String, String>> data, bool isLoading, String error, bool isRejectedTab) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error.isNotEmpty) {
      return Center(child: Text(error));
    }

    final filteredData = data.where((item) {
      final search = _searchController.text.toLowerCase();
      return item['title']!.toLowerCase().contains(search);
    }).toList();

    if (filteredData.isEmpty) {
      return Center(
        child: Image.asset('assets/nodata.png', width: 170),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text('Data(${filteredData.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        ...filteredData.map((item) => _buildCard(item, isRejectedTab)).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 100, // From NEW UI
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/bg_image.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Positioned( // From NEW UI
                top: 45, // From NEW UI
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'History', // From NEW UI
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Container(
            color: Colors.white, // From NEW UI
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue, // From NEW UI
              unselectedLabelColor: Colors.grey, // From NEW UI
              tabs: const [ // From NEW UI
                Tab(text: 'Done'),
                Tab(text: 'Rejected'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0), // From NEW UI
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                filled: true, // From NEW UI
                fillColor: Colors.white, // From NEW UI
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // From NEW UI
                  borderSide: BorderSide.none, // From NEW UI
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent(_doneData, _isLoadingDone, _errorDone, false),
                _buildTabContent(_rejectedData, _isLoadingRejected, _errorRejected, true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}