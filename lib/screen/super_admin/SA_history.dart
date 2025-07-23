// SA_history.dart
import 'package:asset_management/screen/models/user_role.dart';
import 'package:asset_management/screen/super_admin/SA_history_detail.dart';
import 'package:flutter/material.dart';

// CustomCard is a StatelessWidget that creates a reusable card component.
// This widget is included here for simplicity, but in a real app,
// it would typically be in its own separate file.
class CustomCard extends StatelessWidget {
  final String title;
  final String companyName;
  final String companyId; // Added companyId for the design
  final String dateTime; // Combined date and time into one string
  final String status;
  final VoidCallback? onTap; // Added onTap callback for card tap

  // Constructor for the CustomCard.
  const CustomCard({
    super.key,
    required this.title,
    required this.companyName,
    required this.companyId,
    required this.dateTime,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Set the card color to white.
      color: Colors.white,
      // Apply rounded corners to the card.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      // Set elevation for a shadow effect.
      elevation: 4.0,
      // Wrap the card content with InkWell for tap functionality.
      child: InkWell(
        onTap: onTap, // Use the provided onTap callback
        borderRadius: BorderRadius.circular(16.0), // Match card's border radius
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Make column take minimum space.
            crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start.
            children: [
              // Top section of the card: Title and Status.
              Row(
                children: [
                  // Icon for the title, changed to Icons.web_asset.
                  const Icon(Icons.web_asset, size: 24.0, color: Colors.black54),
                  const SizedBox(width: 8.0), // Spacing between icon and text.
                  // Title text.
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  // Status indicator.
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: status == 'Completed' || status == 'Done' ? Colors.green.shade100 : Colors.red.shade100, // Light green/red background.
                      borderRadius: BorderRadius.circular(8.0), // Rounded corners for status.
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: status == 'Completed' || status == 'Done' ? Colors.green.shade700 : Colors.red.shade700, // Darker green/red text.
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0), // Spacing between top and middle sections.

              // Middle section: Company Name and ID.
              Text(
                '$companyName - $companyId',
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16.0), // Spacing before the divider.

              // Divider line.
              const Divider(
                height: 1.0,
                color: Colors.grey,
              ),
              const SizedBox(height: 16.0), // Spacing after the divider.

              // Bottom section: Date, Time, and Detail button.
              Row(
                children: [
                  // Calendar icon.
                  const Icon(Icons.calendar_today_outlined, size: 20.0, color: Colors.black54),
                  const SizedBox(width: 8.0), // Spacing between icon and date/time.
                  // Date and Time text.
                  Expanded(
                    child: Text(
                      dateTime,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  // Detail button visual (the tap is handled by the whole card)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Detail',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 4.0), // Spacing between text and arrow.
                      // Arrow icon.
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100, // Light blue background for arrow.
                          shape: BoxShape.circle, // Circular shape.
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 16.0,
                          color: Colors.blue.shade700, // Darker blue arrow.
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class SuperAdminHistory extends StatefulWidget {
  @override
  State<SuperAdminHistory> createState() => _SuperAdminHistoryState(); // Corrected state class name
  final String userName;
  final String userEmail;
  final UserRole userRole;

  const SuperAdminHistory({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  });
}

class _SuperAdminHistoryState extends State<SuperAdminHistory> with SingleTickerProviderStateMixin { // Corrected state class name
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CustomCard(
        title: item['title']!,
        companyName: item['company']!,
        companyId: '#110000', // Hardcoded as per your image, consider adding to data if dynamic
        dateTime: item['date']!, // Pass the full date and time string
        status: item['status']!,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SAHistoryDetailScreen(
                status: isRejectedTab ? 'rejected' : 'done',
              ),
            ),
          );
        },
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
      backgroundColor: const Color.fromARGB(255, 245, 246, 250), // Corrected alpha value for F5F6FA
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
              tabs: const [ // Changed to const as tabs are static
                Tab(text: 'Done'),
                Tab(text: 'Rejected'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                // Trigger a rebuild when search text changes to filter cards
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search), // Changed to const
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