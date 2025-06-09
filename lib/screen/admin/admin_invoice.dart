import 'package:asset_management/screen/admin/admin_invoice_detail.dart';
import 'package:asset_management/screen/models/user_role.dart'; // Import UserRole
import 'package:flutter/material.dart';

// CustomCard is a StatelessWidget that creates a reusable card component.
// This widget is included here for simplicity, but in a real app,
// it would typically be in its own separate file.
class CustomCard extends StatelessWidget {
  final String title;
  final String companyName;
  final String companyId; // Added companyId
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
      // Explicitly set the card color to white.
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
                  // Icon for the title (using laptop_outlined as per previous request).
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
                      // Status colors adjusted for 'Paid' and 'Unpaid'
                      color: status == 'Paid' ? Colors.green.shade100 : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8.0), // Rounded corners for status.
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: status == 'Paid' ? Colors.green.shade700 : Colors.red.shade700,
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


class AdminInvoice extends StatefulWidget {
  // 1. Declare final fields to store the passed data
  final String userName;
  final String userEmail;
  final UserRole userRole;

  // 2. Add a constructor to receive the data
  const AdminInvoice({
    Key? key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  }) : super(key: key);

  @override
  State<AdminInvoice> createState() => _InvoiceState();
}

class _InvoiceState extends State<AdminInvoice> with SingleTickerProviderStateMixin {
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

  final List<Map<String, String>> paidData = [
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

    // You can access the passed data using widget.userName, widget.userEmail, widget.userRole
    // For example, if you wanted to display it somewhere in this screen:
    // print('Invoice Screen User: ${widget.userName}, Role: ${widget.userRole}');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Changed to use CustomCard
  Widget _BuildCard(Map<String, String> cardData, bool isUnpaidTab) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CustomCard(
        title: cardData['title']!,
        companyName: cardData['company']!,
        companyId: '#110000', // Hardcoded as per your image, consider adding to data if dynamic
        dateTime: cardData['date']!,
        status: cardData['status']!,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminInvoiceDetail(status: cardData['status']!)), // Pass actual status
          );
        },
      ),
    );
  }

  // Removed unused helper methods
  // String _getMonthAbbreviation(int month) {
  //   const months = [
  //     '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  //     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  //   ];
  //   return months[month];
  // }

  // String _formatTime(int value) {
  //   return value.toString().padLeft(2, '0');
  // }


  Widget _buildTabContent(List<Map<String, String>> data, bool isUnpaidTab) {
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
        ...filteredData.map((item) => _BuildCard(item, isUnpaidTab)).toList(),
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
              tabs: const [
                Tab(text: 'Unpaid'),
                Tab(text: 'Paid'),
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
                prefixIcon: const Icon(Icons.search),
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
                _buildTabContent(paidData, false),  // Paid tab
              ],
            ),
          ),
        ],
      ),
    );
  }
}
