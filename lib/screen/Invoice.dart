import 'package:asset_management/screen/invoice_detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Invoice extends StatefulWidget {
  const Invoice({Key? key}) : super(key: key);

  @override
  State<Invoice> createState() => _InvoiceState();
}

class _InvoiceState extends State<Invoice> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> unpaidData = [];
  List<Map<String, String>> paidData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchInvoices();
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
      final response = await http.get(Uri.parse('http://192.168.1.9/skripsi/get_invoices.php')).timeout(const Duration(seconds: 10));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            unpaidData = (data['unpaid'] as List).map((item) => {
                  'title': item['title']?.toString() ?? '',
                  'company': item['company']?.toString() ?? '',
                  'date': item['date']?.toString() ?? '',
                  'status': item['status']?.toString() ?? '',
                  'incident_id': item['incident_id']?.toString() ?? '0',
                }).toList().cast<Map<String, String>>();
            paidData = (data['paid'] as List).map((item) => {
                  'title': item['title']?.toString() ?? '',
                  'company': item['company']?.toString() ?? '',
                  'date': item['date']?.toString() ?? '',
                  'status': item['status']?.toString() ?? '',
                  'incident_id': item['incident_id']?.toString() ?? '0',
                }).toList().cast<Map<String, String>>();
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

  Widget _BuildCard(Map<String, String> cardData, bool isUnpaidTab) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
                      Text(cardData['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(cardData['company'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUnpaidTab ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(cardData['status'] ?? '', style: TextStyle(color: isUnpaidTab ? Colors.red : Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
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
                    Text(cardData['date'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Invoicedetail(
                          status: cardData['status'] ?? '',
                          incident_id: int.tryParse(cardData['incident_id'] ?? '0') ?? 0,
                        ),
                      ),
                    );
                  },
                  child: const Row(
                    children: [Text('Detail', style: TextStyle(color: Colors.blue)), Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue)],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(List<Map<String, String>> data, bool isUnpaidTab) {
    final filteredData = data.where((item) => item['title']!.toLowerCase().contains(_searchController.text.toLowerCase())).toList();

    if (filteredData.isEmpty) {
      return Center(child: Image.asset('assets/nodata.png', width: 170));
    }

    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8), child: Text('Data(${filteredData.length})', style: const TextStyle(fontWeight: FontWeight.bold))),
        ...filteredData.map((item) => _BuildCard(item, isUnpaidTab)).toList(),
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
                    const Positioned(top: 45, left: 0, right: 0, child: Center(child: Text('Invoice', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)))),
                  ],
                ),
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [Tab(text: 'Unpaid'), Tab(text: 'Paid')],
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
                    children: [_buildTabContent(unpaidData, true), _buildTabContent(paidData, false)],
                  ),
                ),
              ],
            ),
    );
  }
}