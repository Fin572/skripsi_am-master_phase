// admin_invoice_detail.dart
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class AdminInvoiceDetail extends StatefulWidget {
  final String status;

  const AdminInvoiceDetail({super.key, required this.status});

  @override
  State<AdminInvoiceDetail> createState() => _AdminInvoicedetailState();
}

class _AdminInvoicedetailState extends State<AdminInvoiceDetail> {
  int _selectedPaymentIndex = 0;
  final List<String> imageList = [
    'assets/cctv.png',
    'assets/cctv.png',
  ];

  @override
  Widget build(BuildContext context) {
    bool isPaid = widget.status == 'Paid';
    // Define the consistent AppBar height
    const double consistentAppBarHeight = 100.0; // Changed from 95.0 to 100.0

    return Scaffold(
      backgroundColor: const Color.fromARGB(245, 245, 245, 245),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(consistentAppBarHeight),
        child: Stack(
          children: [
            // Background image that covers the entire PreferredSize area
            Image.asset(
              'assets/bg_image.png', // Ensure this path is correct
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
                      'Invoice',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.status, // Display the status from the widget
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        if (widget.status == 'Unpaid')
                          const Icon(Icons.warning_amber_rounded,
                              color: Colors.orange, size: 24),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 200,
                        enableInfiniteScroll: true,
                        enlargeCenterPage: true,
                        viewportFraction: 1.0,
                      ),
                      items: imageList
                          .map((item) => ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(item,
                                    fit: BoxFit.cover, width: double.infinity),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Ticket ID', '#110000 - Kantor Pusat Cakung'),
                    _buildInfoRow('Location ID', '#110000 - Kantor Pusat Cakung'),
                    _buildInfoRow('Asset ID', '#001001'),
                    _buildInfoRow('Asset name', 'CCTV'),
                    _buildInfoRow('Person in charge', 'Margareth'),
                    _buildInfoRow('Phone number', '081208120812'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Saluran sudah kembali normal :\n• terdapat kerusakan di kabel dikarenakan digigit tikus',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    _buildInfoRow('Price', 'Rp. 200.000,-', isPrice: true),
                  ],
                ),
              ),
              // The payment method section is now only shown if isPaid is true
              if (isPaid) ...[
                const SizedBox(height: 24),
                const Text(
                  'Payment Method',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Text(
                    'QRIS  125081208120812',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: isPrice ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontWeight: isPrice ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}