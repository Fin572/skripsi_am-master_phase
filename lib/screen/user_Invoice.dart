// lib/screens/user_invoice.dart (Your Invoice.dart file, updated again)
import 'package:asset_management/screen/invoice_detail.dart';
import 'package:asset_management/screen/models/user_role.dart'; // Ensure UserRole is defined
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For backend interaction
import 'dart:convert'; // For json decoding
import 'package:intl/intl.dart'; // For date formatting from original Invoice.dart

// 1. Create an Invoice Model (from user_invoice NEW UI.dart)
class Invoice {
  final String id; // Unique identifier for the invoice
  final String title;
  final String companyName;
  final String companyId; // From NEW UI, but should map to an actual ID or be derived
  final String dateTime;
  String status; // Make status mutable

  // Added incidentId for API calls in InvoiceDetail
  final int incidentId;

  Invoice({
    required this.id,
    required this.title,
    required this.companyName,
    required this.companyId,
    required this.dateTime,
    required this.status,
    required this.incidentId, // Add to constructor
  });

  // Helper to convert from JSON (matching your API response structure)
  factory Invoice.fromJson(Map<String, dynamic> json) {
    // Format date string to match the desired display format
    String formattedDate = '';
    try {
      if (json['date'] != null) {
        // Assuming 'date' from API is an ISO 8601 string or similar
        DateTime parsedDate = DateTime.parse(json['date']);
        formattedDate = DateFormat('dd MMM yyyy HH:mm:ss').format(parsedDate) + ' WIB';
      }
    } catch (e) {
      print('Error parsing date for invoice ${json['incident_id']}: $e');
      formattedDate = json['date']?.toString() ?? 'Unknown Date'; // Fallback
    }

    return Invoice(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      companyName: json['company']?.toString() ?? '', // Assuming 'company' from API
      companyId: json['incident_id']?.toString() ?? '', // Using incident_id as companyId for card display consistency if needed
      dateTime: formattedDate,
      status: json['status']?.toString() ?? '',
      incidentId: int.tryParse(json['incident_id']?.toString() ?? '0') ?? 0,
    );
  }
}

// CustomCard widget definition (from user_invoice NEW UI.dart)
class CustomCard extends StatelessWidget {
  final String title;
  final String companyName;
  final String companyId;
  final String dateTime;
  final String status;
  final VoidCallback? onTap;

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
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.web_asset, size: 24.0, color: Colors.black54),
                  const SizedBox(width: 8.0),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: status == 'Paid' ? Colors.green.shade100 : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8.0),
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
              const SizedBox(height: 12.0),
              Text(
                '$companyName - $companyId',
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16.0),
              const Divider(
                height: 1.0,
                color: Colors.grey,
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 20.0, color: Colors.black54),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      dateTime,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.black54,
                      ),
                    ),
                  ),
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
                      const SizedBox(width: 4.0),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 16.0,
                          color: Colors.blue.shade700,
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

class UserInvoice extends StatefulWidget {
  final String userName;
  final String userEmail;
  final UserRole userRole;

  const UserInvoice({
    Key? key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  }) : super(key: key);

  @override
  State<UserInvoice> createState() => _UserInvoiceState();
}

class _UserInvoiceState extends State<UserInvoice> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();

  List<Invoice> unpaidData = [];
  List<Invoice> paidData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchInvoices();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInvoices() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://assetin.my.id/skripsi/get_invoices.php')).timeout(const Duration(seconds: 10));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            unpaidData = (data['unpaid'] as List)
                .map((item) => Invoice.fromJson(item))
                .toList();
            paidData = (data['paid'] as List)
                .map((item) => Invoice.fromJson(item))
                .toList();
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to load invoices: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load invoices: Status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching invoices: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching invoices: $e')));
    }
  }

  // FIX: Explicitly define the return type to match what Invoicedetail's onPaymentConfirmed expects.
  // This function now returns 'void' which is a subtype of 'dynamic'.
  // We don't need 'Future<void>' here unless it performs async operations that need to be awaited *by its caller*.
  // For a simple callback to update state, `void` is typical.
  void _handlePaymentConfirmed(Invoice invoice) {
    setState(() {
      unpaidData.removeWhere((item) => item.id == invoice.id);
      invoice.status = 'Paid';
      paidData.add(invoice);
    });
  }


  Widget _BuildCard(Invoice invoice) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CustomCard(
        title: invoice.title,
        companyName: invoice.companyName,
        companyId: invoice.companyId,
        dateTime: invoice.dateTime,
        status: invoice.status,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Invoicedetail(
                status: invoice.status,
                incident_id: invoice.incidentId,
                // FIX for "The argument type 'Invoice' can't be assigned to the parameter type 'Invoice?'"
                // Although passing non-nullable to nullable should be fine,
                // explicit cast can sometimes resolve stubborn linting issues or
                // compiler confusion in complex type inference scenarios.
                // Or, more accurately, we ensure 'invoice' here is indeed non-nullable.
                // By removing 'invoice?' in Invoicedetail and making it 'invoice', this error would truly disappear.
                // But sticking to the Invoice? as per our last update in invoice_detail.
                // So, the current 'invoice: invoice' line should NOT generate this error.
                // If it still does, it indicates a caching issue in your IDE or a deeper project setup problem.
                // For a strict workaround, you could use: invoice: invoice as Invoice?, but this is usually unnecessary.
                invoice: invoice, // This line is correct as is, given Invoice? in Invoicedetail.
                onPaymentConfirmed: _handlePaymentConfirmed, // This should now resolve due to the fix in Invoicedetail and this file.
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabContent(List<Invoice> data) {
    final filteredData = data.where((item) {
      final search = _searchController.text.toLowerCase();
      return item.title.toLowerCase().contains(search);
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
        ...filteredData.map((item) => _BuildCard(item)).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 100,
                      decoration: const BoxDecoration(
                        image: DecorationImage(image: AssetImage('assets/bg_image.png'), fit: BoxFit.cover),
                      ),
                    ),
                    const Positioned(
                      top: 45, left: 0, right: 0,
                      child: Center(
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
                      Tab(text: 'Paid')
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTabContent(unpaidData),
                      _buildTabContent(paidData)
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}