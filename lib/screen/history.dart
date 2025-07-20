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
      final response = await http.get(Uri.parse('http://192.168.1.3/Skripsi/history_get.php?status=rejected'));
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

  Widget _buildCard(Map<String, String> item, bool isRejectedTab) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoryDetailScreen(
                status: isRejectedTab ? 'rejected' : 'done',
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(item['company']!, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(item['date']!, style: const TextStyle(fontSize: 12)),
                  const Spacer(),
                  Text(
                    item['status']!,
                    style: TextStyle(
                      color: item['status'] == 'Done' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
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
                height: 100,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/bg_image.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 45,
                left: 0,
                right: 0,
                child: const Center(
                  child: Text(
                    'History',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'Done'),
                Tab(text: 'Rejected'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
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