import 'package:asset_management/screen/invoice_detail.dart';
import 'package:flutter/material.dart';

class Invoice extends StatefulWidget {
  const Invoice({Key? key}) : super(key: key);

  @override
  State<Invoice> createState() => _InvoiceState();
}

class _InvoiceState extends State<Invoice> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> unpaidData = [
    {
      'title': 'CCTV 1',
      'company': 'PT Dunia Persada',
      'date': '25 Jan 2025 11:21:30 WIB',
      'status': 'Unpaid',
    },
    {
      'title': 'CCTV 1',
      'company': 'PT Dunia Persada',
      'date': '24 Jan 2025 11:21:30 WIB',
      'status': 'Unpaid',
    },
    {
      'title': 'CCTV 1',
      'company': 'PT Dunia Persada',
      'date': '24 Jan 2025 11:21:30 WIB',
      'status': 'Unpaid',
    },
    {
      'title': 'CCTV 1',
      'company': 'PT Dunia Persada',
      'date': '24 Jan 2025 11:21:30 WIB',
      'status': 'Unpaid',
    },
    {
      'title': 'CCTV 1',
      'company': 'PT Dunia Persada',
      'date': '24 Jan 2025 11:21:30 WIB',
      'status': 'Unpaid',
    },
  ];

  final List<Map<String, String>> paidData  = [
    {
      'title': 'Laptop A',
      'company': 'PT Dunia Persada',
      'date': '20 Jan 2025 14:00:00 WIB',
      'status': 'Paid',
    },
    {
      'title': 'Laptop A',
      'company': 'PT Dunia Persada',
      'date': '20 Jan 2025 14:00:00 WIB',
      'status': 'Paid',
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

  Widget _BuildCard(Map<String, String> cardData, bool isunpaidTab) {
  return Card(
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 16.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.laptop_mac, size: 24, color: Colors.grey),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cardData['title'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cardData['company'] ?? '',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isunpaidTab
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  cardData['status'] ?? '',
                  style: TextStyle(
                    color: isunpaidTab ? Colors.red : Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1, color: Colors.grey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    cardData['date'] ?? '',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Invoicedetail(status: '',)),
                  );
                },
                child: const Row(
                  children: [
                    Text('Detail', style: TextStyle(color: Colors.blue)),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
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

String _getMonthAbbreviation(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  String _formatTime(int value) {
    return value.toString().padLeft(2, '0');
  }


Widget _buildTabContent(List<Map<String, String>> data, bool isunpaidTab) {
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
      ...filteredData.map((item) => _BuildCard(item, isunpaidTab)).toList(),
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
                    'Invoice',
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
                  Tab(text: 'Unpaid'),
                  Tab(text: 'Paid'),
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
      _buildTabContent(unpaidData, true),  // Unpaid tab
      _buildTabContent(paidData, false),   // Paid tab
    ],
  ),
),

        ],
      ),
    );
  }
}
