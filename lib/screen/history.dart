import 'package:asset_management/screen/history_detail.dart';
import 'package:flutter/material.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> doneData = [
    {
      'title': 'CCTV 1',
      'company': 'PT Dunia Persada',
      'date': '25 Jan 2025 11:21:30 WIB',
      'status': 'Done',
    },
    {
      'title': 'CCTV 1',
      'company': 'PT Dunia Persada',
      'date': '24 Jan 2025 11:21:30 WIB',
      'status': 'Done',
    },
    {
      'title': 'CCTV 1',
      'company': 'PT Dunia Persada',
      'date': '24 Jan 2025 11:21:30 WIB',
      'status': 'Done',
    },
    {
      'title': 'CCTV 1',
      'company': 'PT Dunia Persada',
      'date': '24 Jan 2025 11:21:30 WIB',
      'status': 'Done',
    },
    {
      'title': 'CCTV 1',
      'company': 'PT Dunia Persada',
      'date': '24 Jan 2025 11:21:30 WIB',
      'status': 'Done',
    },
  ];

  final List<Map<String, String>> rejectedData = [
    {
      'title': 'Laptop A',
      'company': 'PT Dunia Persada',
      'date': '20 Jan 2025 14:00:00 WIB',
      'status': 'Rejected',
    },
    {
      'title': 'Laptop A',
      'company': 'PT Dunia Persada',
      'date': '20 Jan 2025 14:00:00 WIB',
      'status': 'Rejected',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
                  item['status'] == 'Done' ? 'Done' : 'Rejected',
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

Widget _buildTabContent(List<Map<String, String>> data, bool isRejectedTab) {
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
      _buildTabContent(doneData, false), // false means "not rejected"
      _buildTabContent(rejectedData, true), // true means "is rejected"
    ],
  ),
),

        ],
      ),
    );
  }
}
